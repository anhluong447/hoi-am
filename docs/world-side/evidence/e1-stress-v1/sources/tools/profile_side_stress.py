"""Run the native side-scroll render stress profile three times, merge and recommend."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import statistics
import subprocess
from verify import ROOT, run

BUDGET_MS = 16.7
VRAM_BUDGET_MIB = 1024.0
INPUTS = ['src/bootstrap/previews/side_stress_preview.gd', 'src/bootstrap/previews/side_stress_preview.tscn',
          'src/bootstrap/previews/side_stress_textures.gd', 'src/bootstrap/previews/side_stress_blur.gdshader',
          'content/world2d/stress/stress_v1.json', 'tests/profile_side_stress.gd', 'tools/profile_side_stress.py']


def percentile(values, fraction):
    ordered = sorted(values)
    return ordered[min(len(ordered) - 1, int((len(ordered) - 1) * fraction))]


def summarize(case, repetition):
    times = [sample['frame_ms'] for sample in case['samples']]
    gpu = [sample['root_gpu_ms'] for sample in case['samples']]
    return {'variant': case['variant'], 'resolution': case['resolution'], 'hdr_2d': case['hdr_2d'],
            'frames': len(times), 'p50_ms': statistics.median(times), 'p95_ms': percentile(times, .95),
            'p99_ms': percentile(times, .99), 'vram_mib': max(s['video_bytes'] for s in case['samples']) / 2**20,
            'texture_mib': max(s['texture_bytes'] for s in case['samples']) / 2**20,
            'gpu_p50_ms': statistics.median(gpu), 'gpu_p95_ms': percentile(gpu, .95),
            'median_draw_calls': statistics.median(s['draw_calls'] for s in case['samples']),
            'over_16_7ms': sum(value > BUDGET_MS for value in times), 'repetition': repetition,
            'glow': case['glow'], 'plate_import': case['plate_import'], 'light_grid': case['light_grid'],
            'window_size': case['window_size'], 'window_mode': case['window_mode'],
            'viewport_size': case['viewport_size'], 'focused': case['focused'], 'elapsed_seconds': case['elapsed_seconds']}


def worst(rows, variants, width, field):
    values = [row[field] for row in rows if row['variant'] in variants and row['resolution'][0] == width]
    assert values, (variants, width)
    return max(values)


def recommend(rows, first):
    probe = first['captures']['light_probe']
    hdr_p95 = worst(rows, ['hdr', 'hdr_glow'], 1920, 'p95_ms')
    lossless_vram = worst(rows, ['hdr_glow'], 2560, 'vram_mib')
    bptc_vram = worst(rows, ['hdr_glow_bptc'], 2560, 'vram_mib')
    lights_p95 = worst(rows, ['hdr_glow_lights32'], 1920, 'p95_ms')
    lossless = lossless_vram <= VRAM_BUDGET_MIB and worst(rows, ['hdr_glow'], 1920, 'p95_ms') <= BUDGET_MS
    lights = probe['lights_lit'] if lights_p95 <= BUDGET_MS else 3
    basis = {'budget_ms': BUDGET_MS, 'vram_budget_mib': VRAM_BUDGET_MIB,
             'hdr_worst_p95_1080p_ms': hdr_p95, 'hdr_glow_lossless_vram_1440p_mib': lossless_vram,
             'hdr_glow_bptc_vram_1440p_mib': bptc_vram, 'plate_compare': first['plate_compare'],
             'lights32_worst_p95_1080p_ms': lights_p95, 'probe_lights_lit': probe['lights_lit'],
             'probe_lights_total': probe['lights_total'],
             'rules': {'hdr_2d': 'every hdr/hdr_glow repetition at 1920x1080 has p95 <= budget',
                       'plate_import': 'lossless when hdr_glow lossless VRAM at 2560x1440 <= budget and its 1080p p95 <= budget, else vram_bptc',
                       'max_runtime_lights': 'observed per-item light cap when every 32-light repetition at 1080p meets budget, else the 3 tested baseline lights'}}
    return {'hdr_2d': hdr_p95 <= BUDGET_MS, 'plate_import': 'lossless' if lossless else 'vram_bptc',
            'max_runtime_lights': lights}, basis


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True)
    parser.add_argument('--output', default='docs/world-side/evidence/e1-stress-v1')
    parser.add_argument('--runs', type=int, default=3)
    args = parser.parse_args()
    output = (ROOT / args.output).resolve()
    assert output.is_relative_to(ROOT) and not output.exists(), 'Use a new evidence directory'
    output.mkdir(parents=True)
    inputs = {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest() for path in INPUTS}
    machine = json.loads(subprocess.check_output(['powershell', '-NoProfile', '-Command',
        '@{cpu=(Get-CimInstance Win32_Processor | Select-Object Name);gpu=(Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion);os=(Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version)} | ConvertTo-Json -Depth 4'], text=True))
    raws = []
    for index in range(1, args.runs + 1):
        raw = ROOT / 'artifacts/profile' / f'{output.name}-run{index}.json'
        assert not raw.exists(), 'Preserve raw measurements'
        command = [args.godot, '--path', str(ROOT), '--script', 'res://tests/profile_side_stress.gd',
                   '--', '--output', 'res://' + raw.relative_to(ROOT).as_posix()]
        if index == 1:
            command.extend(['--captures', output.as_posix()])
        try:
            run(command, timeout=1800, log_path=output / f'profile-run{index}.log',
                expected=r'Side stress profile: \d+ runs; real clock; completed')
        except SystemExit:
            print(f'Run {index} failed; raw partial samples kept at {raw}', flush=True)
            raise
        raws.append(raw)
    assert all(hashlib.sha256((ROOT / p).read_bytes()).hexdigest() == d for p, d in inputs.items()), 'Inputs changed during measurement'
    data = [json.loads(raw.read_text(encoding='utf-8')) for raw in raws]
    for item in data:
        for case in item['runs']:
            # A minimised or resized window renders nothing comparable; reject instead of averaging.
            assert case['window_mode'] in (0, 4) and case['viewport_size'] == case['resolution'], (
                f"Invalid window state: {case['variant']} {case['resolution']} mode={case['window_mode']} viewport={case['viewport_size']}")
    rows = [summarize(case, index + 1) for index, item in enumerate(data) for case in item['runs']]
    first = data[0]
    recommendation, basis = recommend(rows, first)
    payload = json.dumps({raw.name: item for raw, item in zip(raws, data)}).encode('utf-8')
    (output / 'samples.json.gz').write_bytes(gzip.compress(payload, mtime=0))
    machine.update({key: first[key] for key in ['engine', 'adapter', 'adapter_vendor', 'adapter_api_version', 'api', 'renderer', 'screen']})
    report = {'machine': machine, 'protocol': {key: first[key] for key in ['vsync', 'cap_fps', 'fixed_fps', 'warmup_seconds', 'sample_seconds', 'spec_id', 'light_settings']},
              'repetitions': args.runs, 'inputs': inputs, 'samples_sha256': hashlib.sha256(payload).hexdigest(),
              'runs': rows, 'recommendation': recommendation, 'basis': basis,
              'observations': {'captures': first['captures'], 'plate_compare': first['plate_compare']}}
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print('| Variant | Resolution | Rep | Frames | p50 ms | p95 ms | p99 ms | GPU p50 ms | GPU p95 ms | VRAM MiB |')
    print('| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |')
    for row in rows:
        print(f"| {row['variant']} | {row['resolution'][0]}x{row['resolution'][1]} | {row['repetition']} | {row['frames']} | "
              f"{row['p50_ms']:.2f} | {row['p95_ms']:.2f} | {row['p99_ms']:.2f} | {row['gpu_p50_ms']:.2f} | {row['gpu_p95_ms']:.2f} | {row['vram_mib']:.1f} |")
    print('Recommendation:', json.dumps(recommendation))
    print('Side stress evidence saved; inspect every repetition before accepting')


if __name__ == '__main__':
    main()
