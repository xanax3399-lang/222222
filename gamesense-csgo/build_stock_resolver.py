"""Build the stock wrapper with its native model and matching launcher."""
import os
import build_windows as base
from pathlib import Path
R=base.ROOT;B=base.BUILD;Z=base.ZIG
# Includes the same pinned-resource check as the established wrapper build.
import re
raw=(R/'source/skeet/Binary/skeet.bin').read_bytes();value=0xcbf29ce484222325
for byte in raw:value=((value^byte)*0x100000001b3)&0xffffffffffffffff
expected=int(re.search(r'image_fingerprint\s*=\s*(0x[0-9a-fA-F]+)ULL',(R/'source/skeet/core_image.h').read_text()).group(1),16)
assert value==expected
compat=[]if os.name=='nt'else ['-I',R/'source/compat']
base.run('resources','rc','/fo',B/'skeet.res','/I',Z/'lib/libc/include/any-windows-any','/I',R/'source/compat','skeet.rc',cwd=R/'source/skeet')
common=['c++','-target','x86-windows-gnu','-std=c++23','-O1','-fno-fast-math','-ffp-contract=off','-fms-extensions','-fasm-blocks','-DUNICODE','-D_UNICODE','-D_CRT_SECURE_NO_WARNINGS',*compat,'-I',R/'source/skeet']
base.run('stock-dll',*common,'-shared',R/'source/skeet/skeet.cpp',R/'source/skeet/saver.cpp',R/'source/skeet/dllmain.cpp',R/'stock-resolver/exports.cpp',B/'skeet.res','-luser32','-ladvapi32','-lpsapi','-o',B/'skeet.dll')
base.run('stock-injector','c++','-target','x86-windows-gnu','-std=c++23','-O2','-DUNICODE','-D_UNICODE',*compat,'-municode',R/'source/steam/steam.cpp','-ladvapi32','-lshell32','-o',B/'injector.exe')
base.run('stock-mode-probe',*common,R/'stock-resolver/mode_probe.cpp','-luser32','-o',B/'stock_mode_probe.exe')
print('Built skeet.dll with integrated resolver and injector.exe. Lua driver remains explicit.')
