#!/usr/bin/env python3
"""Cross-compile the wrapper with optional NL animation hypotheses.

Install requirements-build.txt first. Requires no MSVC SDK download.
This produces Windows x86 binaries; it does not run the game or inject anything.
"""
from pathlib import Path
import os
import subprocess
import sys
import re
import ziglang
from generate_api_bridge import generate as generate_api_bridge

ROOT = Path(__file__).resolve().parent
ZIG = Path(ziglang.__file__).parent
BUILD = ROOT / 'build'
BUILD.mkdir(exist_ok=True)
env = os.environ.copy()
env.setdefault('ZIG_GLOBAL_CACHE_DIR', str(ROOT / '.cache/global'))
env.setdefault('ZIG_LOCAL_CACHE_DIR', str(ROOT / '.cache/local'))

def run(label, *args, cwd=ROOT):
    print(label, flush=True)
    log = BUILD / (label + '.log')
    with log.open('w') as output:
        proc = subprocess.run([sys.executable, '-m', 'ziglang', *map(str, args)],
                              cwd=cwd, env=env, stdout=output, stderr=subprocess.STDOUT)
    if proc.returncode:
        print(log.read_text(errors='replace')[-12000:])
        raise SystemExit(proc.returncode)

def main():
    generate_api_bridge()
    # Validate the exact resource choice before invoking the compiler.
    # Keep the expected value pinned in the production header; do not regenerate
    # it automatically from arbitrary replacement bytes.
    header = (ROOT/'source/skeet/core_image.h').read_text()
    expected = int(re.search(r'image_fingerprint\s*=\s*(0x[0-9a-fA-F]+)ULL', header).group(1), 16)
    raw = (ROOT/'source/skeet/Binary/skeet.bin').read_bytes()
    actual = 0xcbf29ce484222325
    for value in raw:
        actual = ((actual ^ value) * 0x100000001b3) & 0xffffffffffffffff
    if actual != expected:
        raise SystemExit(f'Core/header fingerprint mismatch: {actual:016x} != {expected:016x}')
    run('resources', 'rc', '/fo', BUILD/'skeet.res', '/I', ZIG/'lib/libc/include/any-windows-any',
        '/I', ROOT/'source/compat', 'skeet.rc', cwd=ROOT/'source/skeet')
    compatibility = [] if os.name == 'nt' else ['-I', ROOT/'source/compat']
    common = ['c++', '-target', 'x86-windows-gnu', '-std=c++23', '-O1', '-fno-fast-math', '-ffp-contract=off', '-fms-extensions',
              '-fasm-blocks', '-DUNICODE', '-D_UNICODE', '-D_CRT_SECURE_NO_WARNINGS',
              *compatibility, '-I', ROOT/'source/skeet']
    run('dll', *common, '-shared', ROOT/'source/skeet/skeet.cpp', ROOT/'source/skeet/saver.cpp',
        ROOT/'source/skeet/dllmain.cpp', ROOT/'source/api_bridge/native.cpp', '-I', BUILD,
        BUILD/'skeet.res', '-luser32', '-ladvapi32', '-lpsapi',
        '-o', BUILD/'skeet.dll')
    run('injector', 'c++', '-target', 'x86-windows-gnu', '-std=c++23', '-O2',
        '-DUNICODE', '-D_UNICODE', *compatibility, '-municode', ROOT/'source/steam/steam.cpp',
        '-ladvapi32', '-lshell32', '-o', BUILD/'injector.exe')
    run('launcher-reports-probe', 'c++', '-target', 'x86-windows-gnu', '-std=c++23', '-O2',
        '-DUNICODE', '-D_UNICODE', *compatibility, '-municode', ROOT/'tests/launcher_reports_probe.cpp',
        '-ladvapi32', '-lshell32', '-o', BUILD/'launcher_reports_probe.exe')
    run('probe', 'c++', '-target', 'x86-windows-gnu', '-std=c++17', '-O2', '-shared',
        *compatibility, ROOT/'tests/overlay_probe.cpp', '-lkernel32', '-o', BUILD/'overlay_probe.dll')
    run('core-probe', 'c++', '-target', 'x86-windows-gnu', '-std=c++17', '-O2', '-shared',
        ROOT/'tests/core_image_probe.cpp', '-o', BUILD/'core_image_probe.dll')
    run('hypotheses-probe', 'c++', '-target', 'x86-windows-gnu', '-std=c++17', '-O2',
        '-fno-fast-math', '-ffp-contract=off', '-shared', ROOT/'tests/hypotheses_probe.cpp',
        '-lkernel32', '-o', BUILD/'hypotheses_probe.dll')
    run('points-bridge-probe', *common, '-shared', ROOT/'tests/points_bridge_probe.cpp',
        '-o', BUILD/'points_bridge_probe.dll')
    run('stop-bridge-probe', *common, '-shared', ROOT/'tests/stop_bridge_probe.cpp',
        '-o', BUILD/'stop_bridge_probe.dll')
    run('fire-bridge-probe', *common, '-shared', ROOT/'tests/fire_bridge_probe.cpp',
        '-o', BUILD/'fire_bridge_probe.dll')
    if os.name != 'nt':
        run('hypotheses-host-probe', 'c++', '-std=c++17', '-O2', '-fno-fast-math',
            '-ffp-contract=off', '-shared', '-fPIC', ROOT/'tests/hypotheses_probe.cpp',
            '-o', BUILD/'hypotheses_probe.so')
    print('Built build/skeet.dll and build/injector.exe. Game runtime validation is separate.')

if __name__ == '__main__':
    main()
