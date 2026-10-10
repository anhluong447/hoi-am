"""Validate concrete gameplay, dialogue, map packs and frozen oracle evidence."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def read(path):
    def unique(pairs):
        result = {}
        for key, value in pairs:
            assert key not in result, f'Duplicate JSON field: {key}'
            result[key] = value
        return result
    return json.loads((ROOT / path).read_text(encoding='utf-8'), object_pairs_hook=unique)


def ids(rows, field='id'):
    result = [row[field] for row in rows]
    assert all(isinstance(x, str) and x for x in result) and len(set(result)) == len(result)
    return set(result)


def main():
    pack = read('content/gameplay/pack.json')
    stats, actors = ids(pack['stats']), ids(pack['roster'])
    ids(pack['cases'], 'key'); ids(pack['quest_steps']); ids(pack['phases']); ids(pack['places'])
    for actor in pack['roster']:
        assert set(actor['stats']) == stats
        assert 1 <= actor['joinDay'] <= pack['balance']['CALENDAR']['maxDays']
        assert all(isinstance(x, (int, float)) and x >= 0 for x in actor['stats'].values())
    for case in pack['cases']:
        assert case['need'] in stats and case['difficulty'] > 0 and case['attraction'] >= 0
    for group in pack['balance'].values():
        assert all(isinstance(x, (float, int)) and x >= 0 for x in group.values())
    defaults = pack['balance']['DEFAULTS']; calendar = pack['balance']['CALENDAR']
    assert calendar['minDays'] <= defaults['days'] <= calendar['maxDays']
    assert defaults['days'] % calendar['daysPerWeek'] == 0
    assert 0 < calendar['schoolDays'] < calendar['daysPerWeek']
    assert defaults['packaging'] <= pack['balance']['LIMITS']['packaging']
    graphs = read('content/dialogue/graphs.json')['scenes']
    speakers = actors | {'groundskeeper', 'teacher', 'harbor-source'}
    for graph in graphs.values():
        nodes = graph['nodes']; assert 'start' in nodes
        for node in nodes.values():
            assert node['speaker'] in speakers
            if 'next' in node: assert node['next'] in nodes
            for choice in node.get('choices', []): assert choice['next'] in nodes
        reached, pending = set(), ['start']
        while pending:
            id = pending.pop()
            if id in reached: continue
            reached.add(id); node = nodes[id]
            pending.extend([node['next']] if 'next' in node else [])
            pending.extend(c['next'] for c in node.get('choices', []))
        assert reached == set(nodes), 'Unreachable dialogue node'
    rooms = read('content/world/source_maps.json')['rooms']
    for room in rooms.values():
        ids(room['objects']); ids(room['npcs'])
        assert len(room['tiles']) == room['height']
        assert all(len(row) == room['width'] for row in room['tiles'])
        for npc in room['npcs']:
            if 'person' in npc: assert npc['person'] in actors
            if 'scene' in npc: assert npc['scene'] in graphs
        for portal in room['portals']:
            assert portal['to'] in rooms
            target = rooms[portal['to']]; spawn = portal['spawn']
            assert 0 <= spawn['x'] < target['width'] and 0 <= spawn['y'] < target['height']
    manifest = read('docs/migration/oracle-manifest.json')
    for item in manifest['outputs']:
        # Captured packs remain frozen during the port; edit by versioned authoring later.
        assert hashlib.sha256((ROOT / item['path']).read_bytes()).hexdigest() == item['sha256'], item['path']
    imports = read('docs/migration/art-import-manifest.json')
    remaining = read('docs/migration/remaining-oracles.json')
    for item in remaining['files']:
        assert hashlib.sha256((ROOT / item['path']).read_bytes()).hexdigest() == item['sha256'], item['path']
    formula = read('content/formula_sandbox/pack.json')
    ids(formula['staff']); ids(formula['subjects']); ids(formula['policies'])
    assert len(formula['policies']) == 8 and len(formula['subjects']) == 96
    locations = read('content/world/locations.json')['locations']
    assert set(locations) == ids(pack['places'])
    for definition in locations.values():
        authored = read(definition['room_path'][6:])
        assert authored['id'] == definition['room_id']
        assert authored['portal']['to'] in locations
        ids(authored['geometry']); ids(authored['targets']); ids(authored['npcs'])
        for camera in authored['camera'].values(): assert 0 < camera['near'] < camera['far']
        assert all(npc['actor_id'] in actors for npc in authored['npcs'])
    for item in imports['files']:
        assert hashlib.sha256((ROOT / item['target']).read_bytes()).hexdigest() == item['sha256'], item['target']
    active_art = read('content/manifest.json')['ui_art_path'][6:]
    art_paths = [p.relative_to(ROOT).as_posix() for p in sorted((ROOT / 'content/ui').glob('art_manifest*.json'))]
    for art_path in [p for p in art_paths if p != active_art] + [active_art]:
        art = read(art_path)
        ids(art['assets'])
        for item in art['assets']:
            target = ROOT / item['texture_path'][6:]
            authored = ROOT / item['source_path'][6:] if 'source_path' in item else ROOT / 'assets/ui/coastal/generated_sources' / (item['id'] + '.svg')
            assert hashlib.sha256(target.read_bytes()).hexdigest() == item['sha256']
            assert hashlib.sha256(authored.read_bytes()).hexdigest() == item['source_sha256']
            assert '<text' not in authored.read_text(encoding='utf-8')
    actors3d = read('content/world/actors.json')['actors']
    for id, actor in actors3d.items():
        assert id in actors and actor['pivot'] == {'x': 16, 'y': 46}
        assert actor['frameWidth'] == 32 and actor['frameHeight'] == 48
        for clip in actor['clips'].values():
            assert len(clip['rows']) == len(actor['directions'])
            assert all(0 <= row < actor['rows'] for row in clip['rows'])
            assert all(0 <= column < actor['columns'] for column in clip['columns'])
    room = read('content/world/newsroom.json')
    ids(room['geometry']); ids(room['targets']); ids(room['npcs'])
    source_targets = {x['id'] for x in rooms['newsroom']['objects'] + rooms['newsroom']['npcs']}
    assert ids(room['targets']) <= source_targets
    assert room['portal']['to'] in rooms and room['speed'] > 0 and room['actor_pixel_size'] > 0
    for preset in room['camera'].values(): assert 0 < preset['near'] < preset['far']
    print(f"Content check: {len(actors)} actors, {len(graphs)} graphs, {len(rooms)} source rooms; oracle hashes intact; {len(imports['files'])} art imports and {len(art['assets'])} runtime textures verified")


if __name__ == '__main__':
    main()
