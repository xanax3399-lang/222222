from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parent
BUILD = ROOT / 'build'
DEST = BUILD / 'skeet-feedback-range'
if DEST.exists(): shutil.rmtree(DEST)
DEST.mkdir(exist_ok=True)
for name in ('skeet.dll', 'injector.exe'):
    shutil.copy2(BUILD / name, DEST / name)
for name in ('README_RU.txt',):
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
automatic_reports=1
[resolver]
enabled=1
confidence=65
fps_limit=0
feedback=1
feedback_learning=1
[accuracy]
final_check=1
nl_brake=1
dt_hc_samples64=1
dt_fast_sampler=1
dt_profile=1
''', encoding='utf-8')
reports = DEST / 'reports'
reports.mkdir(exist_ok=True)
for name in ('model', 'native_controller', 'native_contract', 'accuracy', 'dt', 'dt_fast', 'feedback', 'feedback_hook', 'yaw', 'pe'):
    source = BUILD / ('stock_resolver_' + name + '_validation.json')
    assert source.exists(), source
    shutil.copy2(source, reports / source.name)
sha = os.environ.get('GITHUB_SHA') or subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
(DEST / 'build_info.json').write_text(json.dumps({
    'source_commit': sha, 'github_run': os.environ.get('GITHUB_RUN_ID'),
    'resolver': 'Native C++ model, Source snapshots and GS player overrides inside skeet.dll',
    'external_lua_required': False,
    'accuracy_patch': 'NL braking arithmetic in native GS stop requests + final native HC validation on changed inputs',
    'dt_experiment': 'SCAR-20/G3SG1 active DT: promote native reduced 32-job HC to existing 64-job tier; unchanged threshold and recharge',
    'dt_sampler_optimization': 'Integer-only stack-scoped sampler; same 64 native jobs, sampled HC timing every 32 eligible calls',
    'resolver_feedback': 'Native shot intent + Source events; exact selected tick and model ownership; bounded state-specific positive evidence, ambiguous/unknown outcomes never penalized by the new learner',
    'source_bootstrap': 'Attach current Source FrameStageNotify without requiring a GS hook change; direct Source interfaces and native core clocks; Active only after observed callbacks',
    'eye_yaw_binding': 'Typed scalar/vector/float-array/nested RecvTable binding; unresolved yaw suspends the model while keeping frame/event logs',
    'netvar_offset_range': 'Checked full-width metadata offsets within 1 MiB; rejected eye properties remain observable; no fixed live yaw offset',
    'game': 'CS:GO Legacy 8802 x86', 'gameplay_tested': False,
}, indent=2) + '\n')
hashes = {str(p.relative_to(DEST)): hashlib.sha256(p.read_bytes()).hexdigest()
          for p in sorted(DEST.rglob('*')) if p.is_file() and p.name != 'SHA256SUMS.json'}
(DEST / 'SHA256SUMS.json').write_text(json.dumps(hashes, indent=2) + '\n')
archive = BUILD / 'skeet-feedback-range-windows.zip'
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as output:
    for p in sorted(DEST.rglob('*')):
        if p.is_file(): output.write(p, str(p.relative_to(DEST)))
print(archive)
