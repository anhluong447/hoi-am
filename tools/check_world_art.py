"""Verify immutable world source/runtime bytes and authored region references."""
import hashlib
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def validate():
    manifests = sorted((ROOT / 'content/world').glob('art_manifest_v*.json'))
    for path in manifests:
        manifest = json.loads(path.read_text(encoding='utf-8'))
        atlases = {}
        for atlas in manifest['atlases']:
            assert atlas['id'] not in atlases
            atlases[atlas['id']] = atlas
            for field, digest in [('texture_path', 'sha256'), ('source_path', 'source_sha256')]:
                data = (ROOT / atlas[field][6:]).read_bytes()
                assert hashlib.sha256(data).hexdigest() == atlas[digest], atlas[field]
                assert list(struct.unpack('>II', data[16:24])) == atlas['size']
        assets = set()
        for asset in manifest['assets']:
            assert asset['id'] not in assets
            assets.add(asset['id'])
            x, y, width, height = asset['region']
            size = atlases[asset['atlas']]['size']
            assert min(x, y) >= 0 and min(width, height) > 0
            assert x + width <= size[0] and y + height <= size[1]
    print(f'World art check: {len(manifests)} versioned manifests; source/runtime hashes intact')


if __name__ == '__main__':
    validate()
