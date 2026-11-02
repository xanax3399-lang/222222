"""Exercise the real HTTP and certificate-verified WSS server. Only owns its child."""
import base64,json,os,socket,ssl,subprocess,sys,tempfile,time,urllib.request
from pathlib import Path
binary=Path(sys.argv[1]).resolve()
opener=urllib.request.build_opener(urllib.request.ProxyHandler({}))
def request(path):
    with opener.open('http://127.0.0.1:30031'+path,timeout=2) as response:
        assert response.status==200
        return response.read()
try:
    request('/health')
except Exception:
    pass
else:
    raise SystemExit('Port 30031 is already occupied; stop your own server before this test.')
with tempfile.TemporaryDirectory(prefix='nl-server-check-') as folder:
    root=Path(folder);env=os.environ.copy();env.update(NL_CLOUD_PATH=str(root/'cloud'),WS_TLS='true',RUST_LOG='error')
    with (root/'server.log').open('wb') as log:
        child=subprocess.Popen([str(binary)],cwd=root,env=env,stdout=log,stderr=log)
        try:
            until=time.monotonic()+20
            while True:
                if child.poll() is not None:raise RuntimeError('Server exited before readiness: '+str(child.returncode))
                try:
                    assert request('/health')==b'neverlose-csgo-local-v1'
                    assert (root/'certs/cert.pem').exists()
                    break
                except Exception:
                    if time.monotonic()>until:raise RuntimeError('Server readiness timeout')
                    time.sleep(.1)
            json.loads(request('/api/items'))
            assert len(request('/api/reqitem?name=base64'))>1000
            context=ssl.create_default_context(cafile=str(root/'certs/cert.pem'))
            with socket.create_connection(('127.0.0.1',30030),timeout=3) as raw:
                with context.wrap_socket(raw,server_hostname='127.0.0.1') as conn:
                    key=base64.b64encode(os.urandom(16)).decode()
                    conn.sendall(('GET / HTTP/1.1\r\nHost: 127.0.0.1:30030\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: '+key+'\r\nSec-WebSocket-Version: 13\r\n\r\n').encode())
                    assert b'101 Switching Protocols' in conn.recv(4096)
            print('PASS: health, config API, embedded Lua library, certificate-verified WSS handshake')
        finally:
            child.terminate()
            try:child.wait(timeout=5)
            except subprocess.TimeoutExpired:child.kill();child.wait()
