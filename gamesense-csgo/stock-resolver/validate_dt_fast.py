"""Compare production fast/reference samplers; measure retired shim instructions.

This is x86 emulation, not an FPS benchmark. HC scene outcomes are fixtures.
"""
import json,struct
from pathlib import Path
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import *
from validate_dt_sampling import Machine,SITE,END
from validate_points_bridge import BASE,STOP,SHIM,words,floats
ROOT=Path(__file__).resolve().parent.parent
RESUME=SITE+7
class Fast(Machine):
 def prepare(self,enabled=1,mode=8,fast=1):return bool(self.call('accuracy_dt_fast_prepare',[BASE,len(self.image),mode,enabled,fast])&255)
 def perf(self):
  return dict(zip(['version','enabled','profiling','installed','samples','last_us','worst_us','slow_samples','last_hc_calls','peak_hc_calls'],struct.unpack('<10I',self.u.mem_read(self.exports['sr_dt_fast_status'],40))))

def trace(fast=1,mode=1,tier=32):
 m=Fast();assert m.prepare(fast=fast);m.set_command(mode=mode);m.observe();m.stub(tier)
 u=m.u;inside=False;instructions=[];apis=[];before={};count=0
 gprs=[UC_X86_REG_EAX,UC_X86_REG_EBX,UC_X86_REG_ECX,UC_X86_REG_EDX,UC_X86_REG_ESI,UC_X86_REG_EDI,UC_X86_REG_EBP,UC_X86_REG_ESP]
 fp=[UC_X86_REG_XMM0+i for i in range(8)]+[UC_X86_REG_FPCW,UC_X86_REG_MXCSR,UC_X86_REG_FPSW]+[UC_X86_REG_FP0+i for i in range(8)]
 def step(u,a,size,unused):
  nonlocal inside,count
  if a==SITE:
   inside=True;before['gpr']=[u.reg_read(r) for r in gprs];before['fp']=[u.reg_read(r) for r in fp]
   sp=u.reg_read(UC_X86_REG_ESP);before['stack']=bytes(u.mem_read(sp,0x100));before['flags']=u.reg_read(UC_X86_REG_EFLAGS)
  if a==RESUME:
   after=[u.reg_read(r) for r in gprs];expected=before['gpr'].copy();expected[2]=0;expected[3]=0
   assert after==expected,(fast,after,expected)
   flags=u.reg_read(UC_X86_REG_EFLAGS);assert flags&0x8c5==0x44 and (flags^before['flags'])&~0x8d5==0
   assert [u.reg_read(r) for r in fp]==before['fp'],'floating point state must remain identical'
   stack=bytearray(before['stack']);stack[0x10:0x14]=words(64 if mode==1 else tier)
   assert bytes(u.mem_read(after[-1],0x100))==bytes(stack),'only budget local may change'
   inside=False
  if inside:
   count+=1;instructions.append(bytes(u.mem_read(a,size)))
   if a in m.imports:apis.append(m.imports[a])
 for i in range(8):u.reg_write(UC_X86_REG_XMM0+i,(0x123456789abcdef00112233445566778+i)&((1<<128)-1))
 u.reg_write(UC_X86_REG_FPCW,0x27f);u.reg_write(UC_X86_REG_MXCSR,0x3f80)
 u.reg_write(UC_X86_REG_FP0,(0x8000000000000000,0x3fff));u.reg_write(UC_X86_REG_FPTAG,0xfffc)
 h=u.hook_add(UC_HOOK_CODE,step)
 try:m.sample()
 finally:u.hook_del(h)
 assert m.observed[-1][0]==(64 if mode==1 else tier)
 return {'instructions':count,'os_calls':apis,'fp_save_restore':sum(b.startswith((b'\x0f\xae',b'\xdb\xe3')) for b in instructions)}

def main():
 checks=0
 # Exactly the same native arithmetic, return value and metadata for both implementations.
 for mode,flags in ((1,0),(0,0),(3,8)):
  for weapon in (11,38,40):
   for tier in (32,64):
    results=[]
    for fast in (0,1):
     m=Fast();assert m.prepare(fast=fast);m.set_command(mode=mode,flags=flags);m.observe();m.store(m.weapon+0xd8,weapon);m.stub(tier);m.sample()
     results.append((m.observed,bytes(m.u.mem_read(m.out,4)),m.dt_status()))
     assert m.perf()['installed']==fast;checks+=1
    assert results[0]==results[1],(mode,flags,weapon,results)
 # Calls that bypass our wrapper cannot borrow a previous approved scope.
 m=Fast();assert m.prepare();m.set_command();m.observe();m.stub();m.sample()
 m.u.mem_write(0x43354bd3,bytes.fromhex('e8ea680c00'));m.sample();assert [x[0] for x in m.observed]==[64,32];checks+=1
 # Per-thread observation must not leak into a different caller.
 m=Fast();assert m.prepare();m.set_command();m.observe();m.stub();m.thread=2;m.sample();m.thread=1;m.sample()
 assert [x[0] for x in m.observed]==[32,64];checks+=1
 # HC fast paths still use the exact native result and RET12 ABI.
 m=Fast();assert m.prepare();m.set_command();m.observe();m.fixture=False;m.store(m.weapon,0x4000);m.sample()
 assert m.word(m.out)==0x3f800000 and not m.dt_status()['calls'];checks+=1
 # The gate carries its scope on the stack. Malformed identities never promote.
 for field in range(6):
  m=Fast();assert m.prepare();m.set_command();m.observe();m.stub()
  scope=0x20090000;values=[m.ctx,m.cmd,100,m.weapon,m.candidate,m.hc_context];values[field]+=4
  if field==0:m.store(values[0],0) # readable foreign context
  m.u.mem_write(scope,words(*values));sp=0x30017000;m.u.mem_write(sp,words(STOP,m.weapon,m.candidate,m.out))
  m.u.reg_write(UC_X86_REG_ESP,sp);m.u.reg_write(UC_X86_REG_ECX,m.hc_context);m.u.reg_write(UC_X86_REG_EDX,scope)
  m.u.emu_start(SHIM+1536,STOP,count=100000)
  assert m.observed[-1][0]==32 and m.dt_status()['fallback']==1;checks+=1
 # Sampled timers do not alter the arithmetic; fixture clock increments 200 us.
 m=Fast();assert m.prepare();m.set_command();m.observe();m.stub()
 for i in range(64):m.sample()
 p=m.perf();assert p['samples']==2 and p['last_us']==200 and p['worst_us']==200 and not p['slow_samples']
 m.set_command(101);m.observe();p=m.perf();assert p['last_hc_calls']==64 and p['peak_hc_calls']==64;checks+=1
 # New pinned native frame dependency is fail-closed and rollback remains exact.
 for fast in (0,1):
  m=Fast();m.u.mem_write(0x4341b4c2,b'\xcc');before=bytes(m.u.mem_read(BASE,len(m.image)))
  assert not m.prepare(fast=fast) and bytes(m.u.mem_read(BASE,len(m.image)))==before;checks+=1
 for fault in ('allocate','protect','flush','flush_core','fls'):
  m=Fast(fault);before=bytes(m.u.mem_read(BASE,len(m.image)));assert not m.prepare()
  assert bytes(m.u.mem_read(BASE,len(m.image)))==before and not m.perf()['installed'];checks+=1
 overhead={}
 for mode in (0,1):
  old=trace(0,mode);new=trace(1,mode);assert new['instructions']<old['instructions']
  assert not new['os_calls'] and not new['fp_save_restore']
  overhead[str(mode)]={'reference':old,'fast':new};checks+=1
 report={'checks':checks,'same_64_sample_arithmetic':True,'GPR_and_FP_preserved':True,'stack_scope_and_thread_isolation':True,
         'shim_retired_instructions':overhead,'sampled_timer_fixture_us':200,'native_traces_reduced':False,'fps_gain_measured':False,'gameplay_tested':False}
 (ROOT/'build/stock_resolver_dt_fast_validation.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
if __name__=='__main__':main()
