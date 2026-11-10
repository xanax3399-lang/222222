from pathlib import Path
import json,hashlib,zipfile
R=Path(__file__).resolve().parent.parent
names=['emberlash_optimized.lua','README_PERFORMANCE_RU.md','optimization_validation.json']
(R/'DEPENDENCIES.json').write_bytes((R.parent/'DEPENDENCIES.json').read_bytes())
names.append('DEPENDENCIES.json')
manifest={name:hashlib.sha256((R/name).read_bytes()).hexdigest() for name in names}
(R/'SHA256SUMS.json').write_text(json.dumps(manifest,indent=2)+'\n')
with zipfile.ZipFile(R/'emberlash_optimized.zip','w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
 for name in [*names,'SHA256SUMS.json']:z.write(R/name,name)
print('Packaged', (R/'emberlash_optimized.zip').stat().st_size,'bytes')
