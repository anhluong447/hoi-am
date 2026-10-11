"""Text-free paper/ink correction; retain masters and all earlier authored versions."""
import base64
from pathlib import Path
import random
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent
SVG = '{http://www.w3.org/2000/svg}'
ET.register_namespace('', 'http://www.w3.org/2000/svg')


def wrap(body):
    return f'<svg xmlns="http://www.w3.org/2000/svg" width="1672" height="941" viewBox="0 0 1672 941">{body}</svg>', (1672, 941)


def encoded_image(svg, bounds):
    data = base64.b64encode(svg.encode()).decode()
    x, y, w, h = bounds
    return f'<image href="data:image/svg+xml;base64,{data}" x="{x}" y="{y}" width="{w}" height="{h}"/>'


def documents():
    source = ROOT / 'assets/ui/coastal/source/exports'
    generated = ROOT / 'assets/ui/coastal/generated_sources'
    paper = ET.parse(source / 'dialogue-paper.svg').getroot()
    stops = paper.findall(f'{SVG}defs/{SVG}linearGradient/{SVG}stop')
    stops[0].set('stop-color', '#fffaf3')
    stops[1].set('stop-color', '#f6ecdf')
    for rect in paper.findall(f'{SVG}g/{SVG}rect'):
        rect.set('opacity', '.035')
    paper_body = encoded_image(ET.tostring(paper, encoding='unicode'), [0, 599, 1672, 342])
    print_layer = ET.parse(generated / 'print.svg').getroot()
    print_layer.findall(SVG + 'g')[0].set('opacity', '.58')
    # Broken wash inside the right-hand paper edge, separate from scene/portraits.
    defs = print_layer.find(SVG + 'defs')
    gradient = ET.SubElement(defs, SVG + 'linearGradient', {'id': 'edge-fade'})
    for offset, opacity in [('0', '0'), ('.55', '.2'), ('1', '.7')]:
        ET.SubElement(gradient, SVG + 'stop', {'offset': offset, 'stop-color': 'white', 'stop-opacity': opacity})
    mask = ET.SubElement(defs, SVG + 'mask', {'id': 'edge-wash'})
    ET.SubElement(mask, SVG + 'path', {'d': 'M1060 733Q1260 738 1485 783L1460 877Q1370 853 1260 789Q1160 758 1060 744Z', 'fill': 'url(#edge-fade)'})
    brush = ET.SubElement(print_layer, SVG + 'g', {'mask': 'url(#edge-wash)'})
    rng = random.Random(411)
    for _ in range(1100):
        x, y = rng.uniform(1050, 1490), rng.uniform(730, 880)
        ET.SubElement(brush, SVG + 'ellipse', {'cx': f'{x:.2f}', 'cy': f'{y:.2f}', 'rx': f'{rng.uniform(.6, 6):.2f}', 'ry': f'{rng.uniform(.5, 2.5):.2f}', 'fill': '#4e99a0', 'opacity': f'{rng.uniform(.3, .8):.2f}'})
    # Date card contour/rules follow its sloped lower edge; ornament remains original.
    date_defs = '''<linearGradient id="paper" x2=".8" y2="1"><stop stop-color="#fff9ed"/><stop offset="1" stop-color="#f3e9d7"/></linearGradient>
<filter id="grain"><feTurbulence type="fractalNoise" baseFrequency=".38 .52" numOctaves="3" seed="41"/><feColorMatrix type="saturate" values="0"/></filter>'''
    contour = 'M38 30L91 29L146 27L209 29L278 25L281 34L279 78L281 110Q280 120 271 121L43 143L36 137L38 113L35 93L38 64L35 43Z'
    date_defs += f'<clipPath id="date"><path d="{contour}"/></clipPath>'
    card = f'<defs>{date_defs}</defs><g clip-path="url(#date)"><path d="{contour}" fill="url(#paper)"/><rect x="35" y="25" width="247" height="120" filter="url(#grain)" opacity=".045"/></g>'
    card += '<path d="M110 46L115 119M120 82L260 78" fill="none" stroke="#7b8071" stroke-width=".8" opacity=".6"/>'
    card += encoded_image((source / 'sun-seal.svg').read_text(encoding='utf-8'), [48, 40, 87, 127])
    for _ in range(100):
        x, y = rng.uniform(37, 280), rng.uniform(26, 143)
        # Tiny fiber flecks only, not readable marks or a concept bitmap.
        card += f'<circle cx="{x:.2f}" cy="{y:.2f}" r="{rng.uniform(.2, .7):.2f}" fill="#9b9277" opacity=".17" clip-path="url(#date)"/>'
    hud = ET.parse(ROOT / 'assets/ui/coastal/authored_v3/hud-frame.svg').getroot()
    for y in [195, 203, 211, 219, 227]:
        ET.SubElement(hud, SVG + 'circle', {'cx': '40', 'cy': str(y), 'r': '1.8', 'fill': '#164955'})
    # Break the date edge into small irregular fibers rather than repeated zigzags.
    date = hud.find(f'{SVG}defs/{SVG}clipPath[@id="date"]/{SVG}path')
    edge = 'M32 32L80 30L151 33L231 30L344 33'
    for y in range(34, 133, 2):
        x = 344 - (y - 34) * .13 + rng.uniform(-2.8, 2.8)
        edge += f'L{x:.2f} {y}'
    date.set('d', edge + 'L32 135L30 126L32 93L29 70L31 43Z')
    return {'paper': wrap(paper_body), 'print': (ET.tostring(print_layer, encoding='unicode'), (1672, 941)),
            'date': wrap(card), 'hud-frame': (ET.tostring(hud, encoding='unicode'), (1672, 941))}
