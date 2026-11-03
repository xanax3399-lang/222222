#!/usr/bin/env python3
"""Execute the production Windows overlay resolver in Unicorn with stubbed WinAPI.
This does not execute the cheat, an injector, Windows DllMain, or a running game.
"""
from pathlib import Path
import json
import hashlib
import struct
import pefile
from unicorn import Uc, UC_ARCH_X86, UC_MODE_32, UC_HOOK_CODE
from unicorn.x86_const import UC_X86_REG_ESP, UC_X86_REG_EIP, UC_X86_REG_EAX

ROOT = Path(__file__).resolve().parents[1]
OVERLAY = 0x28000000
STACK = 0x70000000
API = 0x71000000
STOP = 0x72000000
OUTPUT = 0x73000000
RETURN = [0x3d,None,None,None,None,0x73,0x1a,0x68,None,None,None,None,0xe8,None,None,None,None,
          0x8b,0x0d,None,None,None,None,0x83,0xc4,0x04,0x8b,0x01,0x6a,0x00,0xff,0x50,0x14,0x3b,None,0x3c]
RET_BYTES = bytes(0x55 if x is None else x for x in RETURN)
RET_OFFSET = 0x4000 - len(RETURN)
REF_OFFSET = 0x1100

def overlay_image():
    b = bytearray(0x6000)
    b[:2] = b'MZ'
    struct.pack_into('<I', b, 0x3c, 0x80)
    b[0x80:0x84] = b'PE\0\0'
    struct.pack_into('<HHIIIHH', b, 0x84, 0x14c, 2, 0, 0, 0, 224, 0x2102)
    o = 0x98
    struct.pack_into('<H', b, o, 0x10b)
    struct.pack_into('<I', b, o+28, OVERLAY)
    struct.pack_into('<II', b, o+32, 0x1000, 0x200)
    struct.pack_into('<II', b, o+56, len(b), 0x1000)
    s = o+224
    b[s:s+8] = b'.text\0\0\0'
    struct.pack_into('<III', b, s+8, 0x3000, 0x1000, 0x3000)
    struct.pack_into('<I', b, s+36, 0x60000020)
    b[s+40:s+48] = b'.data\0\0\0'
    struct.pack_into('<III', b, s+48, 0x1000, 0x4000, 0x1000)
    struct.pack_into('<I', b, s+76, 0xc0000040)
    b[RET_OFFSET:RET_OFFSET+len(RETURN)] = RET_BYTES
    b[REF_OFFSET:REF_OFFSET+10] = b'\x89\x1d'+struct.pack('<I', OVERLAY+0x4100)+b'\xf3\x0f\x10\x83'
    return b

class Machine:
    def __init__(self, base, image, regions=None, module=True):
        self.base = base
        pe = pefile.PE(str(ROOT/'build/overlay_probe.dll'))
        pe.relocate_image(base)
        self.uc = uc = Uc(UC_ARCH_X86, UC_MODE_32)
        uc.mem_map(base, (pe.OPTIONAL_HEADER.SizeOfImage+4095)&~4095)
        uc.mem_write(base, pe.get_memory_mapped_image())
        self.probe = base + next(x.address for x in pe.DIRECTORY_ENTRY_EXPORT.symbols if x.name == b'probe')
        for address, size in [(STACK,0x10000),(API,0x10000),(STOP,0x1000),(OUTPUT,0x1000),(OVERLAY,0x6000)]:
            uc.mem_map(address,size)
        uc.mem_write(OVERLAY, bytes(image))
        self.regions = regions or [(0,0x1000,2),(0x1000,0x3000,0x20),(0x4000,0x1000,4),(0x5000,0x1000,1)]
        self.module = module
        self.calls = []
        self.apis = {}
        index = 0
        for library in pe.DIRECTORY_ENTRY_IMPORT:
            for function in library.imports:
                address = API + 16*index
                index += 1
                self.apis[address] = function.name.decode() if function.name else str(function.ordinal)
                uc.mem_write(base + function.address - base, struct.pack('<I',address))
        uc.hook_add(UC_HOOK_CODE, self.api, begin=API, end=API+0xffff)
    def api(self, uc, address, size, _):
        sp = uc.reg_read(UC_X86_REG_ESP)
        ret = struct.unpack('<I',uc.mem_read(sp,4))[0]
        name = self.apis[address]
        self.calls.append(name)
        if name == 'GetModuleHandleW':
            argc, result = 1, OVERLAY if self.module else 0
        elif name == 'VirtualQuery':
            argc = 3
            pointer, output, length = struct.unpack('<III', uc.mem_read(sp+4,12))
            assert length == 28
            region = next((r for r in self.regions if OVERLAY+r[0] <= pointer < OVERLAY+r[0]+r[1]), None)
            result = 0
            if region:
                start, n, protection = region
                uc.mem_write(output,struct.pack('<7I',OVERLAY+start,OVERLAY,2,n,0x1000,protection,0x1000000))
                result = 28
        else:
            raise AssertionError('Unexpected WinAPI/CRT use in resolver: '+name)
        uc.reg_write(UC_X86_REG_EAX,result)
        uc.reg_write(UC_X86_REG_ESP,sp+4+4*argc)
        uc.reg_write(UC_X86_REG_EIP,ret)
    def run(self):
        sp = STACK+0xff00
        self.uc.mem_write(sp,struct.pack('<II',STOP,OUTPUT))
        self.uc.reg_write(UC_X86_REG_ESP,sp)
        self.uc.emu_start(self.probe,STOP,count=3000000)
        assert self.uc.reg_read(UC_X86_REG_EIP)==STOP,'Resolver instruction budget exceeded'
        ok = self.uc.reg_read(UC_X86_REG_EAX)
        ret,ref,message = struct.unpack('<III', self.uc.mem_read(OUTPUT,12))
        if ok:
            assert ret == OVERLAY+RET_OFFSET and ref == OVERLAY+0x4100 and message == 0
        else:
            assert ret == 0 and ref == 0 and message != 0
        return bool(ok)

def main():
    cases = []
    for base in [0x10000000,0x12000000]:
        def check(name, expected, change=None, **kwargs):
            image = overlay_image()
            if change: change(image)
            machine = Machine(base,image,**kwargs)
            assert machine.run() == expected, name
            cases.append({'base':hex(base),'case':name,'accepted':expected})
        check('exact screenshot profile with signature ending at section boundary',True)
        for modrm in [0x5f,0x7b,0x83,0xff]:
            check('wildcard ModRM '+hex(modrm),True,lambda b,v=modrm: b.__setitem__(RET_OFFSET+len(RETURN)-2,v))
        check('missing overlay',False,module=False)
        check('missing return signature',False,lambda b: b.__setitem__(RET_OFFSET,0x90))
        check('missing reference signature',False,lambda b: b.__setitem__(REF_OFFSET,0x90))
        check('ambiguous return signature',False,lambda b: b.__setitem__(slice(0x1200,0x1200+len(RETURN)),RET_BYTES))
        check('ambiguous reference signature',False,lambda b: b.__setitem__(slice(0x1300,0x130a),b[REF_OFFSET:REF_OFFSET+10]))
        check('reference operand outside image',False,lambda b: struct.pack_into('<I',b,REF_OFFSET+2,0x1234))
        check('reference operand in inaccessible page',False,lambda b: struct.pack_into('<I',b,REF_OFFSET+2,OVERLAY+0x5000))
        check('guarded text section',False,regions=[(0,0x1000,2),(0x1000,0x3000,0x120),(0x4000,0x1000,4)])
        check('invalid DOS header',False,lambda b: b.__setitem__(0,0))
        check('invalid NT header',False,lambda b: b.__setitem__(0x80,0))
        check('wrong machine x64',False,lambda b: struct.pack_into('<H',b,0x84,0x8664))
        check('section outside image',False,lambda b: struct.pack_into('<I',b,0x178+8,0x6000))
    report = {'passed':True,'resolver_cases':len(cases),'execution_environment':'Unicorn x86 with controlled WinAPI stubs',
              'windows_loader_tested':False,'game_tested':False,'cases':cases,
              'probe_sha256':hashlib.sha256((ROOT/'build/overlay_probe.dll').read_bytes()).hexdigest(),
              'production_header_sha256':hashlib.sha256((ROOT/'source/skeet/overlay_loader.h').read_bytes()).hexdigest()}
    (ROOT/'build/resolver_validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(f'{len(cases)} production Windows resolver cases passed at two image bases.')
if __name__=='__main__': main()
