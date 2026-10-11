"""Restore the original date envelope after the v4 region diagnostic regressed."""
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parent.parent
SVG = '{http://www.w3.org/2000/svg}'
ET.register_namespace('', 'http://www.w3.org/2000/svg')


def documents():
    date = ET.parse(ROOT / 'assets/ui/coastal/generated_sources/date.svg').getroot()
    ET.SubElement(date, SVG + 'path', {'d': 'M110 46L115 119M120 82L260 78',
                                     'fill': 'none', 'stroke': '#7b8071', 'stroke-width': '.8', 'opacity': '.6'})
    return {'date': (ET.tostring(date, encoding='unicode'), (1672, 941))}
