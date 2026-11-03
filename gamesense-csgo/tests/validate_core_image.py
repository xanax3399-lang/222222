#!/usr/bin/env python3
"""Run the production fingerprint code against the resource of the actual DLL.

This executes only a pure header probe in Unicorn, not DllMain or the cheat.
"""
from pathlib import Path
import hashlib
import json
import struct
import pefile
from unicorn import Uc, UC_ARCH_X86, UC_MODE_32
from unicorn.x86_const import UC_X86_REG_EAX, UC_X86_REG_ESP, UC_X86_REG_EIP

ROOT = Path(__file__).resolve().parents[1]

def embedded_core():
    dll = pefile.PE(str(ROOT/'build/skeet.dll'))
    resources = []
    for kind in dll.DIRECTORY_ENTRY_RESOURCE.entries:
        if str(kind.name) != 'BINARY':
            continue
        for item in kind.directory.entries:
            if item.id != 102:
                continue
            for lang in item.directory.entries:
                resources.append(dll.get_data(lang.data.struct.OffsetToData, lang.data.struct.Size))
    assert len(resources) == 1
    data = resources[0]
    assert data == (ROOT/'source/skeet/Binary/skeet.bin').read_bytes()
    return data

def execute(data, size, null=False):
    base, address, stack, stop = 0x10000000, 0x50000000, 0x70000000, 0x71000000
    pe = pefile.PE(str(ROOT/'build/core_image_probe.dll'))
    pe.relocate_image(base)
    uc = Uc(UC_ARCH_X86, UC_MODE_32)
    uc.mem_map(base, (pe.OPTIONAL_HEADER.SizeOfImage+4095)&~4095)
    uc.mem_write(base, pe.get_memory_mapped_image())
    uc.mem_map(address, (len(data)+4095)&~4095)
    uc.mem_write(address, bytes(data))
    uc.mem_map(stack, 0x10000)
    uc.mem_map(stop, 0x1000)
    sp = stack+0xff00
    uc.mem_write(sp, struct.pack('<III', stop, 0 if null else address, size))
    uc.reg_write(UC_X86_REG_ESP, sp)
    exported = next(s.address for s in pe.DIRECTORY_ENTRY_EXPORT.symbols
                    if s.name and s.name.lstrip(b'_') == b'core_matches')
    uc.emu_start(base+exported, stop, count=200000000)
    assert uc.reg_read(UC_X86_REG_EIP) == stop, 'Fingerprint probe did not return'
    return bool(uc.reg_read(UC_X86_REG_EAX))

def main():
    data = embedded_core()
    cases = []
    def check(name, payload, size, expected, **kw):
        actual = execute(payload, size, **kw)
        assert actual == expected, (name, actual, expected)
        cases.append({'case':name,'accepted':actual})
    check('resource from actual rebuilt DLL', data, len(data), True)
    check('null pointer', data, len(data), False, null=True)
    check('truncated size', data, len(data)-1, False)
    check('oversized input', data+b'\0', len(data)+1, False)
    changed = bytearray(data)
    changed[0x1ffb1] ^= 1
    check('single changed instruction byte', changed, len(changed), False)
    changed = bytearray(data)
    changed[-1] ^= 1
    check('single changed final byte', changed, len(changed), False)
    report = {'passed':True,'cases':cases,'execution_environment':'Unicorn x86, production fingerprint header',
              'actual_dll_resource_sha256':hashlib.sha256(data).hexdigest(),
              'probe_sha256':hashlib.sha256((ROOT/'build/core_image_probe.dll').read_bytes()).hexdigest(),
              'production_header_sha256':hashlib.sha256((ROOT/'source/skeet/core_image.h').read_bytes()).hexdigest(),
              'game_runtime_tested':False}
    (ROOT/'build/core_image_validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print(f'{len(cases)} production fingerprint cases passed against the actual DLL resource.')

if __name__ == '__main__':
    main()
