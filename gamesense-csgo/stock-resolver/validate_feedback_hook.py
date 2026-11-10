"""Execute the production shot shim and native GS tick-field publication."""
import json,struct,sys
from pathlib import Path
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import *
ROOT=Path(__file__).resolve().parent.parent;sys.path.insert(0,str(ROOT/'tests'))
from validate_points_bridge import Machine,BASE,DATA,STACK,STOP,words
SITE=0x43355ef1
class Hook(Machine):
 def __init__(self,fault=None):super().__init__(fault,'feedback_probe.dll')
 def prepare(self,mode=8,enabled=1):return self.call('feedback_prepare',[BASE,len(self.image),mode,enabled])&255
checks=0
for mode,enabled in ((0,1),(8,0)):
 m=Hook();old=bytes(m.u.mem_read(BASE,len(m.image)));assert m.prepare(mode,enabled) and bytes(m.u.mem_read(BASE,len(m.image)))==old;checks+=1
for fault in ('allocate','protect','flush','flush_core'):
 m=Hook(fault);old=bytes(m.u.mem_read(BASE,len(m.image)));assert not m.prepare() and bytes(m.u.mem_read(BASE,len(m.image)))==old;checks+=1
for a in (SITE,0x43355efa):
 m=Hook();m.u.mem_write(a,b'\xcc');old=bytes(m.u.mem_read(BASE,len(m.image)));assert not m.prepare() and bytes(m.u.mem_read(BASE,len(m.image)))==old;checks+=1
m=Hook();assert m.prepare();u=m.u;sp=STACK+0x17000;u.mem_write(sp,bytes(0x100));
u.mem_write(sp+0x14,words(DATA+0x10000,DATA+0x20000));u.mem_write(sp+0x28,words(DATA+0x30000));
regs=[UC_X86_REG_EAX,UC_X86_REG_EBX,UC_X86_REG_ECX,UC_X86_REG_EDX,UC_X86_REG_ESI,UC_X86_REG_EDI,UC_X86_REG_EBP]
values=[5,0x1234,DATA+0x40000,0x2345,77,0x3456,0x4567]
for r,v in zip(regs,values):u.reg_write(r,v)
for i in range(8):u.reg_write(UC_X86_REG_XMM0+i,0x112233445566+i)
before=[u.reg_read(UC_X86_REG_XMM0+i) for i in range(8)];u.reg_write(UC_X86_REG_ESP,sp)
u.emu_start(SITE,SITE+7,count=100000)
assert [u.reg_read(r) for r in regs]==values and u.reg_read(UC_X86_REG_ESP)==sp-4
assert m.word(sp-4)==77 and m.word(DATA+0x40000+0x168)==5
assert [u.reg_read(UC_X86_REG_XMM0+i) for i in range(8)]==before
captured=struct.unpack('<6I',u.mem_read(m.exports['feedback_capture'],24))
assert captured==(1,DATA+0x10000,DATA+0x20000,DATA+0x30000,77,5);checks+=1
# Native GS aim_fire publishes candidate+B4 as the field named "tick".
# Execute that exact native load, XOR string decode and Lua setter call.
m=Hook();u=m.u;sp=STACK+0x17000;pair=DATA;candidate=DATA+0x1000
u.mem_write(pair+4,words(candidate));u.mem_write(candidate+0xb4,words(647));u.reg_write(UC_X86_REG_ESP,sp)
u.reg_write(UC_X86_REG_EDX,sp+0x14);u.reg_write(UC_X86_REG_EAX,candidate);u.reg_write(UC_X86_REG_ESI,DATA+0x2000);u.reg_write(UC_X86_REG_EDI,0)
seen=[]
def setter(u,a,size,unused):
 s=u.reg_read(UC_X86_REG_ESP);p=u.reg_read(UC_X86_REG_EDX);n=m.word(s+4);value=m.word(s+8)
 seen.append((bytes(u.mem_read(p,n)),value));u.emu_stop()
u.hook_add(UC_HOOK_CODE,setter,begin=0x4339c6d0,end=0x4339c6d0)
u.emu_start(0x4336aa0a,STOP,count=1000)
assert seen==[(b'tick',647)];checks+=1
for group in json.loads((ROOT/'source/skeet/VM/bytecode.json').read_text()):
 for entry in (group['main'],*group['others']):assert entry['vip']+entry['size']<=SITE or entry['vip']>=SITE+7
report={'checks':checks,'actual_native_shot_replay_executed':True,'native_aim_fire_tick_field_executed':True,'captured_exact_native_frame':True,'gameplay_tested':False}
(ROOT/'build/stock_resolver_feedback_hook_validation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
