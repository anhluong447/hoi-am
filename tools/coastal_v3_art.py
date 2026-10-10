"""Refine the retained v2 vector source with smaller tears and seeded ink flecks."""
from pathlib import Path
import random
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent
SVG = '{http://www.w3.org/2000/svg}'
ET.register_namespace('', 'http://www.w3.org/2000/svg')


def documents():
    root = ET.parse(ROOT / 'assets/ui/coastal/authored_v2/hud-frame.svg').getroot()
    defs = root.find(SVG + 'defs')
    paths = root.findall(SVG + 'path')
    paths[0].set('d', 'M0 0H458C446 24 430 57 405 87C389 104 378 122 346 135L346 140C315 153 282 151 249 149H0Z')
    defs.find(f'{SVG}clipPath[@id="date"]/{SVG}path').set('d', 'M32 32L80 30L151 33L231 30L344 33L337 38L344 42L339 46L345 50L337 53L344 57L336 61L341 65L333 68L342 72L335 75L339 79L334 83L341 87L334 90L338 94L332 98L338 102L331 105L338 109L331 113L336 117L330 121L336 125L328 129L329 133L32 135L30 126L32 93L29 70L31 43Z')
    defs.find(f'{SVG}clipPath[@id="ribbon"]/{SVG}path').set('d', 'M1081 82Q1095 63 1105 52L1096 48L1119 34L1137 22Q1220 29 1303 29L1380 32Q1439 29 1505 32L1589 30L1672 39V94Q1590 94 1500 104L1418 104Q1338 117 1280 105Q1210 110 1150 100L1117 96Z')
    for path in paths:
        if path.get('fill') == 'url(#gold)':
            path.set('d', 'M34 186L277 185L269 188L283 191L273 194L291 197L280 200L288 203L275 206L295 209L280 211L287 214L275 216L291 219L280 222L284 225L273 229L34 233Z')
    rng = random.Random(725)
    # Reusable contour masks provide holes only inside the authored ink envelopes.
    for index, original in enumerate(paths[:2]):
        mask = ET.SubElement(defs, SVG + 'mask', {'id': f'ink-{index}', 'maskUnits': 'userSpaceOnUse', 'x': '0', 'y': '0', 'width': '470', 'height': '390'})
        ET.SubElement(mask, SVG + 'path', {'d': original.get('d'), 'fill': 'white'})
        for _ in range(140):
            x = rng.uniform(280, 452) if index == 0 else rng.uniform(238, 326)
            y = rng.uniform(6, 145) if index == 0 else rng.uniform(158, 322)
            ET.SubElement(mask, SVG + 'circle', {'cx': f'{x:.2f}', 'cy': f'{y:.2f}', 'r': f'{rng.uniform(.3, 1.8):.2f}', 'fill': 'black', 'opacity': f'{rng.uniform(.18, .62):.2f}'})
        original.set('mask', f'url(#ink-{index})')
        clip = ET.SubElement(defs, SVG + 'clipPath', {'id': f'ink-grain-{index}'})
        ET.SubElement(clip, SVG + 'path', {'d': original.get('d')})
        grain = ET.Element(SVG + 'rect', {'x': '0', 'y': '0', 'width': '460', 'height': '370', 'filter': 'url(#grain)', 'opacity': '.1', 'clip-path': f'url(#ink-grain-{index})', 'mask': f'url(#ink-{index})'})
        root.insert(list(root).index(original) + 1, grain)
    return {'hud-frame': (ET.tostring(root, encoding='unicode'), (1672, 941))}
