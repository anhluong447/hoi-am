"""Run isolated real-clock HD-2D measurements, retain all samples and summarize."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import platform
import statistics
import subprocess
from verify import ROOT, run


def percentile(values, fraction):
    ordered = sorted(values)
    return ordered[min(len(ordered) - 1, int((len(ordered) - 1) * fraction))]


def summarize(raw, output):
    data = json.loads(raw.read_text(encoding='utf-8'))
    rows = []
    for case in data['runs']:
        samples = case['samples']
        times = [sample['frame_ms'] for sample in samples]
        rows.append({**{key: value for key, value in case.items() if key != 'samples'},
            'sample_count': len(times), 'median_ms': statistics.median(times),
            'p95_ms': percentile(times, .95), 'p99_ms': percentile(times, .99),
            'over_33ms': sum(value > 33.333 for value in times),
            'over_50ms': sum(value > 50 for value in times),
            'median_gpu_ms': statistics.median(sample['root_gpu_ms'] for sample in samples),
            'median_draw_calls': statistics.median(sample['draw_calls'] for sample in samples),
            'max_video_bytes': max(sample['video_bytes'] for sample in samples)})
    payload = raw.read_bytes()
    compressed = output / 'samples.json.gz'
    assert not compressed.exists()
    compressed.write_bytes(gzip.compress(payload, mtime=0))
    report = {key: value for key, value in data.items() if key != 'runs'}
    report.update({'machine': platform.platform(), 'raw_sha256': hashlib.sha256(payload).hexdigest(),
        'raw_gzip_sha256': hashlib.sha256(compressed.read_bytes()).hexdigest(), 'runs': rows})
    (output / 'summary.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    lines = ['# Real-clock HD-2D profile', '',
        'VSync disabled; 120 FPS cap; 10-second warm-up and at least 30 seconds measured, three repetitions.',
        'All runs retained. Editor remains open. These are device/session measurements, not exported-build certification.', '',
        '| Resolution | Case | Repeat | Median ms | p95 ms | p99 ms | >33 ms |',
        '| --- | --- | ---: | ---: | ---: | ---: | ---: |']
    for row in rows:
        lines.append(f"| {row['resolution'][0]}x{row['resolution'][1]} | {row['mode']} | {row['repetition']} | "
            f"{row['median_ms']:.2f} | {row['p95_ms']:.2f} | {row['p99_ms']:.2f} | {row['over_33ms']} |")
    lines.extend(['', 'Root GPU timestamps exclude dialogue SubViewport passes; wall frame time includes them.',
        'Draw/object counters are total counters. No separate transparent-pass timing is claimed.',
        'See summary.json for adapter/driver/memory and samples.json.gz for every measured frame.', ''])
    (output / 'report.md').write_text('\n'.join(lines), encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True)
    parser.add_argument('--output', required=True)
    args = parser.parse_args()
    output = Path(args.output).resolve()
    assert output.is_relative_to(ROOT) and not output.exists(), 'Use a new project evidence directory'
    output.mkdir(parents=True)
    inputs = {}
    for folder in ['src/world', 'src/bootstrap/gameplay']:
        for path in (ROOT / folder).rglob('*.gd'):
            inputs[path.relative_to(ROOT).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    for path in [ROOT / 'content/world/locations.json', ROOT / 'content/world/newsroom_hd2d_v1.json']:
        inputs[path.relative_to(ROOT).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
    (output / 'inputs.json').write_text(json.dumps(inputs, indent=2) + '\n', encoding='utf-8')
    machine = subprocess.check_output(['powershell', '-NoProfile', '-Command',
        '@{cpu=(Get-CimInstance Win32_Processor | Select-Object Name);gpu=(Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion);os=(Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version)} | ConvertTo-Json -Depth 4'], text=True)
    (output / 'machine.json').write_text(machine, encoding='utf-8')
    raw = ROOT / 'artifacts/profile' / (output.name + '.json')
    assert not raw.exists(), 'Preserve raw measurements'
    run([args.godot, '--path', str(ROOT), '--script', 'res://tests/profile_hd2d.gd',
         '--', '--output', 'res://' + raw.relative_to(ROOT).as_posix()], timeout=2200,
        log_path=output / 'profile.log', expected=r'HD-2D profile: 42 runs; real clock; completed')
    summarize(raw, output)
    print('HD-2D profile evidence saved; inspect all repetitions before accepting performance')


if __name__ == '__main__':
    main()
