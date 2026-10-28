"""Run native input checks and optional captures sequentially on the real GPU."""
import argparse
from pathlib import Path
from verify import ROOT, run


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True)
    parser.add_argument('--capture', action='store_true')
    parser.add_argument('--side-output', help='New directory for versioned side-room captures and report')
    args = parser.parse_args()
    if not Path(args.godot).is_file(): raise SystemExit('Expected Godot executable')
    logs = ROOT / 'artifacts/verification'
    side = [args.godot, '--path', str(ROOT), '--script', 'res://tests/native_side_rooms.gd']
    if args.side_output:
        side += ['--', '--output', args.side_output]
    run(side, timeout=300, log_path=logs / 'native-side-rooms.log',
        expected=r'Native side rooms: \d+ checks; 0 failures; 28 captures\b')
    run([args.godot, '--path', str(ROOT), '--script', 'res://tests/native_interaction.gd',
         '--fixed-fps', '60', '--quit-after', '900'], log_path=logs / 'native-interaction.log',
        expected=r'Native interaction: \d+ checks; 0 failures\b')
    run([args.godot, '--path', str(ROOT), '--script', 'res://tests/native_dialogue_motion.gd',
         '--fixed-fps', '60', '--quit-after', '1800'], log_path=logs / 'native-dialogue-motion.log',
        expected=r'Native dialogue motion: \d+ checks; 0 failures\b')
    run([args.godot, '--path', str(ROOT), '--script', 'res://tests/native_hd2d.gd',
         '--fixed-fps', '60', '--quit-after', '1800'], log_path=logs / 'native-hd2d.log',
        expected=r'Native HD-2D: \d+ checks; 0 failures\b')
    run([args.godot, '--path', str(ROOT), '--script', 'res://tests/native_hd2d_locations.gd',
         '--fixed-fps', '60', '--quit-after', '5000'], log_path=logs / 'native-hd2d-locations.log',
        expected=r'Native HD-2D locations: \d+ checks; 0 failures\b')
    if args.capture:
        run([args.godot, '--path', str(ROOT), '--script', 'res://tests/capture_review.gd', '--quit-after', '900'],
            log_path=logs / 'native-review-current.log', expected=r'Native review: 19 captures saved')
    print('Native checks passed; simulation cadence is not a GPU performance measurement')


if __name__ == '__main__': main()
