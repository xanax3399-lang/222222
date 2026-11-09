"""Add Windows evidence to the exact tested ZIP, validate and refresh hashes."""
from pathlib import Path
import hashlib
import json
import os
import sys
import tempfile
import zipfile

archive, evidence = map(Path, sys.argv[1:])
report = json.loads(evidence.read_text())
assert report['abi']['actual_packaged_x86_dll_loaded'] is True
assert report['legacy_patch_guards'] == [0, 8] and report['injector_cli_checked'] is True
assert report['native_driver']['production_native_driver'] is True
assert report['native_driver']['external_lua_required'] is False
with tempfile.TemporaryDirectory() as temp:
    folder = Path(temp)
    with zipfile.ZipFile(archive) as source:
        for name in source.namelist():
            assert not Path(name).is_absolute() and '..' not in Path(name).parts
        source.extractall(folder)
    original = json.loads((folder / 'SHA256SUMS.json').read_text())
    for name, digest in original.items():
        assert hashlib.sha256((folder / name).read_bytes()).hexdigest() == digest, name
    info = json.loads((folder / 'build_info.json').read_text())
    assert info['source_commit'] == os.environ['GITHUB_SHA']
    assert info['external_lua_required'] is False and not list(folder.rglob('*.lua'))
    (folder / 'reports' / evidence.name).write_bytes(evidence.read_bytes())
    hashes = {str(p.relative_to(folder)): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in sorted(folder.rglob('*')) if p.is_file() and p.name != 'SHA256SUMS.json'}
    (folder / 'SHA256SUMS.json').write_text(json.dumps(hashes, indent=2) + '\n')
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED, compresslevel=9) as output:
        for p in sorted(folder.rglob('*')):
            if p.is_file(): output.write(p, str(p.relative_to(folder)))
print('Final release validated: original DLL bytes preserved, Windows evidence added.')
