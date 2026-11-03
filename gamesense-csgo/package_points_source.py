"""Package source and evidence only. No claim of a gameplay DLL build."""
from pathlib import Path
import hashlib
import json
import zipfile

ROOT=Path(__file__).resolve().parent
out=ROOT/'build/skeet-v2-nl-points-source.zip'
out.parent.mkdir(exist_ok=True)
files=[]
for directory in ['source','tests','recovery','reports']:
    for p in (ROOT/directory).rglob('*'):
        rel=p.relative_to(ROOT)
        if p.is_file() and '__pycache__' not in rel.parts and p.suffix not in ['.log','.pyc']:
            files.append(p)
files.extend(ROOT/name for name in ['README_RU.md','ARCHIVE_README_RU.md','archive_baseline.json',
             'build_windows.py','requirements-build.txt','package_points_source.py'])
assert all(p.suffix.lower() not in ['.dll','.exe'] for p in files)
manifest={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(files)}
with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED) as archive:
    for p in sorted(files):archive.write(p,'skeet-v2-nl-points/'+str(p.relative_to(ROOT)))
    archive.writestr('skeet-v2-nl-points/PACKAGE_SHA256.json',json.dumps(manifest,indent=2)+'\n')
print(out.name,hashlib.sha256(out.read_bytes()).hexdigest())
