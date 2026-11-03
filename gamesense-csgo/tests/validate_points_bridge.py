"""Execute the compiled production x86 bridge, GS intersection and GS consumer.

Controlled Windows storage/CRT APIs and native-output fixtures for head cases.
One body case executes the actual GS generator. No game, injection, DllMain or
VM initialization. Native candidates and native primary center must survive.
"""
from pathlib import Path
import hashlib,json,math,random,struct
import pefile
from unicorn import Uc,UC_ARCH_X86,UC_MODE_32,UC_HOOK_CODE
from unicorn.x86_const import *

ROOT=Path(__file__).resolve().parents[1]
BASE,PE,DATA,STACK,STOP,API,HEAP,SHIM=0x43310000,0x60000000,0x20000000,0x30000000,0x50000000,0x71000000,0x22000000,0x52000000
def words(*v):return struct.pack('<'+'I'*len(v),*(x&0xffffffff for x in v))
def floats(*v):return struct.pack('<'+'f'*len(v),*v)

class Machine:
    def __init__(self,fault=None,probe='points_bridge_probe.dll'):
        self.image=(ROOT/'source/skeet/Binary/skeet.bin').read_bytes()
        assert hashlib.sha256(self.image).hexdigest()=='bbb5ee98d00db63dfc5c454b238d5edd3f809976686be226dbc5f6ae55018b07'
        self.u=u=Uc(UC_ARCH_X86,UC_MODE_32)
        pe=pefile.PE(str(ROOT/'build'/probe));pe.relocate_image(PE)
        for base,size in [(BASE,len(self.image)),(PE,pe.OPTIONAL_HEADER.SizeOfImage),(DATA,0x100000),
                          (STACK,0x20000),(STOP,0x1000),(API,0x10000),(HEAP,0x100000),(SHIM,0x1000)]:
            u.mem_map(base,(size+4095)&-4096)
        u.mem_write(BASE,self.image);u.mem_write(PE,pe.get_memory_mapped_image())
        self.exports={s.name.decode().lstrip('_'):PE+s.address for s in pe.DIRECTORY_ENTRY_EXPORT.symbols if s.name}
        self.imports={}
        for lib in pe.DIRECTORY_ENTRY_IMPORT:
            for item in lib.imports:
                address=API+len(self.imports)*16;self.imports[address]=item.name.decode() if item.name else str(item.ordinal)
                u.mem_write(address,b'\xc3');self.store(item.address,address)
        self.heap=HEAP;self.storage={};self.thread=1;self.original_calls=[];self.error=0;self.fault=fault
        self.allocations=0;self.flushes=0;self.intersections=0
        self.native_count=2;self.last_baseline=b'';self.native_body=False
        u.mem_map(0x774fd000,4096);u.mem_write(0x774fd4a0,b'\xc3')
        u.mem_write(STOP+0x100,b'\xdd\x05'+words(DATA+0x80000)+b'\xc3')
        u.hook_add(UC_HOOK_CODE,self.runtime,begin=API,end=API+0xffff)
        u.hook_add(UC_HOOK_CODE,self.runtime,begin=0x433fd9b7,end=0x433fd9b7)
        u.hook_add(UC_HOOK_CODE,self.runtime,begin=0x43418772,end=0x43418772)
        u.hook_add(UC_HOOK_CODE,self.runtime,begin=0x774fd4a0,end=0x774fd4a0)
    def word(self,a):return struct.unpack('<I',self.u.mem_read(a,4))[0]
    def store(self,a,v):self.u.mem_write(a,words(v))
    def runtime(self,u,a,size,_):
        if a==0x43418772:self.intersections+=1
        if a==0x433fd9b7:
            sp=u.reg_read(UC_X86_REG_ESP)
            args=[self.word(sp+4+4*i) for i in range(5)]
            self.original_calls.append((u.reg_read(UC_X86_REG_ECX),u.reg_read(UC_X86_REG_EDX),args))
            if self.native_body:return
            id=self.word(args[1]);group=1 if id==0 else 3
            self.last_baseline=b''.join(floats(0,4 if i==0 else -4,65+getattr(self,'pose_z',0),1)+words(group,3) for i in range(self.native_count))
            out=args[3];begin=self.word(out)
            if self.last_baseline:u.mem_write(begin,self.last_baseline)
            self.store(out+4,begin+len(self.last_baseline))
            u.reg_write(UC_X86_REG_EIP,self.word(sp));u.reg_write(UC_X86_REG_ESP,sp+24);return
        if a==0x774fd4a0:
            sp=u.reg_read(UC_X86_REG_ESP);ret,dst,src,count=struct.unpack('<4I',u.mem_read(sp,16))
            u.mem_write(dst,bytes(u.mem_read(src,count)));u.reg_write(UC_X86_REG_EAX,dst)
            u.reg_write(UC_X86_REG_ESP,sp+4);u.reg_write(UC_X86_REG_EIP,ret);return
        name=self.imports.get(a)
        if name is None:return
        sp=u.reg_read(UC_X86_REG_ESP);ret=self.word(sp);n=0;result=0
        arg=lambda i:self.word(sp+4*i)
        if name=='VirtualAlloc':n=4;result=0 if self.fault=='allocate' else SHIM
        elif name=='VirtualProtect':n=4;result=int(self.fault!='protect');self.store(arg(4),4)
        elif name=='VirtualFree':n=3;result=1
        elif name=='FlsAlloc':n=1;result=0xffffffff if self.fault=='fls' else 3
        elif name=='FlsFree':n=1;result=1
        elif name=='FlsGetValue':n=1;result=self.storage.get(self.thread,0)
        elif name=='FlsSetValue':
            n=2;result=int(self.fault!='set')
            if result:self.storage[self.thread]=arg(2)
        elif name=='GetProcessHeap':result=0x1234
        elif name=='HeapAlloc':
            n=3;self.allocations+=1
            if self.fault!='heap':
                result=self.heap;self.heap+=(arg(3)+15)&-16;assert self.heap<HEAP+0x100000
                u.mem_write(result,bytes(arg(3)))
        elif name=='HeapFree':n=3;result=1
        elif name=='GetCurrentProcess':result=0xffffffff
        elif name=='FlushInstructionCache':
            n=3;self.flushes+=1;result=int(self.fault!='flush' and not(self.fault=='flush_core' and arg(2)==BASE))
        elif name=='SetLastError':n=1;self.error=arg(1)
        elif name=='GetLastError':result=self.error
        elif name in ('memcpy','memmove'):
            u.mem_write(arg(1),bytes(u.mem_read(arg(2),arg(3))));result=arg(1)
            n=-1
        elif name=='memset':u.mem_write(arg(1),bytes([arg(2)&255])*arg(3));result=arg(1);n=-1
        elif name in ('sqrt','sqrtf'):
            value=struct.unpack('<d' if name=='sqrt' else '<f',u.mem_read(sp+4,8 if name=='sqrt' else 4))[0]
            u.mem_write(DATA+0x80000,struct.pack('<d',math.sqrt(value)))
            u.reg_write(UC_X86_REG_EIP,STOP+0x100);return
        else:raise AssertionError(('Unexpected API',name,hex(a)))
        u.reg_write(UC_X86_REG_EAX,result);u.reg_write(UC_X86_REG_ESP,sp+4+(n*4 if n>0 else 0))
        u.reg_write(UC_X86_REG_EIP,ret)
    def call(self,name,args):
        sp=STACK+0x18000;self.u.mem_write(sp,words(STOP,*args));self.u.reg_write(UC_X86_REG_ESP,sp)
        self.u.reg_write(UC_X86_REG_FPCW,0x37f);self.u.reg_write(UC_X86_REG_MXCSR,0x1f80)
        self.u.emu_start(self.exports[name],STOP,count=30000000)
        assert self.u.reg_read(UC_X86_REG_EIP)==STOP
        return self.u.reg_read(UC_X86_REG_EAX)
    def prepare(self,mode=2):
        self.mode=mode
        return bool(self.call('points_prepare',[BASE,len(self.image),mode])&255)
    def status(self):return struct.unpack('<20I',self.u.mem_read(self.exports['skeet_nl_points_status'],80))
    def run(self,caller=1,hitbox=0,shift=0,special=0,offset=0,consume=False,existing=0,pose_z=0):
        self.pose_z=pose_z
        u=self.u;parent_sp=STACK+0x11000+offset
        site,cont=(0x433341ca,0x433341cf) if caller==0 else (0x4335e9d0,0x4335e9d5)
        out=parent_sp+(0x240 if caller==0 else 0x26c)
        record=DATA+0x10000;box=DATA+0x20000;desc=DATA+0x21000;eye=DATA+0x22000;middle=DATA+0x23000
        u.mem_write(out,b'\xa5'*0x80)
        u.mem_write(out,words(out+16,out+16,out+16+72,0))
        main=parent_sp+0x1250
        u.mem_write(main,b'\x5a'*(16+112*24+16))
        u.mem_write(main,words(main+16,main+16+existing*24,main+16+112*24,0))
        for i in range(existing):u.mem_write(main+16+i*24,floats(i,1,2,1)+words(3,9))
        main_before=bytes(u.mem_read(main+12,112*24+20))
        existing_bytes=bytes(u.mem_read(main+16,existing*24))
        u.mem_write(box,bytes(0x44));u.mem_write(box+4,words(1 if hitbox==0 else 3))
        u.mem_write(box+8,floats(0,0,60,0,0,65));u.mem_write(box+0x30,floats(4))
        u.mem_write(desc,bytes(0x90));u.mem_write(desc,words(hitbox,box))
        u.mem_write(desc+0x48,floats(0,0,60+pose_z,0,0,65+pose_z));u.mem_write(desc+0x70,floats(4))
        u.mem_write(eye,floats(-100,0,64));u.mem_write(middle,floats(0,0,62.5+pose_z))
        u.mem_write(record,bytes(0x1000))
        for i in range(3):
            m=record+(hitbox+31)*48+i*0x3a0
            u.mem_write(m,floats(1,0,0,0,0,1,0,shift if i==2 else 0,0,0,1,pose_z))
        u.mem_write(parent_sp-20,words(record,desc,middle,out,special))
        u.reg_write(UC_X86_REG_ESP,parent_sp-20);u.reg_write(UC_X86_REG_ECX,eye);u.reg_write(UC_X86_REG_EDX,DATA+0x24000)
        regs=[UC_X86_REG_EBX,UC_X86_REG_ESI,UC_X86_REG_EDI,UC_X86_REG_EBP]
        values=[0x12345678,desc,record-0xf0,parent_sp+0x1000]
        for reg,value in zip(regs,values):u.reg_write(reg,value)
        u.reg_write(UC_X86_REG_FPCW,0x37f);u.reg_write(UC_X86_REG_MXCSR,0x1f80)
        stop_hook=u.hook_add(UC_HOOK_CODE,lambda uc,a,s,d:uc.emu_stop(),begin=cont,end=cont)
        try:u.emu_start(site,cont,count=1000000)
        finally:u.hook_del(stop_hook)
        assert u.reg_read(UC_X86_REG_EIP)==cont,'Bridge did not return to the native caller'
        assert u.reg_read(UC_X86_REG_ESP)==parent_sp,'Wrong fastcall argument cleanup'
        assert [u.reg_read(r) for r in regs]==values,'Nonvolatile register corruption'
        assert bytes(u.mem_read(out+0x58,0x80-0x58))==b'\xa5'*(0x80-0x58),'Adjacent stack was overwritten'
        begin,end,cap=struct.unpack('<III',u.mem_read(out,12));count=(end-begin)//24
        assert 0<=count<=(13 if getattr(self,'mode',2)==6 else 10)
        points=[struct.unpack('<4fII',u.mem_read(begin+i*24,24)) for i in range(count)]
        assert all(p[3:]==(1.0,1 if hitbox==0 else 3,3) for p in points)
        baseline=floats(0,4,65+pose_z,1)+words(1 if hitbox==0 else 3,3)
        if self.native_count and count:assert bytes(u.mem_read(begin,24))==baseline,'First native candidate lost'
        if self.native_count==2 and count:assert points[1][:3]==(0.0,-4.0,65.0+pose_z),'Second native candidate lost'
        if begin!=out+16:
            main_begin,main_end,main_cap=struct.unpack('<III',u.mem_read(main,12))
            assert main_cap-main_begin==256*24 and main_end-main_begin==existing*24
            assert bytes(u.mem_read(main_begin,existing*24))==existing_bytes
            assert bytes(u.mem_read(main+12,112*24+20))==main_before
        if consume and count and caller==1:
            # Execute the real parent's dynamic point-count/mean loop. Stop
            # immediately before its unrelated entity and configuration reads.
            self.store(parent_sp+0x48,24)
            snapshots={}
            gprs=[UC_X86_REG_EAX,UC_X86_REG_EBX,UC_X86_REG_ECX,UC_X86_REG_EDX,
                  UC_X86_REG_ESI,UC_X86_REG_EDI,UC_X86_REG_EBP,UC_X86_REG_ESP]
            xmm=[UC_X86_REG_XMM0,UC_X86_REG_XMM1,UC_X86_REG_XMM2,UC_X86_REG_XMM3,
                 UC_X86_REG_XMM4,UC_X86_REG_XMM5,UC_X86_REG_XMM6,UC_X86_REG_XMM7]
            def snapshot(uc,address,size,data):
                snapshots[address]=([uc.reg_read(r) for r in gprs],[uc.reg_read(r) for r in xmm],
                    uc.reg_read(UC_X86_REG_FPCW),uc.reg_read(UC_X86_REG_MXCSR),uc.reg_read(UC_X86_REG_EFLAGS))
            first=u.hook_add(UC_HOOK_CODE,snapshot,begin=0x4335ea97,end=0x4335ea97)
            second=u.hook_add(UC_HOOK_CODE,snapshot,begin=0x4335ea9f,end=0x4335ea9f)
            stop_hook=u.hook_add(UC_HOOK_CODE,lambda uc,a,s,d:uc.emu_stop(),begin=0x4335eaba,end=0x4335eaba)
            try:u.emu_start(cont,0x4335eaba,count=10000)
            finally:
                for h in [stop_hook,first,second]:u.hook_del(h)
            before,after=snapshots[0x4335ea97],snapshots[0x4335ea9f]
            assert before[0]==after[0] and before[2:4]==after[2:4],'Primary-center shim corrupted registers/FP control'
            assert before[4]&~0x8d5==after[4]&~0x8d5
            for i,(a,b) in enumerate(zip(before[1],after[1])):
                assert a>>32==b>>32
                if i not in [5,6,7]:assert a==b
            assert u.reg_read(UC_X86_REG_EIP)==0x4335eaba
            average=struct.unpack('<3f',u.mem_read(parent_sp+0x254,12))
            expected=[0,0,65+pose_z]
            assert max(abs(a-b) for a,b in zip(average,expected))<.0001,(average,expected)
        return points,(begin,end,cap)

def main():
    m=Machine();assert m.prepare()
    patched=bytes(m.u.mem_read(BASE,len(m.image)))
    h=0x811c9dc5
    for b in patched[0xe000:0xe000+0x105b12]:h=((h^b)*0x1000193)&0xffffffff
    assert m.word(m.exports['points_sealed_hash'])==h^0x92ca5df1
    cases=0
    for caller in [1]:
        for hitbox,expected in [(0,9),(3,5),(6,6)]:
            p,_=m.run(caller,hitbox,consume=caller==1);assert len(p)==expected,(caller,hitbox,p);cases+=1
    before=m.status()[13];p,_=m.run(shift=50);assert len(p)==2 and m.status()[13]==before+1;cases+=1
    p,_=m.run(shift=2);assert 2<len(p)<9;cases+=1
    assert len(m.run(existing=20)[0])==9;cases+=1
    m.u.mem_write(m.exports['skeet_nl_points_status']+40,words(1))
    p,_=m.run();assert len(p)==7;cases+=1
    m.u.mem_write(m.exports['skeet_nl_points_status']+40,words(0))
    before=len(m.original_calls);assert len(m.run(special=1)[0])==2;assert len(m.original_calls)==before+1;cases+=1
    before=len(m.original_calls);assert len(m.run(hitbox=2)[0])==2;assert len(m.original_calls)==before+1;cases+=1
    # Different OS threads and nested native vector addresses keep live data separate.
    m.thread=1;p1,v1=m.run(offset=0x100);saved=bytes(m.u.mem_read(v1[0],9*24))
    m.thread=2;p2,v2=m.run(offset=0x100);assert v1[0]!=v2[0];cases+=1
    m.thread=1;p3,v3=m.run(offset=0x300);assert v1[0]!=v3[0]
    assert bytes(m.u.mem_read(v1[0],9*24))==saved;cases+=1
    for fault in ['heap','set']:
        x=Machine(fault);assert x.prepare();x.run();assert len(x.original_calls)==1;cases+=1
    for fault in ['fls','flush','flush_core','allocate','protect']:
        x=Machine(fault);assert not x.prepare();assert bytes(x.u.mem_read(BASE,len(x.image)))==x.image;cases+=1
    x=Machine();assert x.prepare(0);assert bytes(x.u.mem_read(BASE,len(x.image)))==x.image;cases+=1
    x=Machine();x.u.mem_write(BASE+0x4e9d0,b'\x90');assert not x.prepare();cases+=1
    x=Machine();assert x.prepare()
    for i in range(8):assert len(x.run(offset=i*0x100)[0])==9
    assert len(x.run(offset=8*0x100)[0])==2
    assert x.status()[7]==1 and len(x.original_calls)==9;cases+=1
    x=Machine();x.native_count=0;assert x.prepare();assert not x.run()[0] and x.status()[4]==0;cases+=1
    x=Machine();x.native_body=True;assert x.prepare()
    assert len(x.run(hitbox=3,consume=True)[0])==5;cases+=1
    assert bytes(m.u.mem_read(0x433341ca,5))==m.image[0x241ca:0x241cf]
    before=len(m.original_calls);m.run(caller=0);assert len(m.original_calls)==before+1;cases+=1
    x=Machine();assert x.prepare();x.run()
    main=STACK+0x11000+0x1250;start=x.word(main);source=DATA+0x70000
    for i in range(200):
        x.u.mem_write(source,floats(i,1,2,1)+words(1,3))
        sp=STACK+0x1000;x.u.mem_write(sp,words(STOP,0,source));x.u.reg_write(UC_X86_REG_ESP,sp)
        x.u.reg_write(UC_X86_REG_ECX,main);x.u.emu_start(0x4332325f,STOP,count=1000)
        assert x.u.reg_read(UC_X86_REG_ESP)==sp+12
    assert x.word(main+4)==start+200*24 and x.word(main+8)==start+256*24
    assert struct.unpack('<f',x.u.mem_read(start+199*24,4))[0]==199;cases+=1
    report={'passed':True,'compiled_x86_cases':cases,'actual_gs_intersections_executed':m.intersections,
            'calls':m.status()[3],'native_fallback_dispatch_tested':True,'actual_original_body_generator_cases':1,
            'original_head_generator_mocked':True,'native_candidates_retained':True,
            'empty_nl_retains_original_candidates':True,'native_primary_center_preserved':True,
            'primary_center_shim_gpr_sse_and_fp_control_preserved':True,
            'native_consumer_processed_more_than_three_points':True,'native_checksum_after_patching':True,
            'stack_and_nonvolatile_registers_preserved':True,'thread_and_nested_storage_separate':True,
            'native_main_append_tested_points':200,'main_capacity':256,
            'patched_callers':['0x4335e9d0'],'other_caller_left_native':True,
            'gameplay_tested':False,'scope':__doc__}
    (ROOT/'reports/points_bridge_validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))
if __name__=='__main__':main()
