NEW SIGMA PRED — ОБЫЧНЫЙ ВОССТАНОВЛЕННЫЙ LUA-ИСХОДНИК

Основной файл: new_sigma_pred.full_source.lua.

Все 41 функции приложения представлены обычными Lua-функциями и замыканиями.
Убраны PSU VM, закодированный поток, диспетчер инструкций, r[N], up[N],
capture_upvalues, фабрики functions[N], goto и метки переходов.
Общие изменяемые данные передаются через настоящие лексические upvalue Lua.
Переходы представлены условиями и циклами; многозначные возвраты — локальными
наборами результатов. Имена основных функций и состояния определены по
использованию. Для неоднозначных промежуточных значений оставлены value_N.
Это реконструкция, а не точное восстановление авторских имён и комментариев.

Начальная подмена panorama.loadstring уже была в присланном оригинале и
сохранена. Проверка Steam ID, строки и логика приложения не удалялись.
Сетевая часть в процессе проверки не запускалась.

ПРОВЕРКИ

Синтаксис проверен в Lua 5.1 и LuaJIT 2.1.
С оригинальной VM совпали:
 - запуск с 57 элементами UI и 13 обработчиками;
 - 42 сценария обработчиков/интерфейса, всего 449 вызовов host API с запуском;
 - 344 случая математических и вспомогательных функций, включая nil, varargs
   и изменение общих данных. Файл native_test_factories.lua используется
   только для этих изолированных тестов, в основной исходник он не включён.

Отдельно проверены 27 запутанных переходов исходной VM. Они преобразованы
в обычное управление потоком. Проверки не доказывают все возможные ветви,
поведение на реальном сервере или качество стрельбы. В CS:GO не тестировалось.
Подробности: full_source_verification.json и отчёты *_validation.json.

НАВИГАЦИЯ

В основном файле можно искать имена:
  normalize_yaw, contains_value, head_coordinates, angles_to_direction,
  classify_movement, select_nearest_player, update_target_anti_aim,
  update_manual_and_freestanding, apply_body_yaw, on_bullet_impact,
  on_player_hurt, draw_keybind_indicators, draw_custom_indicator,
  update_whitelist, register_events_if_whitelisted.

Названия приблизительные, особенно у target_info и target_record_info.
Карта захваченных переменных и функций: full_source_index.json.
Стартовая генерация неиспользуемых строк сохранена: она потребляет случайные
числа и потому её удаление могло бы изменить последующую последовательность RNG.

ФАЙЛЫ ДЛЯ ПРОВЕРКИ И ВОСПРОИЗВЕДЕНИЯ

В архиве также лежат оригинал, предыдущие промежуточные формы, таблицы/IR,
скрипты реконструкции и фикстуры. Для использования нужен основной Lua-файл.
Промежуточные формы оставлены как исследовательское доказательство.

Python с requirements-full.txt:
  python unpack_sigma.py
  python normalize_sigma.py
  python opcode_map.py
  python recover_sigma.py
  python optimize_sigma.py
  python optimize_lexical.py
  python structure_sigma.py
  python build_full_source.py
  python polish_full_source.py
  SIGMA_SOURCE=new_sigma_pred.full_source.lua python verify_sigma.py
  python verify_helpers.py

В Windows переменную SIGMA_SOURCE задайте через set в cmd или
$env:SIGMA_SOURCE='new_sigma_pred.full_source.lua' в PowerShell.
Парсер при форматировании сохраняет исходные Lua-строки с экранированием
и многозначные поля конструкторов таблиц; эти особенности проверяются
сравнением реальных аргументов API и многозначных возвратов.
