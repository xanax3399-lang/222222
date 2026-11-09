"""Execute the actual pinned GS plist.get/set against the C++ controller layout.

Only Lua argument/result primitives are fixtures. The original GS name hashing,
descriptor lookup, bounds, and field reads/writes execute as actual x86 code.
The production native driver does not call Lua or these argument primitives.
"""
import json,re,struct
from pathlib import Path
from unicorn import Uc,UC_ARCH_X86,UC_MODE_32,UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_ESP,UC_X86_REG_EIP,UC_X86_REG_EAX

ROOT=Path(__file__).resolve().parent
image=(ROOT.parent/'source/skeet/Binary/skeet.bin').read_bytes()
header=(ROOT/'native_controller.h').read_text()
def constant(name):return int(re.search(r'\b'+name+r'\s*=\s*(0x[0-9a-f]+|[0-9]+)',header).group(1),0)
BASE,STACK,DATA,STOP=0x43310000,0x30000000,0x20000000,0x50000000
storage,stride,flag,value=map(constant,('plist_base','stride','yaw_enabled','yaw_value'))
u=Uc(UC_ARCH_X86,UC_MODE_32)
for address,size in ((BASE,len(image)),(STACK,65536),(DATA,65536),(STOP,4096)):u.mem_map(address,(size+4095)&-4096)
u.mem_write(BASE,image)
args={};result=None;checks=0
def word(address):return struct.unpack('<I',u.mem_read(address,4))[0]
def ret(number=0):
    sp=u.reg_read(UC_X86_REG_ESP);u.reg_write(UC_X86_REG_EAX,number&0xffffffff)
    u.reg_write(UC_X86_REG_ESP,sp+4);u.reg_write(UC_X86_REG_EIP,word(sp))
def api(machine,address,size,unused):
    global result
    sp=u.reg_read(UC_X86_REG_ESP)
    if address==0x43434771:ret(3 if args['write'] else 2)
    elif address==0x434249c0:ret(args['player'] if word(sp+8)==1 else args['value'])
    elif address==0x434309b0:
        u.mem_write(word(sp+12),struct.pack('<I',len(args['name'])));ret(DATA)
    elif address==0x43429167:ret(int(bool(args['value'])))
    elif address==0x4342b52b:result=bool(word(sp+8));ret()
    elif address==0x4343525f:result=struct.unpack('<d',u.mem_read(sp+8,8))[0];ret()
for address in (0x43434771,0x434249c0,0x434309b0,0x43429167,0x4342b52b,0x4343525f):
    u.hook_add(UC_HOOK_CODE,api,begin=address,end=address)
def call(player,name,write=False,number=0):
    global args,result,checks
    args={'player':player,'name':name,'write':write,'value':number};result=None
    u.mem_write(DATA,name.encode()+b'\0');sp=STACK+0xf000;u.mem_write(sp,struct.pack('<II',STOP,DATA+0x1000))
    u.reg_write(UC_X86_REG_ESP,sp);u.emu_start(0x43325068 if write else 0x433c8e61,STOP,count=10000)
    assert u.reg_read(UC_X86_REG_EIP)==STOP and u.reg_read(UC_X86_REG_ESP)==sp+4
    checks+=1;return result
for player in (1,2,64):
    entry=storage+player*stride
    u.mem_write(entry,bytes([0x5a])*stride)
    u.mem_write(entry+flag,b'\x01');u.mem_write(entry+value,struct.pack('<i',-60))
    assert call(player,'Force body yaw') is True
    assert call(player,'Force body yaw value')==-60
    before=bytes(u.mem_read(entry,stride));call(player,'Force body yaw',True,0)
    assert u.mem_read(entry+flag,1)==b'\0'
    after=bytes(u.mem_read(entry,stride));assert all(a==b for i,(a,b) in enumerate(zip(before,after)) if i!=flag)
    call(player,'Force body yaw value',True,60);assert struct.unpack('<i',u.mem_read(entry+value,4))[0]==60
    before=bytes(u.mem_read(entry,stride));call(player,'Force body yaw value',True,61)
    assert bytes(u.mem_read(entry,stride))==before
report={'actual_gs_plist_calls':checks,'native_controller_layout_confirmed':True,'lua_required_by_driver':False,
        'lua_argument_primitives':'controlled fixture','gameplay_tested':False}
(ROOT.parent/'build/stock_resolver_native_contract_validation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
