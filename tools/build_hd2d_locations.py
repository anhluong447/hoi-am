"""Concrete coastal room authoring recipe; refuse to overwrite reviewed versions."""
import copy
import json
from pathlib import Path
from build_hd2d_newsroom import prop, surface, write

ROOT = Path(__file__).resolve().parent.parent


def proxy(id, position, size, shadow=True, collision=True):
    return {'id': id, 'position': position, 'size': size, 'color': '#bda078',
            'visible': False, 'shadow': shadow, 'collision': collision}


def furniture(visual, geometry, id, asset, x, z, width, height, depth=.8):
    visual['props'].append(prop(id + '-art', asset, [x, 0, z], [width, height]))
    geometry.append(proxy(id, [x, min(height, 1.2)/2, z - depth/2],
                          [width*.8, min(height, 1.2), depth]))


def plant(visual, geometry, id, x, z, width=1.1, height=1.5, asset='plant', phase=0):
    item = prop(id + '-art', asset, [x, 0, z], [width, height])
    item['idle'] = {'degrees': .35, 'period': 7.1 + phase*.2, 'phase': phase}
    visual['props'].append(item)
    geometry.append(proxy(id, [x, .25, z-.15], [.5, .5, .5], shadow=False))


def desk(visual, geometry, id, x, z, width=2.6):
    furniture(visual, geometry, id, 'desk', x, z, width, 1.15, 1.25)
    visual['props'].append(prop(id+'-papers', 'papers', [x+.3, .91, z-.04], [.5, .3]))
    visual['props'].append(prop(id+'-lamp', 'lamp', [x-width*.3, .91, z-.12], [.42, .5]))


def harbor(visual, outdoors=False):
    layers = [('mountains', -7, -17, 24, 4), ('town', -3.6, -11, 22, 3.6),
              ('quay', -2.5, -8, 20, 2.8)]
    if outdoors:
        layers = [('mountains', -12.5, -24, 35, 5.3), ('town', -7, -17, 30, 4.0),
                  ('quay', -2.4, -10, 27, 3.2)]
    for asset, y, z, width, height in layers:
        visual['props'].append(prop('harbor-'+asset, asset, [0, y, z], [width, height], shaded=False, mipmaps=False))


def indoor(name, floor, tint):
    base = json.loads((ROOT/'content/world/newsroom_hd2d_v1.json').read_text())
    old = json.loads((ROOT/f'content/world/{name}.json').read_text())
    for field in ['title_key', 'npcs', 'targets', 'portal']:
        base[field] = copy.deepcopy(old[field])
    base.update(id=name+'_hd2d_v1', legacy_room_ids=[name],
                visuals_path=f'res://content/world/visuals/{name}_v1.json',
                world_art_path='res://content/world/art_manifest_v3.json')
    shell = [item for item in base['geometry'] if item['id'] in
             ['floor', 'back-base', 'back-top', 'window-left', 'window-middle', 'window-right',
              'left-wall', 'right-cutaway', 'front-left', 'front-right', 'door-left', 'door-right', 'door-lintel']]
    base['geometry'] = shell
    newsroom = json.loads((ROOT/'content/world/visuals/newsroom_v1.json').read_text())
    visual = {'version': 1, 'surfaces': copy.deepcopy(newsroom['surfaces']), 'props': [], 'labels': []}
    visual['surfaces'][0].update(asset=floor, tint=tint, repeat=[4,3], swap_axes=floor == 'oak')
    visual['props'] += [copy.deepcopy(item) for item in newsroom['props'] if item['id'].startswith('window-')]
    harbor(visual)
    visual['props'].append(prop('calendar-art', 'clock', [1.5, 2.3, -4.1], [.6,.6]))
    base['targets'][1].update(position=[1.5,0,-2.9], anchor=[1.5,2.6,-4.02],
                              label_key='world.target.calendar', radius=1.2)
    base['targets'][0]['label_key'] = 'world.target.notes'
    plant(visual, shell, 'foreground-left', -5.6, 4.6, 1.9, 2.2, 'flowers', 1)
    plant(visual, shell, 'foreground-right', 5.7, 4.65, 2.1, 2.3, phase=3)
    visual['props'].append(prop('title-board', 'board', [0,1.4,-4.15], [2.8,1.35]))
    visual['labels'].append({'id':'location-sign', 'text_key':base['title_key'],
        'position':[0,2.05,-4.05], 'font_size':38, 'pixel_size':.0045, 'color':'#153d47'})
    return base, visual


def library():
    config, visual = indoor('library', 'oak', '#d6e1d8')
    geometry = config['geometry']
    for index, x in enumerate([-5.0,-3.45,3.45,5.0]):
        furniture(visual, geometry, f'bookcase-{index}', 'bookshelf', x, -3.55, 1.45, 2.7)
    desk(visual, geometry, 'reading-desk', -1, -.3, 3.2)
    desk(visual, geometry, 'quiet-desk', -3.5, 2.35, 2.4)
    furniture(visual, geometry, 'reading-sofa', 'sofa', 3.5, .2, 3.0, 1.5, 1.1)
    visual['props'].append(prop('reading-books', 'books', [-.7,.92,-.32], [.55,.4]))
    plant(visual, geometry, 'quiet-plant', 5.1, 2.7, phase=2)
    config['ambient'].update(color='#b4d0df', energy=.7)
    return config, visual


def cafe():
    config, visual = indoor('cafe', 'terracotta', '#ead4b5')
    geometry = config['geometry']
    for index, x in enumerate([-3.1,2.5]):
        furniture(visual, geometry, f'cafe-table-{index}', 'cafe-table', x, -.9, 2.2, 1.6, 1.0)
        visual['props'].append(prop(f'cafe-chair-{index}', 'chair', [x+.9,0,-1.15], [.7,1.2]))
    furniture(visual, geometry, 'service-counter', 'counter', 0, -3.2, 3.4, 1.45, 1.1)
    furniture(visual, geometry, 'cafe-sofa', 'sofa', -3.8, 2.5, 3.0, 1.6, 1.05)
    visual['props'].append(prop('hanging-light', 'pendant', [0,2.7,-2.5], [.7,1.0]))
    config['targets'][0].update(position=[-3.1,0,.3], anchor=[-3.1,1.4,-.82])
    config['local_lights']=[{'position':[0,2.4,-2.5], 'color':'#ffce94','energy':.5,'range':5}]
    config['sun']['energy']=1.3
    plant(visual, geometry, 'cafe-flowers', 4.6, 2.7, asset='flowers', phase=2)
    return config, visual


def home():
    config, visual = indoor('home', 'oak', '#e7d7c1')
    geometry = config['geometry']
    furniture(visual, geometry, 'bed', 'bed', 3.6, -2.1, 2.1, 2.6, 2.0)
    furniture(visual, geometry, 'sofa', 'sofa', 0, -2.8, 2.8, 1.5, 1.0)
    desk(visual, geometry, 'home-desk', -3.2, -.65, 2.5)
    config['targets'][0].update(position=[-3.2,0,.5], anchor=[-3.2,1.15,-.55])
    visual['props'].append(prop('home-laptop', 'laptop', [-2.8,.91,-.69], [.7,.5]))
    visual['props'].append(prop('home-painting', 'painting', [0,1.7,-4.08], [1.75,1.3]))
    visual['props'].append(prop('home-rug', 'flowers', [4.8,0,2.6], [.8,1.0]))
    furniture(visual, geometry, 'home-shelf', 'bookshelf', -5, -3.5, 1.25, 2.1)
    config['sun'].update(color='#ffc58a', energy=1.25)
    config['ambient'].update(color='#b9c4d2', energy=.7)
    config['local_lights']=[{'position':[-3,2,-.8], 'color':'#ffcd9d','energy':.4,'range':3}]
    return config, visual


def shop():
    config, visual = indoor('shop', 'terracotta', '#d4d9bf')
    geometry = config['geometry']
    furniture(visual, geometry, 'shop-counter', 'counter', -.5, -.5, 4.1, 1.6, 1.0)
    for index, x in enumerate([-4.7,0,4.7]):
        furniture(visual, geometry, f'goods-shelf-{index}', 'jars', x, -3.6, 1.65, 2.6)
    visual['props'].append(prop('shop-awning', 'awning', [0,1.8,-4.12], [3.8,2.0]))
    visual['props'].append(prop('counter-notes', 'papers', [-.6,1.18,-.55], [.6,.35]))
    config['targets'][0].update(position=[-.5,0,.65], anchor=[-.5,1.5,-.42])
    config['targets'][1].update(position=[2.2,0,-2.2], anchor=[2.2,2.6,-4.02])
    for item in visual['props']:
        if item['id']=='calendar-art': item['position'][0]=2.2
    plant(visual, geometry, 'shop-plant', 4.8, 2.7, phase=2)
    return config, visual


def job():
    config, visual = outside("job")
    geometry = config["geometry"]
    for index, x in enumerate([-4.5,4.5]):
        furniture(visual, geometry, f"food-facade-{index}", "warehouse", x, -4.7, 4.3, 3.3, 1.0)
        visual["props"][-1]["layers"][0]["shadow"] = True
        visual["props"].append(prop(f"food-awning-{index}", "awning", [x,1.3,-3.5], [3.9,2.1]))
    furniture(visual,geometry,"service-counter","counter",-3.5,-2.1,3.5,1.5,1.1)
    furniture(visual,geometry,"food-table","cafe-table",3.1,-.7,2.4,1.7,1.0)
    furniture(visual,geometry,"waiting-bench","bench",-3.5,1.4,2.6,1.2,.7)
    visual["props"].append(prop("food-calendar","clock",[6,1.7,-1.68],[.6,.6]))
    visual["props"].append(prop("food-streetlamp","streetlamp",[6,0,-1.8],[.7,3.4]))
    visual["props"].append(prop("food-town","town",[0,-5.7,-15],[30,4],shaded=False,mipmaps=False))
    for index,x in enumerate([-6,6]):
        plant(visual,geometry,f"food-shrub-{index}",x,5.2,2.5,1.1,"shrub",index+1)
    visual["labels"]=[{"id":"food-sign","text_key":config["title_key"],"position":[-4.5,2.55,-3.38],
        "font_size":32,"pixel_size":.005,"color":"#153d47"}]
    config["targets"][0].update(position=[-3.5,0,-.9],anchor=[-3.5,1.5,-2.02],radius=1.3)
    config["targets"][1].update(position=[6,0,-.4],anchor=[6,2.05,-1.6],radius=1.3)
    config["atmosphere"]["water"]["visible"]=False
    config["sun"].update(color="#ffdbad",energy=1.3)
    return config, visual


def outside(name):
    config = json.loads((ROOT/'content/world/newsroom_hd2d_v1.json').read_text())
    old = json.loads((ROOT/f'content/world/{name}.json').read_text())
    for field in ['title_key','npcs','targets','portal']:
        config[field]=copy.deepcopy(old[field])
    config.update(id=name+'_hd2d_v1', legacy_room_ids=[name],
        world_art_path='res://content/world/art_manifest_v3.json',
        visuals_path=f'res://content/world/visuals/{name}_v1.json', spawn=[0,.05,4.2], spawn_bounds=[8.2,6.1])
    config['portal'].update(position=[0,.6,6.25])
    config['camera']['orthographic'].update(position=[0,13,18], target=[0,1.25,-.65], size=12, far=65)
    config['camera']['perspective'].update(position=[0,19,27], target=[0,.8,-.2], fov=22, far=90)
    config['motion']['follow'].update(strength=[.065,.045], maximum=[.35,.22], response=.3)
    config['sun'].update(rotation=[-48,-145,0], energy=1.35, shadow_distance=55)
    config['ambient'].update(color='#c2dce0', energy=.8, background='#8bb5bb')
    config['atmosphere']['dust'].update(count=12, position=[0,1,0], extents=[7,1,3], color='#d6e8c7')
    config['atmosphere']['dof'].update(far_distance=34, near_distance=17, amount=.018)
    config['local_lights']=[]
    geometry=[proxy('floor',[0,-.15,0],[18,.3,14],False),
              proxy('left-bound',[-8.7,1,0],[.2,2,14],False),
              proxy('right-bound',[8.7,1,0],[.2,2,14],False),
              proxy('back-bound',[0,1,-6.8],[18,2,.2],False),
              proxy('front-left',[-5,1,6.8],[7,2,.2],False),
              proxy('front-right',[5,1,6.8],[7,2,.2],False)]
    config['geometry']=geometry
    visual={'version':1,'surfaces':[surface('courtyard','cobble',[0,.012,0],[24,18],[-90,0,0],[5,4],tint='#d9d4bc',ink_strength=.8)],'props':[],'labels':[]}
    config['targets'][0]['label_key']='world.target.notes'
    config['targets'][1]['label_key']='world.target.calendar'
    return config, visual


def school():
    config, visual = outside('school')
    geometry=config['geometry']
    furniture(visual, geometry, 'school-facade','school-house',0,-5,8.6,5.0,1.2)
    visual['props'].append(prop('school-clock','clock',[2.6,2.2,-4.92],[.6,.6]))
    furniture(visual, geometry, 'notice-stand','bulletin',-3.2,-1.8,1.5,2.2,.5)
    furniture(visual, geometry, 'courtyard-bench','bench',3.2,1.4,2.6,1.2,.7)
    for index, x in enumerate([-6.7,6.7]):
        plant(visual,geometry,f'courtyard-tree-{index}',x,-.8,3.4,4.4,'tree',index+1)
    for index, x in enumerate([-6.1,6.1]):
        plant(visual,geometry,f'front-shrub-{index}',x,5.2,2.3,1.0,'shrub',index+3)
    visual['props'].append(prop('school-streetlamp','streetlamp',[5.1,0,-2.9],[.7,3.3]))
    config['targets'][0].update(position=[-3.2,0,-.65],anchor=[-3.2,1.65,-1.73],radius=1.3)
    config['targets'][1].update(position=[2.6,0,-3.6],anchor=[2.6,2.5,-4.85],radius=1.3)
    visual['labels'].append({'id':'school-sign','text_key':config['title_key'],'position':[0,2.5,-4.9],
        'font_size':36,'pixel_size':.005,'color':'#153d47'})
    config['atmosphere']['water'].update(position=[0,-5,-22],size=[34,7],visible=False)
    visual['props'].append(prop('distant-town','town',[0,-6.3,-15],[30,4],shaded=False, mipmaps=False))
    return config, visual


def waterfront():
    config, visual = outside('waterfront')
    geometry=config['geometry']
    geometry[0].update(position=[0,-.15,2.5],size=[18,.3,8])
    geometry[3].update(position=[0,.5,-1.5],size=[18,1,.25])
    visual['surfaces'][0].update(id='quay-stone',asset='stone',position=[0,.012,4],size=[26,11],repeat=[5,3],tint='#e0dac4')
    harbor(visual, True)
    for index, x in enumerate([-6,-3,0,3,6]):
        visual['props'].append(prop(f'quay-rail-{index}','balustrade',[x,0,-1.28],[3.1,1.1]))
    furniture(visual,geometry,'quay-bench','bench',-3,1.2,2.8,1.2,.7)
    visual['props'].append(prop('moored-boat','boat',[-4,-.15,-3.8],[3.7,1.3]))
    visual['props'].append(prop('pier','pier',[4,-.08,-3.3],[4,1.7]))
    visual['props'].append(prop('quay-streetlamp','streetlamp',[4.8,0,-.5],[.8,3.7]))
    visual['props'].append(prop('quay-clock','clock',[4.8,1.75,-.43],[.55,.55]))
    plant(visual,geometry,'left-palm',-7.3,1.8,3.0,4.7,'palm',1)
    plant(visual,geometry,'right-palm',7.3,4.8,3.5,5.0,'palm',3)
    plant(visual,geometry,'front-shrub',-6.5,5.3,2.5,1.2,'shrub',5)
    config['targets'][0].update(position=[-3,0,2.3],anchor=[-3,1.25,1.28],radius=1.3)
    config['targets'][1].update(position=[4.8,0,.65],anchor=[4.8,2.1,-.38],radius=1.3)
    config['atmosphere']['water'].update(position=[0,-.08,-4.75],size=[34,6.5],strength=.005,speed=.55)
    config['sun'].update(color='#ffdba9',rotation=[-42,-140,0])
    return config, visual


def main():
    for name, recipe in [('library',library),('cafe',cafe),('home',home),('shop',shop),
                         ('job',job),('school',school),('waterfront',waterfront)]:
        config, visual = recipe()
        write(f'content/world/{name}_hd2d_v1.json',config)
        write(f'content/world/visuals/{name}_v1.json',visual)
        print(f'{name}: {len(visual["props"])} painted prop groups; preserved target commands')


if __name__ == '__main__':
    main()
