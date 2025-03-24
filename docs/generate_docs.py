# working directory must be the root of the threedee repo
# and lua-language-server.exe must be in PATH

import subprocess
import json
import dataclasses
import re

@dataclasses.dataclass
class LuaField:
    name: str
    type: str
    updatable: str
    desc: str
    default: str

@dataclasses.dataclass
class LuaMethod:
    name: str
    sig: str
    desc: str

def gen_json():
    subprocess.run(['lua-language-server.exe', '--doc', './threedee', '--doc_out_path', '.'], shell=True)

def get_fields(cls, whitelist=None, blacklist=None) -> dict[str, LuaField]:
    ret = {}
    for f in cls['fields']:
        if f['type'] != 'doc.field' or f['visible'] != 'public':
            continue
        name = f['name']
        if (whitelist and name not in whitelist) or \
            (blacklist and name in blacklist) or name[0] == '_':
            continue
        desc = f.get('desc', '')
        m = re.match(r'^(?:\((.)\) )?(.*?)(?: Default: (.*))?$', desc)
        if m:
            updatable, desc, default = m[1] or '', m[2], m[3] or ''
        else:
            updatable, desc, default = '', '', ''
        typ = f['extends']['view'].replace(
            "'xyz'|'xzy'|'yxz'|'yzx'|'zxy'...(+1)",
            "'xyz'|'xzy'|'yxz'|'yzx'|'zxy'|'zyx'",
        )
        field = LuaField(
            name, typ,
            updatable, desc, default
        )
        ret[name] = field
    return ret

MATH_METAMETHODS = {
    '__add', '__sub', '__mul', '__div', '__unm'
}

def get_methods(cls, whitelist=None, blacklist=None) -> dict[str, LuaMethod]:
    ret = {}
    for f in cls['fields']:
        if f['type'] != 'setmethod' or f['visible'] != 'public':
            continue
        name = f['name']
        if (whitelist and name not in whitelist) or \
            (blacklist and name in blacklist) or \
            (name[0] == '_' and name not in MATH_METAMETHODS):
            continue
        # the .split is a bodge for getting rid of some extra desc stuff
        desc = f.get('desc', '').split('```', 1)[0]
        sig = f['extends']['view'].removeprefix('(method) ')
        sig = sig.replace(
            "'xyz'|'xzy'|'yxz'|'yzx'|'zxy'...(+1)",
            "'xyz'|'xzy'|'yxz'|'yzx'|'zxy'|'zyx'",
        )
        sig = sig.replace('\n ', '')
        sig = sig.replace(' 2.', ',').replace(' 3.', ',')
        if not sig.startswith(cls['name']):
            continue
        m = re.match(r'(.*?)\s*-> (.*)$', sig)
        if m:
            sig = m[1] + ': ' + m[2]
        method = LuaMethod(name, sig, desc)
        ret[name] = method
    return ret

UPDATABLE_TO_EMOJI = {
    'U': '✅',
    'C': '⚠️',
    'X': '❌',
    'Y': '❌ (but you may call `:update()` on the object itself)',
    'R': 'R'
}

def std_gen_cls(
    cls, field_whitelist=None, field_blacklist=None, field_inject=None,
    method_blacklist=None, method_whitelist=None, method_inject=None,
    parent=None
):
    fields = get_fields(
        cls, whitelist=field_whitelist, blacklist=field_blacklist
    )
    if field_inject:
        fields.update(field_inject)
    methods = get_methods(
        cls, whitelist=method_whitelist, blacklist=method_blacklist
    )
    if method_inject:
        methods.update(method_inject)
    
    name = cls['name']
    desc = cls['defines'][0].get('desc')
    lines = []
    if parent:
        lines.append(f'## `{name}: {parent}`\n\n')
    else:
        lines.append(f'## `{name}`\n\n')
    if desc:
        lines.append(desc + '\n\n')
    lines.append('### Properties\n\n')
    if parent:
        lines.append(f'See [`{parent}`](#properties) for more properties.\n\n')
    if fields:
        def sort_key(x):
            k = x[0]
            if k[0] == '[':
                n = int(k[1:-1])
                return '[%2d]' % (n,)
            return k
        flist = sorted(
            [(k, v) for k, v in fields.items()],
            key=sort_key
        )
        for _, v in flist:
            lines.append(f'#### `{name}.{v.name}: {v.type}`\n')
            if v.desc:
                lines.append(v.desc + '\n')
            if v.default:
                lines.append(f'- Default value: {v.default}\n')
            emoji = UPDATABLE_TO_EMOJI.get(v.updatable)
            if emoji == 'R':
                lines.append(f'- This property should be treated as **read-only**.\n')
            elif emoji:
                lines.append(f'- Updatable during runtime: {emoji}\n')
            lines.append('\n')
    else:
        lines.append('This class has no properties of its own.\n\n')
    lines.append('### Methods\n\n')
    if parent:
        lines.append(f'See [`{parent}`](#methods) for more methods.\n\n')
    if methods:
        mlist = sorted([(k, v) for k, v in methods.items() if k != 'new'])
        if 'new' in methods:
            mlist.insert(0, ('new', methods['new']))
        for _, v in mlist:
            lines.append(f'#### `{v.sig}`\n')
            if v.desc:
                lines.append(v.desc + '\n')
            lines.append('\n')
    else:
        lines.append('This class has no methods of its own.\n\n')
    return lines

def write_docs(fname, lines_groups):
    with open(fname, encoding='utf-8') as f:
        curr = f.read()
        preamble = curr.split('## ', 1)[0]
    # don't feel like dealing with seek() so we will just write the
    # whole preamble to file again
    with open(fname, 'w', encoding='utf-8') as file:
        file.write(preamble)
        for lines in lines_groups:
            file.writelines(lines)

def get_classes(names):
    with open('doc.json') as f:
        input = json.load(f)
    return {c['name']: c for c in input if c['name'] in names}

def escpipe(s):
    return s.replace('|', '\u200b\\|\u200b')

def gen_material_docs():
    MATERIAL_CLASS_NAMES = {
        'DepthMaterial',
        'MatcapMaterial',
        'NormalMaterial',
        'PhongMaterial',
        'UnlitMaterial',
        'UVMaterial'
    }
    with open('doc.json') as f:
        input = json.load(f)
    materials = [c for c in input if c['name'] in MATERIAL_CLASS_NAMES]
    base_mat_class = [c for c in input if c['name'] == 'Material'][0]
    base_mat_fields = get_fields(base_mat_class)

    lines = [
        '# Built-in Materials\n\n',
        'Remember that all these properties are in addition to the properties provided by the base class.\n\n',
        # 'Emoji meanings:\n',
        # '- ✅: This property is allowed to be modified after scene finalization/during "runtime", via the material\'s `:update()` method.\n'
        # '- ⚠️: This property may only be modified during runtime to a value with the *same type* as the previous value. For example, a `.colorMap` property that was set to a `RageTexture` can only be changed to another `RageTexture`. An `.envMap` property set to an `EnvMap` may only be set to another `EnvMap` with the *same properties* (mapping, color format, etc.), besides perhaps the texture itself. A property set to `false` or `\'sampler0\'` should not be modified during runtime at all.\n',
        # '- ❌: This property should not be modified at runtime.\n\n',
    ]
    for mat in materials:
        fields = get_fields(mat)
        own_fields = {
            k:v for k, v in fields.items()
            if k not in base_mat_fields and k != 'update'
        }

        lines.append(f'## `{mat['name']}`\n\n')
        if desc := mat['defines'][0].get('desc'):
            lines.append(desc + '\n\n')
        
        lines.append('### Properties\n\n')
        if not own_fields:
            lines.append('This material has no additional properties.\n\n')
            continue

        for f in own_fields.values():
            lines.extend([
                f'#### `{mat['name']}.{f.name}: {f.type}`\n',
                f.desc + '\n',
                f'- Default value: {f.default}\n',
                f'- Updatable during runtime: {UPDATABLE_TO_EMOJI.get(f.updatable, '')}\n\n',
            ])
        lines.append('\n')

    with open('./docs/materials.md', 'w', encoding='utf-8') as file:
        file.writelines(lines)

def update_inject(clsname):
    u = LuaMethod(
        'update',
        clsname + ':update(props: table)',
        'Updates the properties of `self` according to `props`.'
    )
    return {'update': u}

def oo_inject(clsname):
    ret = update_inject(clsname)
    ret['lookAt'] = LuaMethod(
        'lookAt',
        clsname + ':lookAt(eyePos: Vec3, targetPos: Vec3, up?: Vec3)',
        'Positions `self` at `eyePos`, then rotates it to look at '\
        '`targetPos`, with its viewpoint oriented with its '\
        'up vector pointed in the direction hinted by `up`. If `up` '\
        'is not given, a default of `(0, -1, 0)` (the world up-direction) '\
        'will be used.'
    )
    return ret

def gen_scene_docs():
    scene = get_classes(['Scene'])['Scene']
    lines = std_gen_cls(scene,
        field_blacklist=['lights', 'pub'],
        method_inject=update_inject('Scene'))
    write_docs('docs/scene.md', [lines])

def gen_camera_docs():
    clss = get_classes(
        ['Camera', 'PerspectiveCamera', 'OrthographicCamera']
    )
    lc = std_gen_cls(
        clss['Camera'],
        method_whitelist=[''], method_inject=oo_inject('Camera')
    )
    lpc = std_gen_cls(
        clss['PerspectiveCamera'],
        field_whitelist=['aspectRatio', 'fov'],
        method_whitelist=['new'],
        parent='Camera'
    )
    loc = std_gen_cls(
        clss['OrthographicCamera'],
        field_whitelist=['left', 'right', 'top', 'bottom'],
        method_whitelist=['new'],
        parent='Camera'
    )
    write_docs(
        'docs/cameras.md', [lc, lpc, loc]
    )

def gen_lights_docs():
    clss = get_classes(
        ['Light', 'AmbientLight', 'PointLight', 'DirLight', 'SpotLight']
    )
    ll = std_gen_cls(
        clss['Light'],
        field_blacklist=['shadow'], method_blacklist=['linkWithScene'],
        method_inject=oo_inject('Light')
    )
    def gen_light_cls_docs(clsname, add_field_excludes=[]):
        return std_gen_cls(
            clss[clsname],
            field_blacklist=['color', 'intensity', 'position', 'rotation', 'viewMatrix', 'index', 'colorMapIndex', *add_field_excludes],
            method_blacklist=['linkWithScene'],
            parent='Light'
        )
    lal = gen_light_cls_docs('AmbientLight', ['shadow'])
    lpl = gen_light_cls_docs('PointLight')
    ldl = gen_light_cls_docs('DirLight')
    lsl = gen_light_cls_docs('SpotLight')
    write_docs(
        'docs/lights.md', [ll, lal, lpl, ldl, lsl]
    )

def gen_material_base_class_docs():
    clss = get_classes(['Material'])
    lines = std_gen_cls(clss['Material'],
        field_blacklist=['changeFuncs', 'listeners', 'mixins', 'useCamera', 'useLights'],
        method_inject=update_inject('Material'))
    write_docs('docs/material.md', [lines])

def gen_math_docs():
    clss = get_classes(['Euler', 'Mat3', 'Mat4', 'Quat', 'Vec3', 'Vec4'])
    write_docs('docs/math.md', [
        std_gen_cls(clss['Vec3']),
        std_gen_cls(clss['Vec4']),
        std_gen_cls(clss['Mat3']),
        std_gen_cls(clss['Mat4']),
        std_gen_cls(clss['Quat']),
        std_gen_cls(clss['Euler']),
    ])

def gen_shadow_docs():
    clss = get_classes([
        'StandardShadow',
        'StandardPerspectiveShadow', 'StandardOrthographicShadow'
    ])
    write_docs('docs/shadows.md', [
        std_gen_cls(
            clss['StandardShadow'],
            method_inject=update_inject('StandardShadow')
        ),
        std_gen_cls(
            clss['StandardPerspectiveShadow'],
            field_whitelist=[''],
            method_whitelist=[''],
            parent='StandardShadow'
        ),
        std_gen_cls(
            clss['StandardOrthographicShadow'],
            field_whitelist=[''],
            method_whitelist=[''],
            parent='StandardShadow'
        )
    ])

if __name__ == '__main__':
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument('-j', action='store_true')
    p.add_argument('-m', action='store_true')
    p.add_argument('-all', action='store_true')
    args = p.parse_args()
    if args.j:
        gen_json()
    elif args.m:
        gen_material_docs()
    elif args.all:
        gen_material_docs()
        gen_scene_docs()
        gen_camera_docs()
        gen_lights_docs()
        gen_material_base_class_docs()
        gen_math_docs()
        gen_shadow_docs()
    else:
        print('invalid option')
    