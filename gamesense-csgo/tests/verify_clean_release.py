#!/usr/bin/env python3
"""Inspect built PE files and packaged resources without executing the cheat."""
from pathlib import Path
import hashlib
import json
import struct
import pefile

ROOT = Path(__file__).resolve().parents[1]

def sha(data):
    return hashlib.sha256(data).hexdigest()

def inspect(name, dll):
    path = ROOT/'build'/name
    pe = pefile.PE(str(path))
    assert pe.FILE_HEADER.Machine == 0x14c, name
    assert pe.OPTIONAL_HEADER.Magic == 0x10b, name
    assert pe.is_dll() == dll, name
    entry = pe.get_section_by_rva(pe.OPTIONAL_HEADER.AddressOfEntryPoint)
    assert entry is not None and entry.Characteristics & 0x20000000, name
    assert pe.OPTIONAL_HEADER.DllCharacteristics & 0x140 == 0x140, name
    assert getattr(pe, 'DIRECTORY_ENTRY_BASERELOC', []), name
    imports = {i.dll.decode(): [s.name.decode() if s.name else s.ordinal for s in i.imports]
               for i in pe.DIRECTORY_ENTRY_IMPORT}
    assert not any(n.lower().startswith(('libc++','libstdc++','libgcc','vcruntime','msvcp')) for n in imports)
    return pe, {'file':name, 'bytes':path.stat().st_size, 'sha256':sha(path.read_bytes()),
                'format':'Windows x86 PE32', 'imports':imports, 'warnings':pe.get_warnings()}

def main():
    dll, dll_report = inspect('skeet.dll', True)
    injector, injector_report = inspect('injector.exe', False)
    exports = {x.name.decode(): x.address for x in dll.DIRECTORY_ENTRY_EXPORT.symbols if x.name}
    assert 'skeet_loader_status' in exports
    # Zig's statically linked C++ exception runtime exports libunwind entrypoints.
    # These are compiler support symbols, not optional addon/gameplay exports.
    assert 'skeet_nl_hypotheses_status' in exports
    assert all(name in ('skeet_loader_status','skeet_nl_hypotheses_status') or name.startswith(('_Unwind_', 'unw_'))
               for name in exports), exports
    status = dll.get_data(exports['skeet_loader_status'], 256)
    assert struct.unpack_from('<III', status) == (1, 0, 0)
    assert b'Waiting for game modules\0' in status
    hypothesis_status=dll.get_data(exports['skeet_nl_hypotheses_status'],40)
    assert struct.unpack('<10i',hypothesis_status)==(1,0,0,0,0,0,-1,0,0,0)
    expected = {('BINARY',102):ROOT/'source/skeet/Binary/skeet.bin',
                ('BYTECODE',103):ROOT/'source/skeet/VM/bytecode.json',
                ('EXPORTS',101):ROOT/'source/skeet/Binary/exports.json'}
    resources = []
    for kind in dll.DIRECTORY_ENTRY_RESOURCE.entries:
        for item in kind.directory.entries:
            key = str(kind.name), item.id
            assert key in expected, key
            for lang in item.directory.entries:
                data = dll.get_data(lang.data.struct.OffsetToData, lang.data.struct.Size)
                assert data == expected[key].read_bytes(), key
                resources.append({'type':key[0], 'id':key[1], 'bytes':len(data), 'sha256':sha(data)})
    assert len(resources) == 3
    manifest = json.loads((ROOT/'reports/cleanup_manifest.json').read_text())
    assert sha(expected[('BINARY',102)].read_bytes()) == manifest['retained_core_sha256']
    assert not any((ROOT/p).exists() for p in manifest['removed_source_files'])
    main_source = (ROOT/'source/skeet/skeet.cpp').read_text()
    for module in ['scan_patch', 'precision_patch', 'motion_patch', 'body_preference_patch',
                   'crouch_multipoint_patch', 'hitchance_override_patch', 'cs2_visuals']:
        assert module+'::' not in main_source
        assert '#include "'+module+'.h"' not in main_source
    assert 'cs2_visuals_impl' not in (ROOT/'source/skeet/saver.cpp').read_text()
    assert not (ROOT/'source/lua').exists()
    linked = (ROOT/'build/skeet.dll').read_bytes()
    for marker in [b'Gameplay patch installation failed:', b'clover_cs2_ui_8802',
                   'Crouch multipoint\0'.encode('utf-16le'),
                   'Enemy ESP preview\0'.encode('utf-16le')]:
        assert marker not in linked, marker
    # Check all local quoted includes, including non-compiled source project headers.
    import re
    for p in (ROOT/'source').rglob('*'):
        if p.suffix.lower() not in ['.h','.cpp']: continue
        for target in re.findall(r'^\s*#include\s+"([^"]+)"',p.read_text(errors='replace'),re.M):
            local = p.parent/target
            shared = ROOT/'source/skeet'/target
            assert local.exists() or shared.exists(), (str(p),target)
    report = {'passed':True, 'artifacts':[dll_report,injector_report], 'resources':resources,
              'exports':sorted(exports), 'removed_optional_source_files':len(manifest['removed_source_files']),
              'embedded_core_byte_identical_to_supplied':True,
              'previous_optional_gameplay_installers_removed':True, 'custom_presentation_removed':True,
              'new_optional_module':'NL no-history animation-hypothesis adapter; not a full resolver',
              'embedded_lua_addon_removed':True, 'loader_compatibility_retained':True,
              'windows_runtime_tested':False, 'game_runtime_tested':False,
              'accuracy_improvement_measured':False}
    (ROOT/'build/experimental_release_validation.json').write_text(json.dumps(report,indent=2)+'\n')
    print('PE32/resources/include closure/old installer removal/new diagnostic export: passed')

if __name__ == '__main__':
    main()
