#!/usr/bin/env python3
"""Run compiled crash reporter with bounded file/memory WinAPI fixtures.

No Windows crash or game is triggered. Invalid memory is handled by mocked
ReadProcessMemory just as a failed bounded read, not by dereferencing pointers.
"""
import hashlib,json,struct,re
from unicorn import UcError
from unicorn.x86_const import *
from validate_hypotheses import Machine,ROOT,BASE,DATA,PEBASE,STACK,STOP

class Reporter(Machine):
    def __init__(self,image,path_ok=True,file_ok=True):
        super().__init__(image);self.path_ok=path_ok;self.file_ok=file_ok
        self.text=bytearray();self.created=[];self.closed=0;self.flushed=0;self.reads=[]
    def word(self,address):return struct.unpack('<I',self.uc.mem_read(address,4))[0]
    def store(self,address,value):self.uc.mem_write(address,struct.pack('<I',value&0xffffffff))
    def wide(self,address):
        result=bytearray()
        for i in range(32768):
            b=bytes(self.uc.mem_read(address+i*2,2))
            if b==b'\0\0':return result.decode('utf-16le')
            result+=b
        raise AssertionError('unterminated path')
    def string(self,address):
        result=bytearray()
        for i in range(4096):
            b=bytes(self.uc.mem_read(address+i,1))
            if b==b'\0':return result.decode()
            result+=b
        raise AssertionError('unterminated text')
    def format_runtime(self,format_address,arguments):
        # UCRT's formatting boundary is stubbed, not the reporter's fields,
        # pointer validation, file handling, or actual argument construction.
        fmt=self.string(format_address);position=0;result=''
        pattern=re.compile(r'%([0 ]?)(\d*)(l?)([Xxuds%])')
        for match in pattern.finditer(fmt):
            assert '%' not in fmt[position:match.start()]
            result+=fmt[position:match.start()];position=match.end()
            flag,width,length,kind=match.groups()
            if kind=='%':value='%'
            else:
                word=self.word(arguments);arguments+=4
                if kind=='s':value=self.string(word)
                elif kind=='d':value=str(word if word<0x80000000 else word-0x100000000)
                elif kind=='u':value=str(word)
                elif kind=='X':value=format(word,'X')
                else:value=format(word,'x')
            if width:value=value.rjust(int(width),'0' if flag=='0' else ' ')
            result+=value
        assert '%' not in fmt[position:]
        return (result+fmt[position:]).encode()
    def runtime(self,u,address,size,user):
        name=self.imports.get(address);sp=u.reg_read(UC_X86_REG_ESP);ret=self.word(sp)
        argc=0;result=0
        args=lambda n:[self.word(sp+4+i*4) for i in range(n)]
        if name=='GetModuleFileNameW':
            argc=3;module,dest,length=args(3);assert module==PEBASE and length==32768
            if self.path_ok:
                path='C:\\Test\\skeet.dll';u.mem_write(dest,(path+'\0').encode('utf-16le'));result=len(path)
        elif name=='CreateFileW':
            argc=7;path,access,share,security,creation,flags,template=args(7)
            self.created.append(self.wide(path))
            assert self.created[-1]=='C:\\Test\\skeet_crash.log'
            assert (access,share,security,creation,flags,template)==(0x40000000,1,0,2,0x80,0)
            result=0x900 if self.file_ok else 0xffffffff
        elif name=='WriteFile':
            argc=5;handle,buffer,length,written,overlap=args(5)
            assert handle==0x900 and length<=767 and overlap==0
            self.text+=u.mem_read(buffer,length);self.store(written,length);result=1
        elif name=='GetCurrentThreadId':result=77
        elif name=='wcsrchr':
            source,char=args(2);offset=self.wide(source).rfind(chr(char))
            result=source+offset*2 if offset>=0 else 0
        elif name=='wcscpy':
            dest,source=args(2);u.mem_write(dest,(self.wide(source)+'\0').encode('utf-16le'));result=dest
        elif name=='GetCurrentProcess':result=0xffffffff
        elif name=='ReadProcessMemory':
            argc=5;process,source,dest,length,got=args(5);assert process==0xffffffff and length<=256
            try:content=bytes(u.mem_read(source,length));result=1
            except UcError:content=b''
            if content:u.mem_write(dest,content)
            self.store(got,len(content));self.reads.append((source,length,bool(result)))
        elif name=='FlushFileBuffers':argc=1;assert args(1)==[0x900];self.flushed+=1;result=1
        elif name=='CloseHandle':argc=1;assert args(1)==[0x900];self.closed+=1;result=1
        elif name=='__stdio_common_vsprintf':
            options,dest,capacity,fmt,locale,arguments=struct.unpack('<QIIIII',u.mem_read(sp+4,28))
            assert not locale and capacity==768
            text=self.format_runtime(fmt,arguments);result=len(text)
            u.mem_write(dest,text[:capacity-1]+b'\0')
            argc=0 # C runtime is __cdecl: caller removes all arguments.
        else:raise AssertionError(('unexpected reporter import',name,hex(address)))
        u.reg_write(UC_X86_REG_EAX,result);u.reg_write(UC_X86_REG_ESP,sp+4+4*argc);u.reg_write(UC_X86_REG_EIP,ret)
    def call(self,name,args):
        u=self.uc;sp=STACK+0x18000
        u.mem_write(sp,struct.pack('<'+'I'*(len(args)+1),STOP,*args));u.reg_write(UC_X86_REG_ESP,sp)
        u.reg_write(UC_X86_REG_EFLAGS,2)
        u.emu_start(self.exports[name],STOP,count=3000000)
        assert u.reg_read(UC_X86_REG_EIP)==STOP
        return u.reg_read(UC_X86_REG_EAX)&255

def main():
    image=(ROOT/'source/skeet/Binary/skeet.bin').read_bytes();cases=[]
    for name,path_ok,file_ok,code,eip,esp,expected in [
        ('reported AV address',True,True,0xc0000005,0x433d5f12,DATA+0x9000,True),
        ('unreadable code and stack',True,True,0xc0000005,0xdead1000,0xdead0000,True),
        ('other exception ignored',True,True,0x80000003,0x433d5f12,DATA+0x9000,False),
        ('path unavailable',False,True,0xc0000005,0x433d5f12,DATA+0x9000,False),
        ('file unavailable',True,False,0xc0000005,0x433d5f12,DATA+0x9000,False),
    ]:
        r=Reporter(image,path_ok,file_ok)
        r.call('probe_crash_initialize',[PEBASE])
        r.uc.mem_write(r.exports['skeet_nl_hypotheses_status'],struct.pack('<10i',1,1,1,123,120,3,2,444,0,0))
        actual=bool(r.call('probe_crash_snapshot',[code,eip,0xdead0020,esp,0,0x21f4be2a]))
        assert actual==expected,(name,actual,expected)
        if actual:
            text=r.text.decode()
            for fragment in ['exception=C0000005','ecx=DEAD0020','access_kind=0 target=21F4BE2A',
                             'mode=1 installed=1 calls=123 supplied=120 rejected=3','last_bridge_best_effort:']:
                assert fragment in text,(name,fragment,text)
            assert r.flushed==1 and r.closed==1
            if eip==0x433d5f12:assert 'index_locals_at_esp_plus_1A0' in text
            else:assert 'read_ok=0' in text
        else:assert not r.text and not r.closed and not r.flushed
        cases.append({'case':name,'report_written':actual,'bounded_memory_reads':len(r.reads)})
    header=ROOT/'source/skeet/crash_report.h'
    report={'passed':True,'cases':cases,'scope':__doc__,'ucrt_formatting_stubbed':True,
            'production_header_sha256':hashlib.sha256(header.read_bytes()).hexdigest(),
            'game_runtime_tested':False,'crash_root_cause_confirmed':False}
    (ROOT/'build/crash_report_validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print('5 compiled crash-reporter fixtures passed, including unreadable memory and file/path failures.')
if __name__=='__main__':main()
