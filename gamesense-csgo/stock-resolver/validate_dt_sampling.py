"""Execute the real native 32/64 budget arithmetic through the production shim.

HC scene and interfaces are fixtures. This does not simulate a CS:GO match.
"""
from pathlib import Path
import json,struct,sys
from unicorn import UC_HOOK_CODE
from unicorn.x86_const import *
from validate_accuracy import Accuracy
ROOT=Path(__file__).resolve().parent.parent
from validate_points_bridge import BASE,STOP,words,floats
SITE=0x4341bc00;END=0x4341bc46
class Machine(Accuracy):
 def prepare(self,enabled=1,mode=8):return bool(self.call('accuracy_dt_prepare',[BASE,len(self.image),mode,enabled])&255)
 def dt_status(self):
  names=['version','enabled','mode','installed','calls','boosted','already_full','fallback','command','weapon','before','after']
  return dict(zip(names,struct.unpack('<12I',self.u.mem_read(self.exports['sr_dt_status'],48))))
 def stub(self,tier=32,penalty=.25,multi=0):
  self.fixture=False;self.observed=[]
  entry=STOP+0x600;tail=STOP+0x700
  # Native __thiscall ABI; use the actual native stack-local offsets.
  code=bytearray.fromhex('55 89e5 56 57 81ec00010000 894c2434 8b7508 8b7d0c c7442410')+words(tier)+bytearray.fromhex('c644240b00')
  code[-1]=multi
  code+=b'\xe9'+struct.pack('<i',SITE-(entry+len(code)+5))
  self.u.mem_write(entry,bytes(code));self.u.mem_write(0x4341b4c2,b'\xe9'+struct.pack('<i',entry-0x4341b4c2-5))
  self.u.mem_write(tail,bytes.fromhex('8b4510 c700 cdcc4c3f b801000000 8d65f8 5f5e 89ec5d c20c00'))
  self.u.mem_write(self.candidate+0xd4,floats(penalty))
  def complete(u,a,size,unused):
   sp=u.reg_read(UC_X86_REG_ESP)
   self.observed.append((self.word(sp+0x10),self.word(sp+0x5c),self.word(sp+0x4c)))
   u.reg_write(UC_X86_REG_EIP,tail)
  self.u.hook_add(UC_HOOK_CODE,complete,begin=END,end=END)
 def run(self,mode=1,flags=0,weapon=38,tier=32,enabled=1):
  assert self.prepare(enabled);self.set_command(mode=mode,flags=flags);self.observe()
  self.store(self.weapon+0xd8,weapon);self.stub(tier);self.sample()
  assert len(self.observed)==1
  return self.observed[0]
def main():
 checks=[]
 for weapon in (11,38):
  for tier in (32,64):
   for enabled in (0,1):
    m=Machine();got=m.run(weapon=weapon,tier=tier,enabled=enabled)
    expected=64 if enabled else tier
    assert got==(expected,128//expected,expected-round(expected*.25)+2),(weapon,tier,enabled,got)
    st=m.dt_status();assert st['boosted']==int(enabled and tier==32) and st['already_full']==int(enabled and tier==64)
    # Per-shot probability and attacks remain owned by the native routine.
    assert m.word(m.cmd+0x30)==0 and abs(struct.unpack('<f',m.u.mem_read(m.out,4))[0]-.8)<1e-6
    checks.append('native tier '+str((weapon,tier,enabled)))
 for multi in (0,1):
  for penalty in (0,.25,.5,1):
   m=Machine();assert m.prepare();m.set_command();m.observe();m.stub(penalty=penalty,multi=multi);m.sample()
   count=64*(1+2*multi)
   assert m.observed[-1]==(64,2,count-round(count*penalty)+2)
   checks.append('native count '+str((multi,penalty)))
 for mode,flags,weapon in ((0,0,38),(3,8,38),(1,0,40),(1,0,1),(1,0,9)):
  m=Machine();assert m.run(mode,flags,weapon)==(32,4,26);assert not m.dt_status()['calls'];checks.append('excluded '+str((mode,flags,weapon)))
 # The DT mode can be cleared before queued commands finish; latch only while
 # the native pending-shift flag persists. A later inactive command clears it.
 m=Machine();assert m.prepare();m.set_command(mode=1);m.observe();m.set_command(101,mode=0,flags=8);m.observe();m.stub();m.sample()
 assert m.observed[-1][0]==64
 m.set_command(102,mode=0,flags=0);m.observe();m.sample();assert m.observed[-1][0]==32
 checks.append('queued DT and inactive transition')
 for defect in ('stale_before_call','stale_inside_call','HC_context','unexpected_tier','release_same_command','context_change','command_gap','unobserved_pending'):
  m=Machine();assert m.prepare();m.set_command(mode=1);m.observe()
  if defect=='stale_before_call':m.store(m.cmd+4,101)
  elif defect=='release_same_command':m.set_command(mode=0)
  elif defect=='context_change':
   m.ctx+=0x1000;m.store(m.ctx,0x4346edd4);m.set_command(101,mode=0,flags=8);m.observe()
  elif defect=='command_gap':m.set_command(999,mode=0,flags=8);m.observe()
  elif defect=='unobserved_pending':
   m=Machine();assert m.prepare();m.set_command(mode=0,flags=8);m.observe()
  m.stub(tier=16 if defect=='unexpected_tier' else 32)
  if defect in ('stale_inside_call','HC_context'):
   def corrupt(u,a,size,unused):
    if defect=='stale_inside_call':m.store(m.cmd+4,101)
    else:m.store(u.reg_read(UC_X86_REG_ESP)+0x34,m.hc_context+4)
   m.u.hook_add(UC_HOOK_CODE,corrupt,begin=SITE,end=SITE)
  m.sample();assert m.observed[-1][0]==(16 if defect=='unexpected_tier' else 32)
  assert not m.dt_status()['boosted'];checks.append('fallback '+defect)
 # Optional feature depends on installed HC observers; no hidden hook when disabled.
 for brake in (0,1):
  m=Machine();m.store(m.exports['sr_dt_status']+4,1)
  assert m.call('accuracy_prepare',[BASE,len(m.image),8,0,brake])&255
  assert bytes(m.u.mem_read(SITE,7))==m.image[SITE-BASE:SITE-BASE+7]
  assert not m.dt_status()['installed'];checks.append('final_check disabled '+str(brake))
 # The hook site is outside all decoded VM blocks, so the VM installer cannot overwrite it.
 for group in json.loads((ROOT/'source/skeet/VM/bytecode.json').read_text()):
  for entry in (group['main'],*group['others']):
   assert entry['vip']+entry['size']<=SITE or entry['vip']>=SITE+7
 checks.append('VM blocks do not overlap sample hook')
 for fault in ('allocate','protect','flush','flush_core','fls'):
  m=Machine(fault);before=bytes(m.u.mem_read(BASE,len(m.image)));assert not m.prepare()
  assert bytes(m.u.mem_read(BASE,len(m.image)))==before;checks.append('rollback '+fault)
 for enabled in (0,1):
  m=Machine();before=bytes(m.u.mem_read(BASE,len(m.image)));assert m.prepare(enabled,mode=0)
  assert bytes(m.u.mem_read(BASE,len(m.image)))==before;checks.append('stock remains intact '+str(enabled))
 for address in (SITE,0x4341bbf8,0x4341bc14):
  m=Machine();m.u.mem_write(address,b'\xcc');before=bytes(m.u.mem_read(BASE,len(m.image)));assert not m.prepare()
  assert bytes(m.u.mem_read(BASE,len(m.image)))==before;checks.append('byte contract '+hex(address))
 # Fixed-bank worker bounds are unmodified: 64 jobs and 128 bank entries.
 report={'checks':len(checks),'cases':checks,'native_budget_arithmetic_executed':True,'maximum_jobs':64,'seed_bank':128,
         'queued_DT_latch_tested':True,'thresholds_and_recharge_unchanged':True,'HC_scene_results':'fixture','gameplay_tested':False}
 (ROOT/'build/stock_resolver_dt_validation.json').write_text(json.dumps(report,indent=2)+'\n')
 print(json.dumps(report))
if __name__=='__main__':main()
