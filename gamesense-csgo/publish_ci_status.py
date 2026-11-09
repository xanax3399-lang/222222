"""Publish bounded compiler evidence through git when local API logs are unavailable."""
from pathlib import Path
import json,os,subprocess
ROOT=Path(__file__).resolve().parent
def git(*args,data=None):
    return subprocess.check_output(['git',*args],input=data,cwd=ROOT.parent).decode().strip()
source=os.environ['GITHUB_SHA'];run=os.environ['GITHUB_RUN_ID']
status={'source':source,'run':run,'job_status':os.environ['CI_JOB_STATUS']}
logs=[]
for p in sorted((ROOT/'build').glob('*.log')):
    logs.append(p.name+'\n'+'\n'.join(p.read_text(errors='replace').splitlines()[-400:]))
payloads={'status.json':json.dumps(status,indent=2)+'\n','build.log':'\n\n'.join(logs)[-100000:]}
entries=[]
for name,value in payloads.items():
    blob=git('hash-object','-w','--stdin',data=value.encode())
    entries.append(f'100644 blob {blob}\t{name}\0')
tree=git('mktree','-z',data=''.join(entries).encode())
env=os.environ.copy()
env.update(GIT_AUTHOR_NAME='Codex',GIT_AUTHOR_EMAIL='codex@openai.com',GIT_COMMITTER_NAME='Codex',GIT_COMMITTER_EMAIL='codex@openai.com')
commit=subprocess.check_output(['git','commit-tree',tree,'-m',f'Build evidence for {source}'],cwd=ROOT.parent,env=env).decode().strip()
series=os.environ.get('SKEET_RELEASE_SERIES','v2')
if series not in ('v2','v3','stock-resolver'):raise ValueError('Invalid release series')
branch=f'codex/skeet-{series}-ci-{run}'
label=os.environ.get('SKEET_CI_LABEL','')
if label not in ('','windows'):raise ValueError('Invalid CI evidence label')
if label:branch+='-'+label
subprocess.run(['git','push','origin',f'{commit}:refs/heads/{branch}'],cwd=ROOT.parent,check=True)
print('Build evidence branch:',branch)
