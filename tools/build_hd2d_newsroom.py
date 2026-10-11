"""Author the first complete newsroom pack; never overwrite a selected pack."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def write(path, data):
    target = ROOT / path
    assert not target.exists(), f'Preserve existing authored version: {path}'
    target.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')


def prop(id, asset, position, size, **extra):
    return {'id': id, 'position': position, 'layers': [{'asset': asset, 'size': size, **extra}]}


def surface(id, asset, position, size, rotation=None, repeat=None, **extra):
    return {'id': id, 'asset': asset, 'position': position, 'size': size,
            'rotation': rotation or [0, 0, 0], 'repeat': repeat or [1, 1], **extra}


def build():
    config = json.loads((ROOT / 'content/world/newsroom_hd2d_corner.json').read_text())
    config.update(id='newsroom_hd2d_v1', visuals_path='res://content/world/visuals/newsroom_v1.json',
                  world_font_path='res://assets/fonts/source_serif_4/source-serif-4.ttf')
    config['camera']['orthographic']['size'] = 8.0
    for geometry in config['geometry']:
        geometry['visible'] = False
        if geometry['id'].startswith('front-') or geometry['id'].startswith('door-'):
            geometry['shadow'] = False
        if geometry['id'] == 'window-left': geometry.update(position=[-5.5, 2.1, -4.5], size=[1, 1.8, 0.22])
        if geometry['id'] == 'window-middle': geometry.update(position=[0, 2.1, -4.5], size=[4, 1.8, 0.22])
        if geometry['id'] == 'window-right': geometry.update(position=[5.5, 2.1, -4.5], size=[1, 1.8, 0.22])
    surfaces = [surface('floor-art', 'oak', [0, 0.012, 0], [15, 12], [-90, 0, 0], [4, 3], swap_axes=True)]
    walls = [('wall-base', [0, 0.6, -4.37], [15, 1.2]),
             ('wall-top', [0, 3.55, -4.37], [15, 1.1]),
             ('wall-left', [-6.25, 2.1, -4.37], [2.5, 1.8]),
             ('wall-middle', [0, 2.1, -4.37], [4, 1.8]),
             ('wall-right', [6.25, 2.1, -4.37], [2.5, 1.8])]
    surfaces += [surface(id, 'plaster', position, size, repeat=[size[0]/2, size[1]/2],
                         tint='#e0d5be', ink_strength=0.45) for id, position, size in walls]
    surfaces += [surface('wainscot', 'teal-wood', [0, 0.48, -4.32], [15, 0.96], repeat=[5, 1], ink_strength=0.8)]
    props = []
    for id, x, z, width in [('writing', -1, -0.6, 3.2), ('van', 3.1, -2.4, 2.1),
                           ('rear', -1.5, -3.1, 2.2), ('front', -3.1, 2.35, 3.0)]:
        props.append(prop(id+'-desk-art', 'desk', [x, 0, z+0.3], [width, 1.15]))
        props.append(prop(id+'-papers-art', 'papers', [x+0.45, 0.9, z+0.25], [0.52, 0.32]))
        props.append(prop(id+'-lamp-art', 'lamp', [x-width*0.29, 0.88, z+0.18], [0.42, 0.52]))
        props.append(prop(id+'-books-art', 'books', [x+0.1, 0.9, z+0.27], [0.52, 0.35]))
        if id in ['rear', 'front']:
            config['geometry'].append({'id':id+'-desk-collider','position':[x,0.4,z],
                                       'size':[width,0.8,1.15],'color':'#000000','visible':False})
    for id, asset, position, size in [
        ('archive-art','cabinet',[-4.7,0,-3.5],[1.6,2.2]),
        ('archive-shelf-art','bookshelf',[-3.15,0,-3.7],[1.5,2.3]),
        ('right-shelf-art','bookshelf',[5.05,0,-3.7],[1.6,2.4]),
        ('printer-art','printer',[4.5,0.7,-3.4],[0.9,0.7]),
        ('board-art','board',[-4.7,1.15,-3.2],[1.45,0.85]),
        ('brand-board-art','board',[0,1.35,-4.2],[2.7,1.45]),
        ('clock-art','clock',[1.65,2.55,-4.1],[0.62,0.62]),
        ('window-left-art','window',[-3.5,1.03,-4.17],[3.2,2.25]),
        ('window-right-art','window',[3.5,1.03,-4.17],[3.2,2.25]),
        ('left-plant-art','plant',[-5.3,0,0.6],[1.2,1.65]),
        ('right-plant-art','plant',[5,0,2.9],[1.3,1.7]),
        ('window-flowers-left','flowers',[-3.5,1.0,-4.05],[0.75,0.8]),
        ('window-flowers-right','plant',[3.5,1.0,-4.05],[0.8,0.8]),
        ('front-flowers','flowers',[-5.8,0,4.6],[2.1,2.3]),
        ('front-plant','plant',[5.8,0,4.65],[2.5,2.6]),
    ]: props.append(prop(id,asset,position,size))
    for id, y, z, size in [('mountains',-7,-17,[22,3.9]),('town',-3.6,-11,[20,3.6]),('quay',-2.5,-8,[18,2.8])]:
        props.append(prop('harbor-'+id,id,[0,y,z],size,shaded=False))
    for target in config['targets']:
        if target['id'] == 'assignment-board':
            target.update(position=[-4.7,0,-2.6], anchor=[-4.7,1.8,-3.1])
    config['geometry'] += [{'id':id,'position':position,'size':size,'color':'#000000','visible':False}
                          for id,position,size in [('right-shelf-collider',[5.05,1,-3.7],[1.6,2,0.7]),
                                                   ('left-shelf-collider',[-3.15,1,-3.7],[1.5,2,0.7]),
                                                   ('left-plant-collider',[-5.3,0.4,0.6],[0.65,0.8,0.65])]]
    labels = [
        {'id':'club-sign','text_key':'world.newsroom.sign','position':[0,2.35,-4.12],
         'font_size':52,'pixel_size':0.0048,'color':'#153d47'},
        {'id':'club-motto','text_key':'world.newsroom.motto','position':[0,1.8,-4.11],
         'font_size':28,'pixel_size':0.0065,'color':'#245766'},
    ]
    write('content/world/visuals/newsroom_v1.json', {'surfaces':surfaces,'props':props,'labels':labels})
    write('content/world/newsroom_hd2d_v1.json',config)
    print(f'Authored newsroom: {len(props)} prop groups; {len(surfaces)} surfaces; 2 catalog labels')


if __name__ == '__main__':
    build()
