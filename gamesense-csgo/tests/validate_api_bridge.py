"""Run the actual embedded source and bootstrap in LuaJIT with controlled GS APIs."""
from pathlib import Path
import sys,subprocess,json,hashlib,ctypes
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT))
from generate_api_bridge import generate
from lupa.luajit21 import LuaRuntime
m=generate()
out=ROOT/'build/api_bridge_host.so'
subprocess.run(['g++','-std=c++17','-O2','-shared','-fPIC','-fno-fast-math','-ffp-contract=off','-Wall','-Wextra','-Werror',
    '-I',str(ROOT/'build'),str(ROOT/'tests/api_bridge_host.cpp'),'-o',str(out)],check=True)
lib=ctypes.CDLL(str(out));lib.gsnl_snapshot.argtypes=[ctypes.c_void_p,ctypes.c_uint]
assert lib.gsnl_snapshot(None,72)==0
buf=(ctypes.c_ubyte*80)(*([0xA5]*80));assert lib.gsnl_snapshot(buf,71)==0 and bytes(buf)==b'\xA5'*80
assert lib.gsnl_snapshot(buf,72)==1 and bytes(buf)[72:]==b'\xA5'*8
runtime=LuaRuntime(unpack_returned_tuples=True)
runtime.globals().HOST_LIBRARY=str(out)
runtime.globals().BOOTSTRAP=str(ROOT/'lua/gsnl.lua')
checks=runtime.execute((ROOT/'tests/api_bridge_contract.lua').read_text())
rows=m['neverlose'];assert len(rows)==328
assert all(rows[n]['status']=='unavailable' for n in ['rage_exploit:force_charge','rage_exploit:force_teleport','entity:get_anim_state','utils.net_channel'])
report={'luajit_contract_assertions':checks,'native_buffer_guard_cases':3,'reference_symbols':len(rows),
    'supported':sum(r['status']=='supported' for r in rows.values()),'partial':sum(r['status']=='partial' for r in rows.values()),
    'unavailable':sum(r['status']=='unavailable' for r in rows.values()),
    'source_sha256':hashlib.sha256((ROOT/'build/gsnl_embedded.lua').read_bytes()).hexdigest(),
    'native_math_and_embedded_source_executed':True,'host_globals_preserved':True,
    'missing_module_and_exports_rejected':True,'controlled_gs_api_fixtures':True,'gameplay_tested':False}
report.update({'ffi_load_disabled':True,'ffi_C_external_resolution_disabled':True,
    'os_library_absent':True,'native_preload_module_controlled_fixture':True,
    'ffi_module_required':False,'own_module_signature_scanning_required':False})
(ROOT/'reports/api_bridge_validation.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
