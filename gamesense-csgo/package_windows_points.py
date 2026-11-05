from pathlib import Path
import argparse,hashlib,json,zipfile,os
parser=argparse.ArgumentParser();parser.add_argument('--v3',action='store_true');args=parser.parse_args()
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
if args.v3:
    readme='''Skeet v3 / CS:GO Legacy 8802

GS + NL API BRIDGE 0.1.1
Это частичная совместимость с публичным NL CS:GO Lua API, не полный API NL.
Инструкция: GSNL_README_RU.md. Справочник: GSNL_API.md и gsnl_api_manifest.json.
Загрузчик и пример находятся в lua/. Самому мосту не требуется Lua FFI.
DLL регистрирует нативный модуль gsnl_native на штатном этапе инициализации Lua.
API GS сохраняется. Новых хуков стрельбы/DT мост не добавляет.

Пункт 2 сохраняет поведение v2. Пункт 3 включает v3: дополнительные точки головы,
проверку после коррекции точки выстрела; recharge DT по умолчанию штатный GS. Командный запуск:
    injector.exe --mode v3-patches
Это собственный геометрический патч, а не полный перенос сканера NL.
Проверки трёх матриц, урон и hitchance GS сохраняются. Реальная видимость и
попадания на карте здесь не проверены. Интерполяция/экстраполяция не изменены.
Полные autostop/quick stop NL ещё не перенесены; сохраняется импульс NL из v2.

[v3] head_crown=0 отключает патч; head_crown_percent=95 задаёт масштаб 50..99.
late_eye_guard=1 повторяет HC GS перед автоматическим выстрелом только если
после исходной проверки изменилась точка выстрела или выбранная точка цели.
Если новая проверка не проходит HC или даёт 0, GS не выставляет атаку.
Это оценка клиента, а не гарантия промаха/попадания на сервере. Отправленную
пулю отменить нельзя. Ручная атака, отпускание DT и уже начатая очередь исключены.
ИСПРАВЛЕНИЕ RECHARGE DT
unsafe_dt_recharge=0 по умолчанию: дополнительный обход recharge не установлен,
зарядом управляет штатный GS. Сам DT продолжает работать.
Прежний патч мог обходить ожидание незавершённого выстрела и задержку после
выстрела; этот обход удалён. Даже если оставить старый INI с параметром =1,
новая DLL сохраняет обе штатные проверки. Эксперимент теперь может обходить
только aim/peek-блокировку после них, на земле, без приседа/прыжка и команд
движения. Отпускание DT, очередь, attack/choke, предел и накопление заряда остаются
штатными. Мгновенный recharge поверх незавершённого DT больше не форсируется.
Это собственная ограниченная политика GS, а не полный перенос Neverlose.
Для проверки поведения по умолчанию используй новый INI либо пункт 7 → 3 → OFF.
late_eye_guard=0 / unsafe_dt_recharge=0 независимо отключают новые изменения.
После изменения INI полностью перезапустите CS:GO. Пункт 5 сохраняет счётчики
V3 head crown, Fire guard и Recharge в module_diagnostics.log. Старые гипотезы анимации теперь в пункте 6.
Используйте новую пару DLL + инжектор. Исходный архив v2 сохранён отдельно.

ОТЧЁТ БЕЗ РУЧНОГО ПОИСКА
После успешного запуска лоудер сам сохраняет module_diagnostics.log и обновляет
его отдельным фоновым процессом раз в 10 секунд до закрытия CS:GO. Он только
читает счётчики нашей DLL; приоритет/настройки игры не меняет. Последний живой
отчёт остаётся после выхода. Пункт 8 открывает свежий отчёт в редакторе.
Если папка лоудера недоступна для записи, используется
%LOCALAPPDATA%\\GameSenseLegacy8802\\Reports; пункт 8 находит и этот вариант.
Пункт 7 переключает Head crown / Late HC / экспериментальный early recharge / автосохранение
отчёта. Флаги сохраняются в INI; после изменения полностью перезапустите CS:GO.
Для обычной игры по-прежнему достаточно выбрать 2 или 3. Пункт 5 оставлен
для разового отчёта вручную. Эти счётчики не определяют причину aim_miss.

''' + readme
    config+='\n[v3]\nhead_crown=1\nhead_crown_percent=95\nlate_eye_guard=1\nunsafe_dt_recharge=0\n\n[loader]\nautomatic_reports=1\nreport_interval_seconds=10\nnative_api_bridge=1\n'
out=ROOT/('build/skeet-v3-patches-windows.zip' if args.v3 else 'build/skeet-v2-nl-points-windows.zip')
files={n:(ROOT/'build'/n).read_bytes() for n in ['skeet.dll','injector.exe']}
files.update({'README_RU.txt':readme.encode('utf-8-sig'),'skeet_nl_points.ini':config.encode()})
for name in ['points_bridge_validation.json','points_validation.json','points_dll_validation.json',
             'stop_math_validation.json','stop_bridge_validation.json']:
    files['reports/'+name]=(ROOT/'reports'/name).read_bytes()
if args.v3:
    for name in ['v3_head_validation.json','v3_fire_validation.json','api_bridge_validation.json','lua_native_validation.json']:
        files['reports/'+name]=(ROOT/'reports'/name).read_bytes()
    for name in ['gsnl.lua','gsnl_example.lua']:
        files['lua/'+name]=(ROOT/'lua'/name).read_bytes()
    for name in ['GSNL_API.md','gsnl_api_manifest.json']:
        files[name]=(ROOT/'build'/name).read_bytes()
    files['GSNL_README_RU.md']=(ROOT/'api/README_RU.md').read_bytes()
    files['api/gsnl_native.h']=(ROOT/'source/api_bridge/native.h').read_bytes()
    files['api/lua_native.h']=(ROOT/'source/api_bridge/lua_native.h').read_bytes()
if args.v3:files['BUILD_INFO.json']=(json.dumps({'series':'v3','source_commit':os.environ.get('GITHUB_SHA'),
    'frozen_v2_base':'72aa34f0956c619ba5f24c9e5c19c6dabf7fd7ff',
    'v3_patches':['record_head_crown','late_eye_hitchance_guard','guarded_dt_recharge'],
    'automatic_reports':True,'loader_patch_switches':True,
    'api_bridge_revision':1,'api_bridge_version':'0.1.1','full_neverlose_api':False,
    'api_bootstrap_revision':3,'native_lua_preload_module':True,
    'gs_ffi_module_required':False,'gs_ffi_load_required':False,'gs_ffi_external_resolution_required':False,
    'real_gamesense_lua_loader_tested':False,
    'shooting_source_base':'bb2cce750ec83af2d6596303046b2a0521c98639',
    'dt_recharge_revision':2,'early_recharge_default':False,
    'native_pending_shot_and_cooldown_retained':True,
    'full_nl_recharge_port':False,
    'full_nl_stop_controller_ported':False,'interpolation_extrapolation_changed':False,
    'gameplay_tested':False},indent=2)+'\n').encode()
files['SHA256SUMS.json']=(json.dumps({n:hashlib.sha256(v).hexdigest() for n,v in files.items()},indent=2)+'\n').encode()
with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED) as archive:
    for name,raw in files.items():archive.writestr(name,raw)
print(out.name,hashlib.sha256(out.read_bytes()).hexdigest())
