"""Check actual PE32 outputs, core resource, API closure and diagnostic exports."""
from pathlib import Path
import hashlib,json,struct
import pefile
ROOT=Path(__file__).resolve().parents[1]
reports=[]
for name,is_dll in [('skeet.dll',True),('injector.exe',False)]:
    raw=(ROOT/'build'/name).read_bytes();pe=pefile.PE(data=raw)
    assert pe.FILE_HEADER.Machine==0x14c and pe.OPTIONAL_HEADER.Magic==0x10b and pe.is_dll()==is_dll
    assert pe.OPTIONAL_HEADER.DllCharacteristics&0x140==0x140
    imports={lib.dll.decode().lower():[i.name.decode() if i.name else str(i.ordinal) for i in lib.imports] for lib in pe.DIRECTORY_ENTRY_IMPORT}
    assert not any(n.startswith(('libc++','libstdc++','libgcc','vcruntime','msvcp')) for n in imports)
    if is_dll:
        exports={i.name.decode():i.address for i in pe.DIRECTORY_ENTRY_EXPORT.symbols if i.name}
        for symbol in ['skeet_loader_status','skeet_nl_hypotheses_status','skeet_nl_points_status','skeet_nl_stop_status','skeet_v3_status','skeet_v3_fire_status']:assert symbol in exports
        assert struct.unpack('<21I',pe.get_data(exports['skeet_v3_fire_status'],84))==(1,1,0,*([0]*18))
        assert struct.unpack('<11I',pe.get_data(exports['skeet_v3_status'],44))==(1,1,95,*([0]*8))
        assert struct.unpack('<14I',pe.get_data(exports['skeet_nl_stop_status'],56))==(1,1,*([0]*12))
        assert struct.unpack('<20I',pe.get_data(exports['skeet_nl_points_status'],80))==(2,0,0,0,0,0,0,0,80,80,0,*([0]*9))
        symbols={s for entries in imports.values() for s in entries}
        assert {'FlsAlloc','FlsGetValue','FlsSetValue','FlsFree','HeapAlloc','HeapFree'}<=symbols
        core=[]
        for kind in pe.DIRECTORY_ENTRY_RESOURCE.entries:
            for item in kind.directory.entries:
                if item.id==102:
                    for lang in item.directory.entries:core.append(pe.get_data(lang.data.struct.OffsetToData,lang.data.struct.Size))
        assert len(core)==1 and core[0]==(ROOT/'source/skeet/Binary/skeet.bin').read_bytes()
    reports.append({'name':name,'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'imports':imports})
report={'passed':True,'files':reports,'core_resource_original':True,'gameplay_tested':False}
(ROOT/'reports/points_dll_validation.json').write_text(json.dumps(report,indent=2)+'\n')
print('PE32 DLL/injector, original core, NL points API and exports verified.')
