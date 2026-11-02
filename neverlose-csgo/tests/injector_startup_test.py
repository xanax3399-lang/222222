"""Windows regressions for double-click exits. Never injects a DLL into a process."""
from pathlib import Path
import os,shutil,subprocess,sys,tempfile,time
assert os.name=='nt'
release=Path(sys.argv[1] if len(sys.argv)>1 else 'Release').resolve()
def log_text(root):
    p=root/'injector.log'
    return p.read_text(encoding='utf-8',errors='replace') if p.exists() else ''
def wait_for(child,root,needle):
    end=time.monotonic()+15
    while time.monotonic()<end:
        if needle in log_text(root):return
        if child.poll() is not None:raise AssertionError('Injector closed unexpectedly: '+log_text(root))
        time.sleep(.1)
    raise AssertionError('Diagnostic stage not reached: '+needle)
with tempfile.TemporaryDirectory(prefix='nl-startup-') as folder:
    root=Path(folder);exe=root/'injector.exe';shutil.copy2(release/'injector.exe',exe)
    def check(*args):return subprocess.run([str(exe),*args,'--no-pause'],cwd=root,stdin=subprocess.DEVNULL,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=15)
    result=check('--check')
    assert result.returncode!=0 and 'Missing neverlose.dll' in log_text(root)
    assert 'stage=validate_dll' in log_text(root)
    print('PASS: missing DLL has a persistent diagnostic')
    child=subprocess.Popen([str(exe)],cwd=root,creationflags=subprocess.CREATE_NEW_CONSOLE)
    try:
        wait_for(child,root,'Awaiting Enter after error')
        time.sleep(.3);assert child.poll() is None,'Double-click console closed before the error could be read'
    finally:
        if child.poll() is None:child.terminate()
        child.wait(timeout=10)
    print('PASS: new-console launch keeps startup errors visible')
    (root/'neverlose.dll').write_bytes(b'not-a-dll')
    result=check('--check')
    assert result.returncode!=0 and 'Invalid neverlose.dll' in log_text(root)
    print('PASS: invalid DLL has a specific diagnostic')
    shutil.copy2(release/'neverlose.dll',root/'neverlose.dll')
    result=check('--check')
    assert result.returncode==0 and 'stage=preflight_complete' in log_text(root)
    print('PASS: real DLL passes preflight without starting the game')
    result=check('--no-wait')
    assert result.returncode!=0 and 'CS:GO Legacy is not running' in log_text(root)
    child=subprocess.Popen([str(exe)],cwd=root,stdin=subprocess.PIPE,stdout=subprocess.DEVNULL,stderr=subprocess.STDOUT)
    try:
        wait_for(child,root,'Waiting for csgo.exe; the injector stays open')
        time.sleep(.4);assert child.poll() is None,'Default launch exited instead of waiting for the game'
    finally:
        if child.poll() is None:child.terminate()
        child.wait(timeout=10)
    print('PASS: default launch waits for CS:GO instead of closing')
