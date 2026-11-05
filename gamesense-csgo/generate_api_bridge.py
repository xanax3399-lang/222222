"""Generate DLL source and the complete reference inventory from pinned inputs.

No remote content is executed. Upstream references are factual symbol/signature
inventories only. A declaration is never treated as an implemented function.
"""
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parent

def lua(value):
    if isinstance(value,str):return json.dumps(value,ensure_ascii=True)
    if isinstance(value,dict):return '{'+','.join('['+lua(k)+']='+lua(v) for k,v in sorted(value.items()))+'}'
    if isinstance(value,list):return '{'+','.join(map(lua,value))+'}'
    raise TypeError(type(value))

def generate():
    nl=json.loads((ROOT/'api/neverlose-csgo-reference.json').read_text())
    gs=json.loads((ROOT/'api/gamesense-reference.json').read_text())
    source=(ROOT/'source/api_bridge/adapter.lua').read_text()
    aliases={'V':'vector','C':'color','E':'entity','G':'MenuGroup','I':'MenuItem'}
    implemented=set()
    for name in re.findall(r'function\s+([\w.:]+)\s*\(',source):
        if name.startswith('api.'):
            implemented.add(name[4:])
        elif ':' in name and name.split(':')[0] in aliases:
            a,b=name.split(':');implemented.add(aliases[a]+':'+b)
    implemented.update(['vector','color','db','print','new_class','NLClass:struct'])
    implemented.update('math.'+n for n in ['clamp','map','normalize_yaw','difference'])
    implemented.update('common.'+n for n in ['get_unixtime','get_date','get_timestamp','is_button_down','set_clan_tag'])
    implemented.update('utils.'+n for n in ['console_exec','execute_after','random_int','random_float','create_interface'])
    implemented.update(['json.parse','json.stringify'])
    # These dictionaries directly select real host getters/events, not stubs.
    for variable,prefix in [('global_map','globals.'),('event_map','events.')]:
        block=re.search(r'local '+variable+r'=\{(.*?)\}',source,re.S)[1]
        implemented.update(prefix+n for n in re.findall(r'(\w+)=',block))
    implemented.update(i['name'] for i in nl['symbols'] if i['name'].startswith('bit.'))
    partial={
        'math.clamp':'Explicit min and max required; undocumented NL defaults are not guessed.',
        'ui.create':'Only ui.create(group); controls appear under GS LUA/B with a group prefix.',
        'ui.find':'Explicit api.map_menu(path, GS references...) required. No automatic NL menu-path translation.',
        'MenuGroup:slider':'Integer GS slider; scale=1, no tooltip overload.',
        'MenuGroup:button':'No alt_style.',
        'MenuItem:reset':'Only controls created with a recorded default; host references have no known NL default.',
        'MenuItem:type':'Returns bridge kind; mapped GS references report host.',
        'MenuItem:id':'Returns GS reference, not an NL ID.',
        'render.line':'Thickness=1 only.',
        'render.rect':'No rounding or no_clamp.',
        'render.text':'Default GS font only (font=nil); GS text flags, not arbitrary NL font/flag semantics.',
        'render.measure_text':'Default GS font only (font=nil); GS flags.',
        'entity.get_players':'Uses GS CCSPlayer list and enemy/dormancy filters; no NL internal player list.',
        'entity.get_entities':'String classname only; GS entity list, no NL internal list.',
        'entity:get_eye_position':'Verified local-player eye getter only. Other players throw.',
        'entity:get_player_weapon':'Active weapon only; all_weapons=true throws.',
        'entity:get_xuid':'GS Steam64 string; no numeric coercion or NL account metadata.',
        'events.render':'Mapped to GS paint; no NL render context.',
        'events.createmove':'Mapped to GS setup_command. Supported fields are documented separately; unsupported fields throw.',
        'events.createmove_run':'GS run_command exposes only command_number and choked_commands; read-only.',
        'events.aim_fire':'GS event with hit_chance renamed hitchance and x/y/z converted to aim. No NL shot angle.',
        'common.get_timestamp':'GS millisecond timestamp; no promise of the same epoch as NL.',
        'common.get_date':'Only when the host explicitly provides os.date; stripped GS standard libraries do not guarantee it.',
        'common.get_system_time':'Requires host os.date for the calendar fields; no fabricated date if it is absent.',
        'db':'Namespaced GS database keys (gsnl: prefix); no existing NL database import.',
    }
    rows={}
    assert set(partial)<=implemented, 'Partial entries need actual implementations too.'
    for item in nl['symbols']:
        name=item['name'];status='partial' if name in partial else 'supported' if name in implemented else 'unavailable'
        rows[name]={**item,'status':status,'notes':partial.get(name,'Implemented against the bridge contract; NL binary equivalence unverified.' if status=='supported' else 'No implementation in this revision; explicit error. Original GS API remains available through api.gs.')}
    manifest={'bridge_version':'0.1.1','scope':'CS:GO Legacy 8802 only; partial compatibility, not a full Neverlose runtime.',
        'neverlose_reference':{k:v for k,v in nl.items() if k!='symbols'},
        'gamesense_reference':{k:v for k,v in gs.items() if k!='symbols'},
        'neverlose':rows,'gamesense':gs['symbols'],'gameplay_tested':False}
    build=ROOT/'build';build.mkdir(exist_ok=True)
    embedded=source.replace('__GSNL_INVENTORY__',lua(rows))
    assert '__GSNL_INVENTORY__' not in embedded and ')GSNL_SOURCE"' not in embedded
    (build/'embedded.h').write_text('#pragma once\nstatic const char gsnl_embedded_source[]=R"GSNL_SOURCE('+embedded+')GSNL_SOURCE";\n')
    (build/'gsnl_embedded.lua').write_text(embedded)
    (build/'gsnl_api_manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    lines=['# GS + NL API bridge 0.1.1','',manifest['scope'],'',
        'This is an independently written adapter. Public NL type declarations are a reference, not a recovered implementation.',
        'Native GS globals are preserved. `local api = require("gsnl")`; use `api.gs` for the original GS API.',
        '`api.supports(name)` is true for supported signatures only; partial entries require reading their restrictions.',
        'An inventory entry does not make a function available. Unsupported NL symbols throw; no fabricated charge/latency/matrix values.',
        '', '## Neverlose CS:GO reference inventory', '', '| Symbol | Status | Arguments | Restrictions |','|---|---|---|---|']
    for name,r in sorted(rows.items()):lines.append('| `'+name+'` | '+r['status']+' | `'+r.get('arguments','')+'` | '+r['notes'].replace('|','/')+' |')
    lines.extend(['','## Original Gamesense reference inventory','',
        'These are existing host functions, not bridge implementations. Availability is determined by the running GS build.',
        'Reference: '+gs['source']+'/tree/'+gs['revision'], '', '| Symbol | Arguments |','|---|---|'])
    for r in gs['symbols']:lines.append('| `'+r['name']+'` | `'+', '.join(n for n in r['arguments'] if n)+'` |')
    (build/'GSNL_API.md').write_text('\n'.join(lines)+'\n')
    return manifest

if __name__=='__main__':
    from collections import Counter
    m=generate();print(dict(Counter(r['status'] for r in m['neverlose'].values())))
