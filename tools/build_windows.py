"""Export debug/release, distribute licenses and execute each in a clean directory."""
import argparse
from pathlib import Path
import shutil
import tempfile
from verify import ROOT, run


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', required=True)
    args = parser.parse_args()
    build = ROOT / 'build/windows'
    build.mkdir(parents=True, exist_ok=True)
    logs = ROOT / 'artifacts/verification'
    for kind in ['debug', 'release']:
        target = build / kind
        target.mkdir(exist_ok=True)
        run([args.godot, '--headless', '--path', str(ROOT), '--export-' + kind,
             'Windows Desktop', str(target / 'hoi-am.exe')], timeout=180,
            log_path=logs / ('export-' + kind + '.log'))
        licenses = target / 'licenses'
        licenses.mkdir(exist_ok=True)
        for path in (ROOT / 'assets/licenses').glob('*.txt'):
            shutil.copy2(path, licenses / path.name)
        for folder in (ROOT / 'assets/fonts').iterdir():
            for path in folder.glob('*'):
                if path.name.lower().startswith(('ofl', 'license')):
                    shutil.copy2(path, licenses / (folder.name + '-' + path.name))
        with tempfile.TemporaryDirectory(prefix='hoi-am-native-' + kind + '-') as directory:
            clean = Path(directory)
            shutil.copytree(target, clean, dirs_exist_ok=True)
            assert not (clean / 'project.godot').exists()
            run([str(clean / 'hoi-am.exe'), '--quit-after', '600',
                 '--', '--self-check', '--capture'], timeout=120,
                log_path=logs / ('native-export-' + kind + '.log'), cwd=clean,
                expected=r'Release checks: packaged gameplay, management, save/load, ruleset isolation, formula content, font glyphs, room travel passed')
        print(f'{kind}: clean-folder native build verified')
    print('Windows export passed: debug and release, standalone packaging and user save/load')


if __name__ == '__main__':
    main()
