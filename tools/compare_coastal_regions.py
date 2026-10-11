"""Before/after diagnostics for reference-owned coastal UI regions; no pass threshold."""
import argparse
import hashlib
import json
from pathlib import Path
from compare_ui import png, ROOT


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--before', type=Path, required=True)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--screen', choices=['dialogue', 'hud'], default='dialogue')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists():
        raise SystemExit('Refusing to overwrite historical diagnostics')
    spec_path = ROOT / 'docs/ui-specs/coastal-review-regions.json'
    spec = json.loads(spec_path.read_text(encoding='utf-8'))
    ref_path = ROOT / 'docs/reference/coastal-editorial-v1' / ('01-dialogue.png' if args.screen == 'dialogue' else '03-hud-map.png')
    mask_path = ROOT / 'docs/reviews/chapters-01-05/ui-mask-v3.png'
    ref, before, candidate = png(ref_path), png(args.before), png(args.candidate)
    mask = png(mask_path) if args.screen == 'dialogue' else None
    for bitmap in [ref, before, candidate] + ([mask] if mask else []):
        assert bitmap[:2] == tuple(spec['plane'])
    width, _height = spec['plane']
    rows = []
    for name, (x, y, w, h) in spec[args.screen].items():
        count = old_error = new_error = 0
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                pixel = yy * width + xx
                if mask:
                    p = pixel * mask[2]
                    if mask[3][p] <= 127 or (mask[2] == 4 and mask[3][p + 3] <= 127):
                        continue
                count += 1
                for channel in range(3):
                    r = ref[3][pixel * ref[2] + channel]
                    old_error += abs(r - before[3][pixel * before[2] + channel])
                    new_error += abs(r - candidate[3][pixel * candidate[2] + channel])
        assert count > 0
        old, new = old_error / (count * 3), new_error / (count * 3)
        rows.append({'id': name, 'bounds': [x, y, w, h], 'pixels': count,
                     'before_mae': old, 'candidate_mae': new, 'delta_mae': new - old})
    digest = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
    report = {'schema_version': 1, 'screen': args.screen, 'plane': spec['plane'], 'policy': spec['policy'],
              'reference_sha256': digest(ref_path), 'before_sha256': digest(args.before),
              'candidate_sha256': digest(args.candidate), 'regions_sha256': digest(spec_path),
              'mask_sha256': digest(mask_path) if mask else None, 'regions': rows,
              'acceptance': 'Diagnostic only; original reference and mask unchanged; no G2 pass threshold'}
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    for row in rows:
        print(f"{row['id']}: {row['before_mae']:.3f} -> {row['candidate_mae']:.3f}; delta {row['delta_mae']:+.3f}")


if __name__ == '__main__':
    main()
