"""Guard the observed GS buffer contract. Does not approve a hook."""
from pathlib import Path
import hashlib
import json
import struct

ROOT=Path(__file__).resolve().parents[1]
raw=(ROOT/'source/skeet/Binary/skeet.bin').read_bytes()
assert hashlib.sha256(raw).hexdigest()=='bbb5ee98d00db63dfc5c454b238d5edd3f809976686be226dbc5f6ae55018b07'
base=0x43310000
address=0x433d5a95
initializer=bytes.fromhex('8d4110894104890183c0488941088bc1c3')
assert raw[address-base:address-base+len(initializer)]==initializer
callers=[]
for i in range(len(raw)-5):
    if raw[i]==0xe8 and (base+i+5+struct.unpack_from('<i',raw,i+1)[0])&0xffffffff==0x433fd9b7:
        callers.append(base+i)
assert callers==[0x433341ca,0x4335e9d0]
handlers=json.loads((ROOT/'source/skeet/VM/bytecode.json').read_text())
for group in handlers:
    for entry in [group['main'],*group['others']]:
        first=entry['vip'];last=first+entry['size']
        assert last<=0x4335e9d0 or first>=0x4335e9d5,'VM preparation would overwrite the hook'
report={'core_sha256':hashlib.sha256(raw).hexdigest(),
        'generator':'0x433fd9b7','direct_callers':[hex(x) for x in callers],
        'small_vector_initializer':hex(address),'initializer_bytes':initializer.hex(),
        'inline_capacity_bytes':0x48,'gs_point_stride':0x18,'inline_point_capacity':3,
        'nl_point_stride':0x50,'nl_max_generated_points':7,
        'direct_copy_compatible':False,'runtime_hook_implemented':True,
        'hook_callers':['0x4335e9d0'],'other_caller_native':True,
        'adapter_point_stride':24,'adapter_capacity':7,'main_capacity':256,
        'vm_writes_do_not_overlap_hook':True,
        'aim_selection_ported':False,'gameplay_tested':False}
(ROOT/'reports').mkdir(exist_ok=True)
(ROOT/'reports/points_integration_contract.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
