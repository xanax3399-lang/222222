from pathlib import Path
import hashlib,json,zipfile
ROOT=Path(__file__).resolve().parent
readme='''Skeet v2 / CS:GO Legacy 8802 / NL points

Распакуйте все файлы в одну папку. Запустите injector.exe и выберите 2
(NL points, также выбирается по Enter). Командный запуск:
    injector.exe --mode nl-points
Счётчики активного модуля:
    injector.exe --diagnostics

skeet_nl_points.ini: head_scale_percent и body_scale_percent — 0..100;
reduced_head=1 оставляет пять точек головы вместо семи. Настройки читаются
при загрузке DLL; для изменения нужно полностью перезапустить игру.

NL-геометрия подключена к проверенному пути сканирования GS. Сохраняются
проверки пересечения трёх матриц, метаданные, штатные урон/hitchance/выбор
цели и точки GS. Другой путь сканирования и специальные позы остаются GS.
Автоматический масштаб NL по оружию и полный выбор точки NL не перенесены.

Это экспериментальная DLL: CI проверяет сборку, загрузку в Windows и x86
переходник с родными функциями GS. Запуск на карте CS:GO не проверен.
При сбое сохраняются skeet_crash.log и loader_last.log рядом с файлами.
'''
config='[points]\nhead_scale_percent=80\nbody_scale_percent=80\nreduced_head=0\n'
out=ROOT/'build/skeet-v2-nl-points-windows.zip'
files={n:(ROOT/'build'/n).read_bytes() for n in ['skeet.dll','injector.exe']}
files.update({'README_RU.txt':readme.encode('utf-8-sig'),'skeet_nl_points.ini':config.encode()})
for name in ['points_bridge_validation.json','points_validation.json','points_dll_validation.json']:
    files['reports/'+name]=(ROOT/'reports'/name).read_bytes()
files['SHA256SUMS.json']=(json.dumps({n:hashlib.sha256(v).hexdigest() for n,v in files.items()},indent=2)+'\n').encode()
with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED) as archive:
    for name,raw in files.items():archive.writestr(name,raw)
print(out.name,hashlib.sha256(out.read_bytes()).hexdigest())
