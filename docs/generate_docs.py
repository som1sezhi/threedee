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

def gen_json():
    subprocess.run(['lua-language-server.exe', '--doc', './threedee/materials', '--doc_out_path', '.'], shell=True)

def get_fields(cls):
    ret = {}
    for f in cls['fields']:
        desc = f.get('desc', '')
        m = re.match(r'\((.)\) (.*) Default: (.*)$', desc)
        if m:
            updatable, desc, default = m[1], m[2], m[3]
        else:
            updatable, desc, default = '', '', ''
        field = LuaField(
            f['name'],
            f['extends']['view'],
            updatable, desc, default
        )
        ret[f['name']] = field
    return ret

UPDATABLE_TO_EMOJI = {
    'U': '✅',
    'C': '⚠️',
    'X': '❌'
}

MATERIAL_CLASS_NAMES = {
    'DepthMaterial',
    'MatcapMaterial',
    'NormalMaterial',
    'PhongMaterial',
    'UnlitMaterial',
    'UVMaterial'
}

def escpipe(s):
    return s.replace('|', '\u200b\\|\u200b')

def gen_material_docs():
    with open('doc.json') as f:
        input = json.load(f)
    materials = [c for c in input if c['name'] in MATERIAL_CLASS_NAMES]
    base_mat_class = [c for c in input if c['name'] == 'Material'][0]
    #mixins = [c for c in input if c['name'].startswith('With')]
    base_mat_fields = get_fields(base_mat_class)

    # for mixin in mixins:
    #     fields = get_fields(mixin)
    #     own_fields = {
    #         k:v for k, v in fields.items()
    #         if k not in base_mat_fields and k != 'update'
    #     }
    #     print(mixin['name'], [f for f in own_fields])

    lines = [
        '# Built-in Materials\n\n',
        'Note that all these properties are in addition to the properties provided by the base class.\n\n'
    ]
    for mat in materials:
        fields = get_fields(mat)
        own_fields = {
            k:v for k, v in fields.items()
            if k not in base_mat_fields and k != 'update'
        }
        lines.append(f'## {mat['name']}\n\n')
        if desc := mat['defines'][0].get('desc'):
            lines.append(desc + '\n\n')
        if not own_fields:
            lines.append('This material has no additional properties.\n\n')
            continue
        lines.append('### Properties\n\n')
        lines.append('Name | Type | Updatable during runtime? | Description | Default value\n')
        lines.append('--- | --- | :---: | --- | ---\n')
        for f in own_fields.values():
            f: LuaField
            l = f'{f.name} | `{escpipe(f.type)}` ' \
                f'| {UPDATABLE_TO_EMOJI.get(f.updatable, '')} ' \
                f'| {f.desc} | {f.default}\n'
            lines.append(l)
        lines.append('\n')

    with open('./docs/materials.md', 'w', encoding='utf-8') as file:
        file.writelines(lines)

if __name__ == '__main__':
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument('-j', action='store_true')
    p.add_argument('-m', action='store_true')
    args = p.parse_args()
    if args.j:
        gen_json()
    elif args.m:
        gen_material_docs()
    