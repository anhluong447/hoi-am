"""Capture source packs/oracles without writing to the reference checkout."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parent.parent


def write(relative, value):
    path = ROOT / relative
    if path.exists():
        raise SystemExit(f'Refusing to overwrite evidence: {relative}')
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', required=True, type=Path)
    source = parser.parse_args().source.resolve()
    if source == ROOT or not (source / 'src/domain/session.js').is_file():
        raise SystemExit('Expected separate reference checkout')
    before = subprocess.check_output(['git', '-C', str(source), 'status', '--porcelain'])
    packs, traces = [json.loads(subprocess.check_output(
        ['node', str(ROOT / 'tools/export_migration.mjs'), str(source), mode],
        encoding='utf-8', timeout=60)) for mode in ['packs', 'oracles']]
    write('content/gameplay/pack.json', packs['gameplay'])
    write('content/dialogue/graphs.json', {'schema_version': 1, 'scenes': packs['dialogue']})
    write('content/world/source_maps.json', {'schema_version': 1, 'rooms': packs['maps']})
    for trace in traces:
        write(f"tests/fixtures/parity/{trace['id']}.json", trace)
    inputs = list((source / 'content/gameplay').glob('*.js'))
    inputs += list((source / 'src/domain').glob('*.js'))
    inputs += [source / p for p in ['content/locales/vi.js', 'src/shared/text.js',
                                  'content/maps/definitions.js', 'content/dialogue/interaction-scenes.js']]
    outputs = ['content/gameplay/pack.json', 'content/dialogue/graphs.json', 'content/world/source_maps.json']
    outputs += [f"tests/fixtures/parity/{t['id']}.json" for t in traces]
    digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    manifest = {
        'schema_version': 1, 'source_commit': subprocess.check_output(
            ['git', '-C', str(source), 'rev-parse', 'HEAD'], text=True).strip(),
        'source_clean': not before.strip(), 'capture_tool': 'tools/export_migration.mjs',
        'numeric_tolerance': 1e-8, 'array_order': 'exact; including logs and events',
        'inputs': [{'path': str(p.relative_to(source)).replace('\\', '/'), 'sha256': digest(p)} for p in inputs],
        'outputs': [{'path': p, 'sha256': digest(ROOT / p)} for p in outputs],
        'traces': [{'id': t['id'], 'scope': t['scope'], 'steps': len(t['steps'])} for t in traces],
    }
    if subprocess.check_output(['git', '-C', str(source), 'status', '--porcelain']) != before:
        raise SystemExit('Reference checkout changed during capture')
    write('docs/migration/oracle-manifest.json', manifest)
    print(f"Captured {len(outputs)} packs/traces; source unchanged")


if __name__ == '__main__':
    main()
