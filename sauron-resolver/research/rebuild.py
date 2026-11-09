from pathlib import Path
import subprocess,sys
R=Path(__file__).resolve().parent
for step in ['extract.py','normalize_sigma.py','opcode_map.py','prepare.py','lift.py','JAVA','structure_source.py','finalize.py','verify.py']:
 with (R/(step+'.log')).open('w')as log:
  if step=='JAVA':
   with (R/'source.raw.lua').open('w')as out:
    subprocess.run(['java','-jar',str(R/'unluac-recovery.jar'),str(R/'recovered.luac')],stdout=out,stderr=log,check=True,cwd=R)
  else:subprocess.run([sys.executable,str(R/step)],stdout=log,stderr=subprocess.STDOUT,check=True,cwd=R)
 print('Passed',step,flush=True)
