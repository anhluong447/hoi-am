"""Compile text-free SVG art with Chromium filters; runtime needs only PNG assets."""
import argparse
import base64
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import time
import urllib.request
import xml.etree.ElementTree as ET
from browser_cdp import DevTools

ET.register_namespace('', 'http://www.w3.org/2000/svg')

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / 'assets/ui/coastal/source'
OUT = ROOT / 'assets/ui/coastal/runtime'


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def documents():
    spec = read(ROOT / 'docs/reference/art/coastal-dialogue-ui.json')
    manifest = read(SOURCE / 'manifest.json')
    assets = {a['id']: a for a in manifest['assets']}
    def image(id, bounds, item=None):
        item = item or {}
        asset = assets[id]; path = SOURCE / 'exports' / Path(asset['file']).name
        mime = 'image/svg+xml' if path.suffix == '.svg' else 'image/png'
        data = base64.b64encode(path.read_bytes()).decode()
        x, y, w, h = bounds
        if 'sourceRect' in item:
            view = ' '.join(map(str, item['sourceRect']))
            return f'<svg x="{x}" y="{y}" width="{w}" height="{h}" viewBox="{view}" preserveAspectRatio="xMidYMin slice" overflow="hidden"><image href="data:{mime};base64,{data}" width="{asset["size"][0]}" height="{asset["size"][1]}"/></svg>'
        return f'<image href="data:{mime};base64,{data}" x="{x}" y="{y}" width="{w}" height="{h}" preserveAspectRatio="none"/>'
    contour = manifest['paperContour']
    defs = f'<clipPath id="paper"><path d="{contour}" transform="translate(0 599)"/></clipPath>'
    for name, profile in spec['lighting']['shadows'].items():
        defs += f'<filter id="shadow-{name}" x="-20%" y="-40%" width="140%" height="180%" color-interpolation-filters="sRGB"><feDropShadow dx="{profile["dx"]}" dy="{profile["dy"]}" stdDeviation="{profile["blur"]}" flood-color="{profile["color"]}" flood-opacity="{profile["opacity"]}"/></filter>'
    def svg(body, size=(1672, 941)):
        w,h=size
        result=f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}"><defs>{defs}</defs>{body}</svg>'
        assert '<text' not in result, 'Art must never bake text'
        return result,size
    layers = {'paper': f'<g filter="url(#shadow-paper)">{image("material.dialogue-paper", spec["paperBounds"])}</g>',
              'wave': image('material.dialogue-wave', spec['paperBounds']), 'print':'', 'flowers':'', 'notebook':'', 'date':''}
    for item in spec['art']:
        if item.get('optionalLogo'): continue
        if item['id'].startswith('date-'): layer='date'
        elif item['id']=='foreground-left': layer='flowers'
        elif item.get('component')=='notebook': layer='notebook'
        else: layer='print'
        group=image(item['asset'],item['bounds'],item)
        attrs=f'opacity="{item.get("opacity",1)}" transform="{item.get("transform", "")}"'
        if item.get('clip'): attrs+=' clip-path="url(#paper)"'
        if item.get('shadow'): attrs+=f' filter="url(#shadow-{item["shadow"]})"'
        layers[layer]+=f'<g {attrs}>{group}</g>'
    layers['notebook']=f'<g filter="url(#shadow-notebook)">{layers["notebook"]}</g>'
    for rule in spec['rules']:
        layers['print']+=f'<line x1="{rule["x1"]}" y1="{rule["y1"]}" x2="{rule["x2"]}" y2="{rule["y2"]}" stroke="{rule.get("stroke", "#126477")}" stroke-width="{rule.get("width",1.25)}"/>'
    arrow=spec['speakerArrow']
    layers['print']+=f'<path d="M{arrow["x1"]} {arrow["y1"]}H{arrow["x2"]}l-4 -2m4 2l-4 2" fill="none" stroke="#126477" stroke-width="1.25"/>'
    output={k:svg(v) for k,v in layers.items()}
    for id in ['choice-gold','choice-plain','date-paper','sun-seal']:
        asset=assets['material.'+id]
        output[id]=svg(image('material.'+id,[0,0,*asset['size']]),tuple(asset['size']))
    icons=ET.parse(SOURCE / 'exports/icons.svg').getroot()
    for symbol in icons.find('{http://www.w3.org/2000/svg}defs'):
        id=symbol.attrib['id']; body=ET.tostring(symbol,encoding='unicode')
        output['icon-'+id]=svg(f'<defs>{body}</defs><use href="#{id}" width="32" height="32"/>',(32,32))
    return output


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--browser',default=r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe')
    parser.add_argument('--version', type=int, choices=[1, 2, 3], default=1)
    args=parser.parse_args()
    out = OUT if args.version == 1 else ROOT / f'assets/ui/coastal/runtime_v{args.version}'
    authored=ROOT / ('assets/ui/coastal/generated_sources' if args.version == 1 else f'assets/ui/coastal/authored_v{args.version}')
    if args.version > 1 and (out.exists() or authored.exists()):
        raise SystemExit('Preserve versioned art; choose a new authored version instead of overwriting')
    out.mkdir(parents=True,exist_ok=True)
    authored.mkdir(exist_ok=True)
    (authored / '.gdignore').write_text('',encoding='utf-8')
    docs = documents()
    if args.version == 2:
        from coastal_v2_art import documents as version_two
        docs = version_two()
    elif args.version == 3:
        from coastal_v3_art import documents as version_three
        docs = version_three()
    with tempfile.TemporaryDirectory(prefix='hoi-am-ui-bake-',ignore_cleanup_errors=True) as profile:
        process=subprocess.Popen([args.browser,'--headless=new','--disable-gpu','--no-first-run',
                                  '--remote-debugging-port=0',f'--user-data-dir={profile}','about:blank'],
                                 stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL,creationflags=subprocess.CREATE_NO_WINDOW)
        client=None
        try:
            port_file=Path(profile)/'DevToolsActivePort'; deadline=time.monotonic()+20
            while not port_file.is_file():
                if time.monotonic()>deadline: raise RuntimeError('Browser did not start')
                time.sleep(.05)
            port=int(port_file.read_text().splitlines()[0])
            with urllib.request.urlopen(f'http://127.0.0.1:{port}/json/list') as response: pages=json.load(response)
            client=DevTools(next(p['webSocketDebuggerUrl'] for p in pages if p['type']=='page'))
            client.call('Page.enable')
            client.call('Emulation.setDefaultBackgroundColorOverride',{'color':{'r':0,'g':0,'b':0,'a':0}})
            outputs=[]
            for name,(svg,(w,h)) in docs.items():
                source=authored/f'{name}.svg'; source.write_text(svg,encoding='utf-8')
                client.call('Emulation.setDeviceMetricsOverride',{'width':w,'height':h,'deviceScaleFactor':1,'mobile':False})
                markup='<style>html,body{margin:0;background:transparent;overflow:hidden}</style>'+svg
                client.call('Page.setDocumentContent',{'frameId':client.call('Page.getFrameTree')['frameTree']['frame']['id'],'html':markup})
                client.evaluate('Promise.all(Array.from(document.querySelectorAll("image")).map(i=>new Promise((resolve,reject)=>{let v=new Image();v.onload=resolve;v.onerror=reject;v.src=i.getAttribute("href")})))',True)
                image=client.call('Page.captureScreenshot',{'format':'png','clip':{'x':0,'y':0,'width':w,'height':h,'scale':1},'captureBeyondViewport':True})
                target=out/f'{name}.png'; target.write_bytes(base64.b64decode(image['data']))
                outputs.append({'id':name,'texture_path':'res://'+target.relative_to(ROOT).as_posix(),
                                'size':[w,h],'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),
                                'source_path':'res://'+source.relative_to(ROOT).as_posix(),
                                'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest()})
            manifest = 'art_manifest.json' if args.version == 1 else f'art_manifest_v{args.version}.json'
            if args.version > 1:
                previous = 'art_manifest.json' if args.version == 2 else f'art_manifest_v{args.version - 1}.json'
                replaced = {item['id'] for item in outputs}
                outputs = [item for item in read(ROOT/'content/ui'/previous)['assets'] if item['id'] not in replaced] + outputs
            (ROOT/'content/ui'/manifest).write_text(json.dumps({'version':args.version,'text_policy':'art-only; live catalog text','assets':outputs},indent=2)+'\n',encoding='utf-8')
            print(f'Baked {len(outputs)} independent text-free UI assets')
        finally:
            if client: client.socket.close()
            if process.poll() is None: process.terminate(); process.wait(timeout=10)


if __name__=='__main__': main()
