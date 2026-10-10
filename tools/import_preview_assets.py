"""Copy selected existing art and its authoring provenance; never edit source bytes."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parent.parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, required=True)
    source = parser.parse_args().source.resolve()
    pairs = []
    for folder in ['pilot-v2', 'pilot-v5', 'pilot-v6']:
        # Keep generation/registration inputs for the selected actor sheets.
        for path in (source / 'assets/pixel' / folder).iterdir():
            if path.suffix in {'.png', '.json', '.txt', '.md'}:
                pairs.append((path, ROOT / 'assets/actors/source' / folder / path.name))
    for actor, folder in [('khue', 'pilot-v6'), ('van', 'pilot-v2')]:
        pairs.append((source / f'assets/pixel/{folder}/{actor}.png', ROOT / f'assets/actors/{actor}.png'))
    pairs.append((source / 'assets/pixel/atlas.json', ROOT / 'docs/reference/actors/atlas.source.json'))
    for path in (source / 'assets/ui/coastal-replica/v3').rglob('*'):
        if path.is_file():
            relative = path.relative_to(source / 'assets/ui/coastal-replica/v3')
            pairs.append((path, ROOT / 'assets/ui/coastal/source' / relative))
    for folder in ['cormorantgaramond', 'dancingscript']:
        for path in (source / 'assets/fonts/coastal-replica' / folder).iterdir():
            pairs.append((path, ROOT / 'assets/fonts' / folder / path.name))
    pairs += [(source / p, ROOT / 'docs/reference/art' / Path(p).name) for p in [
        'assets/pixel/CHARACTER-ART.md', 'assets/fonts/coastal-replica/manifest.json',
        'content/ui/coastal-dialogue-ui.json', 'assets/ui/coastal-replica/v2/prompts.json']]
    entries = []
    for original, target in pairs:
        if target.exists():
            raise SystemExit(f'Refusing overwrite: {target}')
        if not original.is_file():
            raise SystemExit(f'Missing source: {original}')
    for original, target in pairs:
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(original, target)
        digest = hashlib.sha256(original.read_bytes()).hexdigest()
        assert hashlib.sha256(target.read_bytes()).hexdigest() == digest
        entries.append({'source': original.relative_to(source).as_posix(),
                        'target': target.relative_to(ROOT).as_posix(), 'sha256': digest})
    path = ROOT / 'docs/migration/art-import-manifest.json'
    path.write_text(json.dumps({'version': 1, 'files': entries}, indent=2) + '\n', encoding='utf-8')
    # Source documentation contains paths from the old checkout; retained as immutable evidence.
    for folder in ['assets/actors/source', 'assets/ui/coastal/source']:
        (ROOT / folder / '.gdignore').write_text('', encoding='utf-8')
    print(f'Copied {len(entries)} verified art/provenance files')


if __name__ == '__main__':
    main()
