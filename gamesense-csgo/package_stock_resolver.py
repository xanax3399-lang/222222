from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parent
BUILD = ROOT / 'build'
DEST = BUILD / 'skeet-stock-resolver'
DEST.mkdir(exist_ok=True)
for name in ('skeet.dll', 'injector.exe'):
    shutil.copy2(BUILD / name, DEST / name)
for name in ('stock_resolver.lua', 'README_RU.txt'):
    shutil.copy2(ROOT / 'stock-resolver' / name, DEST / name)
(DEST / 'skeet_nl_points.ini').write_text('''[points]
head_scale_percent=80
body_scale_percent=80
reduced_head=0
[movement]
nl_brake=0
[v3]
head_crown=0
head_crown_percent=95
late_eye_guard=0
unsafe_dt_recharge=0
[loader]
automatic_reports=0
''', encoding='utf-8')
reports = DEST / 'reports'
reports.mkdir(exist_ok=True)
for name in ('model', 'driver', 'pe'):
    source = BUILD / ('stock_resolver_' + name + '_validation.json')
    assert source.exists(), source
    shutil.copy2(source, reports / source.name)
sha = os.environ.get('GITHUB_SHA') or subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
(DEST / 'build_info.json').write_text(json.dumps({
    'source_commit': sha, 'github_run': os.environ.get('GITHUB_RUN_ID'),
    'resolver': 'C++ model inside skeet.dll + explicit GameSense Lua driver',
    'game': 'CS:GO Legacy 8802 x86', 'gameplay_tested': False,
}, indent=2) + '\n')
hashes = {str(p.relative_to(DEST)): hashlib.sha256(p.read_bytes()).hexdigest()
          for p in sorted(DEST.rglob('*')) if p.is_file() and p.name != 'SHA256SUMS.json'}
(DEST / 'SHA256SUMS.json').write_text(json.dumps(hashes, indent=2) + '\n')
archive = BUILD / 'skeet-stock-resolver-windows.zip'
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as output:
    for p in sorted(DEST.rglob('*')):
        if p.is_file(): output.write(p, str(p.relative_to(DEST)))
print(archive)
