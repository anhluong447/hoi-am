"""Native side-scroll render stress: `measure` one device/renderer, then `recommend` for the target."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import statistics
import subprocess
from verify import ROOT, run

BUDGET_MS = 16.7
FALLBACK_MS = 33.3
VRAM_BUDGET_MIB = 1024.0
INPUTS = ['src/bootstrap/previews/side_stress_preview.gd', 'src/bootstrap/previews/side_stress_preview.tscn',
          'src/bootstrap/previews/side_stress_textures.gd', 'src/bootstrap/previews/side_stress_effects.gd',
          'src/bootstrap/previews/side_stress_blur.gdshader', 'content/world2d/stress/stress_v1.json',
          'tests/profile_side_stress.gd', 'tools/profile_side_stress.py']


def percentile(values, fraction):
    ordered = sorted(values)
    return ordered[min(len(ordered) - 1, int((len(ordered) - 1) * fraction))]


def summarize(case, repetition, item):
    times = [sample['frame_ms'] for sample in case['samples']]
    gpu = [sample['root_gpu_ms'] for sample in case['samples']]
    keep = ['glow', 'plate_import', 'light_grid', 'plate_source', 'runtime_lights', 'runtime_blur', 'particles',
            'window_size', 'window_mode', 'viewport_size', 'focused', 'elapsed_seconds', 'discarded_attempts']
    return {'variant': case['variant'], 'resolution': case['resolution'], 'hdr_2d': case['hdr_2d'],
            'frames': len(times), 'p50_ms': statistics.median(times), 'p95_ms': percentile(times, .95),
            'p99_ms': percentile(times, .99), 'vram_mib': max(s['video_bytes'] for s in case['samples']) / 2**20,
            'texture_mib': max(s['texture_bytes'] for s in case['samples']) / 2**20,
            'gpu_p50_ms': statistics.median(gpu), 'gpu_p95_ms': percentile(gpu, .95),
            'median_draw_calls': statistics.median(s['draw_calls'] for s in case['samples']),
            'over_16_7ms': sum(value > BUDGET_MS for value in times), 'repetition': repetition,
            'adapter': item['adapter'], 'api': item['api'], 'renderer': item['renderer'],
            **{key: case[key] for key in keep}}


def measure(args):
    output = (ROOT / args.output).resolve()
    assert output.is_relative_to(ROOT) and not output.exists(), 'Use a new evidence directory'
    output.mkdir(parents=True)
    inputs = {path: hashlib.sha256((ROOT / path).read_bytes()).hexdigest() for path in INPUTS}
    machine = json.loads(subprocess.check_output(['powershell', '-NoProfile', '-Command',
        '@{cpu=(Get-CimInstance Win32_Processor | Select-Object Name);gpu=(Get-CimInstance Win32_VideoController | Select-Object Name,DriverVersion);os=(Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version)} | ConvertTo-Json -Depth 4'], text=True))
    engine_args = (['--gpu-index', str(args.gpu_index)] if args.gpu_index is not None else []) + \
        (['--rendering-method', args.rendering_method] if args.rendering_method else []) +         (['--rendering-driver', args.rendering_driver] if args.rendering_driver else [])
    raws = []
    for index in range(1, args.runs + 1):
        raw = ROOT / 'artifacts/profile' / f'{output.parent.name}-{output.name}-run{index}.json'
        assert not raw.exists(), 'Preserve raw measurements'
        command = [args.godot, '--path', str(ROOT), *engine_args, '--script', 'res://tests/profile_side_stress.gd',
                   '--', '--output', 'res://' + raw.relative_to(ROOT).as_posix(), '--resolutions', args.resolutions,
                   '--screen', args.screen]
        if args.variants:
            command.extend(['--variants', args.variants])
        if index == 1:
            command.extend(['--captures', output.as_posix()])
        run(command, timeout=1800, log_path=output / f'profile-run{index}.log',
            expected=r'Side stress profile: \d+ runs; real clock; completed')
        raws.append(raw)
    assert all(hashlib.sha256((ROOT / p).read_bytes()).hexdigest() == d for p, d in inputs.items()), 'Inputs changed during measurement'
    data = [json.loads(raw.read_text(encoding='utf-8')) for raw in raws]
    for item in data:
        assert args.expect_adapter.lower() in item['adapter'].lower(), f"Measured on {item['adapter']}"
        for case in item['runs']:
            # A minimised or resized window renders nothing comparable; reject instead of averaging.
            assert case['minimized_frames'] == 0 and case['window_mode'] in (0, 4) and case['viewport_size'] == case['resolution'], (
                f"Invalid window state: {case['variant']} {case['resolution']} mode={case['window_mode']} viewport={case['viewport_size']}")
    rows = [summarize(case, index + 1, item) for index, item in enumerate(data) for case in item['runs']]
    payload = json.dumps({raw.name: item for raw, item in zip(raws, data)}).encode('utf-8')
    (output / 'samples.json.gz').write_bytes(gzip.compress(payload, mtime=0))
    first = data[0]
    machine.update({key: first[key] for key in ['engine', 'adapter', 'adapter_vendor', 'adapter_api_version', 'api', 'renderer', 'screen', 'gpu_index_arg']})
    profile = {'machine': machine, 'engine_args': engine_args, 'repetitions': args.runs, 'inputs': inputs,
               'protocol': {key: first[key] for key in ['vsync', 'cap_fps', 'fixed_fps', 'warmup_seconds', 'sample_seconds', 'spec_id', 'light_settings']},
               'samples_sha256': hashlib.sha256(payload).hexdigest(), 'runs': rows,
               'observations': {'captures': first['captures'], 'plate_compare': first['plate_compare']}}
    (output / 'profile.json').write_text(json.dumps(profile, indent=2) + '\n', encoding='utf-8')
    print_table(rows)


def light_count(row, cap):
    return min(row['runtime_lights'] + (32 if row['light_grid'] else 0), cap)


def recommend(args):
    profiles = [json.loads((ROOT / path / 'profile.json').read_text(encoding='utf-8')) for path in args.target]
    rows = [row for profile in profiles for row in profile['runs'] if row['resolution'] == [1920, 1080]]
    worst = {}
    for row in rows:
        key = (row['renderer'], row['variant'])
        worst[key] = max(worst.get(key, row), row, key=lambda r: r['p95_ms'])
    casual = {renderer: row for (renderer, variant), row in worst.items() if variant == 'casual'}
    passing = [r for r, row in casual.items() if row['p95_ms'] <= BUDGET_MS]
    renderer = min(passing or casual, key=lambda r: casual[r]['p95_ms'])
    chosen = {variant: row for (r, variant), row in worst.items() if r == renderer}
    ok = {variant for variant, row in chosen.items() if row['p95_ms'] <= BUDGET_MS}
    observed = next(p['observations'] for p in profiles if p['machine']['renderer'] == renderer)
    cap = observed['captures']['light_probe_sdr']['lights_lit']
    lit = [light_count(chosen[v], cap) for v in ok]
    gpu_dust = chosen.get('casual_gpu_particles')
    base = chosen['casual']
    gpu_better = bool(gpu_dust) and (gpu_dust['p95_ms'] < base['p95_ms'] - 0.1 or (
        abs(gpu_dust['p95_ms'] - base['p95_ms']) <= 0.1 and gpu_dust['p50_ms'] < base['p50_ms'] - 0.1))
    if 'casual' in ok and base['vram_mib'] <= VRAM_BUDGET_MIB:
        plate_import = 'lossless'
    elif 'casual_bptc' in ok:
        plate_import = 'vram_bptc'
    else:
        plate_import = 'lossless' if base['p95_ms'] <= chosen['casual_bptc']['p95_ms'] else 'vram_bptc'
    hdr = worst.get(('forward_plus', 'hdr_glow'))
    recommendation = {'renderer': renderer, 'hdr_2d': renderer == 'forward_plus' and hdr is not None and hdr['p95_ms'] <= BUDGET_MS,
                      'plate_source': [3840, 2160] if 'baseline' in ok else base['plate_source'],
                      'plate_import': plate_import, 'max_runtime_lights': max(lit) if lit else 1,
                      'particles': 'gpu' if gpu_better else 'cpu'}
    basis = {'target': 'Intel UHD Graphics iGPU, 1920x1080, p95 <= 16.7 ms (hardware target set by user 2026-10-28)',
             'casual_p95_ms': {r: row['p95_ms'] for r, row in casual.items()},
             'casual_meets_16_7ms': {r: row['p95_ms'] <= BUDGET_MS for r, row in casual.items()},
             'casual_meets_33_3ms': {r: row['p95_ms'] <= FALLBACK_MS for r, row in casual.items()},
             'variants_meeting_budget_on_renderer': sorted(ok), 'probe_lights_lit_sdr': cap,
             'plate_compare': observed['plate_compare'],
             'rules': {'renderer': 'lowest casual p95 among renderers meeting 16.7 ms; if none meet it, lowest casual p95',
                       'hdr_2d': 'only with forward_plus when hdr_glow on the iGPU meets 16.7 ms',
                       'plate_source': '3840x2160 only if the 4K baseline meets budget on the chosen renderer, else the casual source',
                       'plate_import': 'lossless if casual meets budget within 1 GiB VRAM, else vram_bptc if casual_bptc meets it, else the lower p95',
                       'max_runtime_lights': 'largest light count among variants meeting budget on the chosen renderer, capped by the observed per-item limit; 1 if none',
                       'particles': 'gpu only if casual_gpu_particles beats CPU dust by more than 0.1 ms p95 (or p50 on a tie), else cpu'}}
    reference = json.loads((ROOT / args.reference).read_text(encoding='utf-8'))
    report = {'machine': profiles[0]['machine'], 'target_profiles': args.target, 'runs': [row for p in profiles for row in p['runs']],
              'recommendation': recommendation, 'basis': basis,
              'observations': {p['machine']['renderer']: p['observations'] for p in profiles},
              'reference': {'source': args.reference, 'adapter': reference['machine']['adapter'],
                            'note': 'High-end reference only; its recommendation targeted the RTX and is superseded.',
                            'superseded_recommendation': reference['recommendation'], 'runs': reference['runs']}}
    output = ROOT / args.output
    assert not output.exists(), 'Preserve earlier reports'
    output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print_table(report['runs'])
    print('Recommendation:', json.dumps(recommendation))


def print_table(rows):
    print('| Renderer | Variant | Resolution | Rep | Frames | p50 ms | p95 ms | p99 ms | GPU p50 ms | VRAM MiB |')
    print('| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |')
    for row in rows:
        print(f"| {row.get('renderer', '')} | {row['variant']} | {row['resolution'][0]}x{row['resolution'][1]} | {row['repetition']} | {row['frames']} | "
              f"{row['p50_ms']:.2f} | {row['p95_ms']:.2f} | {row['p99_ms']:.2f} | {row['gpu_p50_ms']:.2f} | {row['vram_mib']:.1f} |")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='command', required=True)
    one = sub.add_parser('measure')
    one.add_argument('--godot', required=True)
    one.add_argument('--output', required=True)
    one.add_argument('--expect-adapter', required=True, help='Substring the measured adapter name must contain')
    one.add_argument('--runs', type=int, default=3)
    one.add_argument('--gpu-index', type=int)
    one.add_argument('--rendering-method')
    one.add_argument('--rendering-driver')
    one.add_argument('--screen', default='largest', help='Screen index for the window; use the screen wired to the measured GPU')
    one.add_argument('--variants', default='')
    one.add_argument('--resolutions', default='1920x1080,2560x1440')
    two = sub.add_parser('recommend')
    two.add_argument('--target', nargs='+', required=True)
    two.add_argument('--reference', required=True)
    two.add_argument('--output', required=True)
    args = parser.parse_args()
    measure(args) if args.command == 'measure' else recommend(args)


if __name__ == '__main__':
    main()
