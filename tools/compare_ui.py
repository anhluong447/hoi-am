"""Read-only RGB comparison inside the source's conservative UI mask; not an art gate."""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import zlib

ROOT = Path(__file__).resolve().parent.parent


def png(path):
    data = path.read_bytes(); assert data[:8] == b'\x89PNG\r\n\x1a\n'
    offset, compressed = 8, bytearray()
    while offset < len(data):
        length = struct.unpack('>I', data[offset:offset + 4])[0]
        kind = data[offset + 4:offset + 8]; body = data[offset + 8:offset + 8 + length]
        crc = struct.unpack('>I', data[offset + 8 + length:offset + 12 + length])[0]
        assert zlib.crc32(kind + body) & 0xffffffff == crc, 'PNG CRC mismatch'
        if kind == b'IHDR': width, height, depth, color, _, _, interlace = struct.unpack('>IIBBBBB', body)
        if kind == b'IDAT': compressed.extend(body)
        offset += 12 + length
    assert depth == 8 and color in (2, 6) and interlace == 0, 'Expected RGB/RGBA8 noninterlaced PNG'
    channels = 4 if color == 6 else 3; stride = width * channels
    raw = zlib.decompress(compressed); pixels = bytearray(stride * height)
    assert len(raw) == (stride + 1) * height
    for y in range(height):
        filter = raw[y * (stride + 1)]; row = bytearray(raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)])
        previous = pixels[(y - 1) * stride:y * stride] if y else bytearray(stride)
        if filter:
            for i in range(stride):
                a = row[i - channels] if i >= channels else 0; b = previous[i]
                c = previous[i - channels] if i >= channels else 0
                if filter == 1: predictor = a
                elif filter == 2: predictor = b
                elif filter == 3: predictor = (a + b) // 2
                elif filter == 4:
                    p = a + b - c; distances = (abs(p - a), abs(p - b), abs(p - c))
                    predictor = (a, b, c)[distances.index(min(distances))]
                else: raise ValueError('Unsupported PNG filter')
                row[i] = (row[i] + predictor) & 255
        pixels[y * stride:(y + 1) * stride] = row
    return width, height, channels, pixels


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--mask', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists(): raise SystemExit('Refusing to overwrite historical comparison')
    reference = ROOT / 'docs/reference/coastal-editorial-v1/01-dialogue.png'
    ref, candidate, mask = png(reference), png(args.candidate), png(args.mask)
    assert ref[:2] == candidate[:2] == mask[:2] == (1672, 941)
    count, error, maximum = 0, 0, 0
    for pixel in range(1672 * 941):
        m = pixel * mask[2]
        included = mask[3][m] > 127 and (mask[2] != 4 or mask[3][m + 3] > 127)
        if not included: continue
        count += 1
        for channel in range(3):
            delta = abs(ref[3][pixel * ref[2] + channel] - candidate[3][pixel * candidate[2] + channel])
            error += delta; maximum = max(maximum, delta)
    assert count > 0
    digest = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
    report = {'schema_version': 1, 'plane': [1672, 941], 'mask_kind': 'conservative source interior; fringe/occluded alpha unresolved',
              'reference_sha256': digest(reference), 'candidate_sha256': digest(args.candidate), 'mask_sha256': digest(args.mask),
              'included_pixels': count, 'rgb_mae_0_255': error / (count * 3), 'max_channel_error': maximum,
              'acceptance': 'diagnostic only; G2 remains open; no full-frame or zero-diff claim'}
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(f"Conservative UI comparison: {count} pixels; RGB MAE {report['rgb_mae_0_255']:.3f}; G2 remains open")


if __name__ == '__main__': main()
