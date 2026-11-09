"""Check the real x86 deliverables and their exported driver ABI."""
from pathlib import Path
import json
import pefile

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / 'build'
required = {'sr_abi_version', 'sr_mode_enabled', 'sr_snapshot_bytes', 'sr_decision_bytes',
            'sr_reset', 'sr_forget', 'sr_feed', 'sr_head_hit', 'sr_stats', 'sr_history',
            'sr_frame', 'sr_frame_stats', 'skeet_loader_status', 'sr_driver_status'}
rows = []
for name, dll in [('skeet.dll', True), ('injector.exe', False), ('stock_mode_probe.exe', False), ('native_driver_probe.exe', False)]:
    pe = pefile.PE(str(BUILD / name))
    assert pe.FILE_HEADER.Machine == 0x14c and pe.OPTIONAL_HEADER.Magic == 0x10b, name
    assert bool(pe.FILE_HEADER.Characteristics & 0x2000) == dll, name
    exports = {e.name.decode('ascii') for e in getattr(pe, 'DIRECTORY_ENTRY_EXPORT', ()).symbols if e.name} if hasattr(pe, 'DIRECTORY_ENTRY_EXPORT') else set()
    if dll:
        assert required <= exports, sorted(required - exports)
    imports = {d.dll.decode('ascii').lower() for d in pe.DIRECTORY_ENTRY_IMPORT}
    assert not any(x.startswith(('msvcp', 'vcruntime', 'libgcc', 'libstdc++')) for x in imports), imports
    rows.append({'file': name, 'x86': True, 'imports': sorted(imports), 'resolver_exports': sorted(required & exports)})
report = {'artifacts': rows, 'gameplay_tested': False}
(BUILD / 'stock_resolver_pe_validation.json').write_text(json.dumps(report, indent=2) + '\n')
print('Actual x86 DLL/injector/probe PE imports and resolver exports verified.')
