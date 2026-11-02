"""Windows-only: launch the actual embedded server without loading any game DLL."""
from pathlib import Path
import os,shutil,subprocess,sys,tempfile,time,urllib.request
assert os.name=='nt','This check must run on Windows'
exe=Path(sys.argv[1]).resolve()
opener=urllib.request.build_opener(urllib.request.ProxyHandler({}))
def health():
    with opener.open('http://127.0.0.1:30031/health',timeout=1) as r:
        return r.status==200 and r.read()==b'neverlose-csgo-local-v1'
try:
    if health():raise SystemExit('A server is already running; refusing to interfere')
except SystemExit:raise
except Exception:pass
with tempfile.TemporaryDirectory(prefix='nl-injector-test-') as folder:
    root=Path(folder);copy=root/'injector.exe';shutil.copy2(exe,copy)
    with (root/'injector.log').open('wb') as log:
        child=subprocess.Popen([str(copy),'--server-only'],cwd=root,stdin=subprocess.PIPE,stdout=log,stderr=log)
        try:
            deadline=time.monotonic()+30
            while True:
                if child.poll() is not None:raise RuntimeError('Embedded-server injector exited early: '+str(child.returncode))
                try:
                    if health():break
                except Exception:pass
                if time.monotonic()>deadline:raise RuntimeError('Embedded server did not become ready')
                time.sleep(.15)
            child.communicate(b'\n',timeout=15)
            assert child.returncode==0,'Injector reported failure'
            deadline=time.monotonic()+5
            while True:
                try:running=health()
                except Exception:running=False
                if not running:break
                if time.monotonic()>deadline:raise RuntimeError('Owned server remained after injector exit')
                time.sleep(.1)
            print('PASS: injector extracted, launched and verified its embedded server, then stopped it on exit')
        finally:
            if child.poll() is None:child.kill();child.wait(timeout=10)
