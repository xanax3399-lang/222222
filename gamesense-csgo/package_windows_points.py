from pathlib import Path
import hashlib,json,zipfile
ROOT=Path(__file__).resolve().parent
readme='''Skeet v2 / CS:GO Legacy 8802 / NL points

Распакуйте все файлы в одну папку. Запустите injector.exe и выберите 2
(NL points, также выбирается по Enter). Командный запуск:
    injector.exe --mode nl-points
Счётчики активного модуля:
    injector.exe --diagnostics
Либо пункт 5: отчёт сохраняется рядом с injector.exe в module_diagnostics.log,
а окно ждёт Enter. Папка reports содержит тесты сборки, не игровые счётчики.

skeet_nl_points.ini: head_scale_percent и body_scale_percent — 0..100;
reduced_head=1 оставляет пять точек головы вместо семи. Настройки читаются
при загрузке DLL; для изменения нужно полностью перезапустить игру.

[movement] nl_brake=1 подключает расчёт тормозного импульса NL к общей
остановке GS в режимах 2 и 4. GS определяет момент остановки, выполняет трение
и передаёт эффективные параметры движения/оружия. Полный контроллер autostop/
quick stop NL не перенесён. Более ранний выстрел пока не подтверждён.
nl_brake=0 возвращает прежнее торможение GS, сохраняя точки NL. После изменения
полностью перезапустите CS:GO. Пункт 5 показывает GS brake samples и NL brake applied.

NL-геометрия подключена к проверенному пути сканирования GS. Сохраняются
проверки пересечения трёх матриц, метаданные, штатные урон/hitchance/выбор
цели и точки GS. Другой путь сканирования и специальные позы остаются GS.
Автоматический масштаб NL по оружию и полный выбор точки NL не перенесены.

В этой версии исходные точки GS остаются в списке, точки NL добавляются к ним.
Если точек NL нет или они отфильтрованы, исходные кандидаты не удаляются.
Центр, который GS использует в дальнейших проверках, остаётся исходным.
Минимальный урон и hitchance не снижаются. После обновления полностью закройте
CS:GO и используйте новую пару injector.exe + skeet.dll из этого архива.

Это экспериментальная DLL: CI проверяет сборку, загрузку в Windows и x86
переходник с родными функциями GS. Запуск на карте CS:GO не проверен.
При сбое сохраняются skeet_crash.log и loader_last.log рядом с файлами.
'''
config='[points]\nhead_scale_percent=80\nbody_scale_percent=80\nreduced_head=0\n\n[movement]\nnl_brake=1\n'
out=ROOT/'build/skeet-v2-nl-points-windows.zip'
files={n:(ROOT/'build'/n).read_bytes() for n in ['skeet.dll','injector.exe']}
files.update({'README_RU.txt':readme.encode('utf-8-sig'),'skeet_nl_points.ini':config.encode()})
for name in ['points_bridge_validation.json','points_validation.json','points_dll_validation.json',
             'stop_math_validation.json','stop_bridge_validation.json']:
    files['reports/'+name]=(ROOT/'reports'/name).read_bytes()
files['SHA256SUMS.json']=(json.dumps({n:hashlib.sha256(v).hexdigest() for n,v in files.items()},indent=2)+'\n').encode()
with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED) as archive:
    for name,raw in files.items():archive.writestr(name,raw)
print(out.name,hashlib.sha256(out.read_bytes()).hexdigest())
