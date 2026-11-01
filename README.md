# Outlaw: восстановленный Lua

[Скачать Lua](https://github.com/xanax3399-lang/222222/raw/refs/heads/outlaw-deobfuscated/outlaw_source.lua) · [Скачать весь архив](https://github.com/xanax3399-lang/222222/raw/refs/heads/outlaw-deobfuscated/outlaw_source.zip)

Основной файл — [outlaw_source.lua](outlaw_source.lua). Он содержит все 386
функций приложения из присланного `output_outlaw_beta (1).lua`.
Таблицы собраны в литералы, цепочки временных присваиваний сокращены,
для замыканий восстановлены локальные области видимости. Имена определены
по использованию; неоднозначные значения сохраняют временные имена.
Авторские имена и комментарии из обфускации восстановить невозможно.

Участок с буквами теперь представлен функцией `random_alphabet`:
`alphabet`, `remaining`, `shuffle_index`, `last_character`.

- [Отдельный Experimental Predict](experimental_predict.lua)
- [Модуль для исходной UI-обёртки](experimental_predict_module.lua)
- [Что делает Experimental Predict](experimental_predict_explanation.txt)
- [Указатель функций](function_index.json)
- [Проверки и контрольные суммы](verification.json)
- [Примечания к восстановлению](SOURCE_NOTES_RU.txt)

В этой версии Experimental Predict содержит список режимов и обработчик
видимости в разделе Rage Bot. Связанного алгоритма предсказания не обнаружено.

Пройдены 160 проверок и проверка синтаксиса Lua 5.1/5.3. Для всех 385
вложенных функций сверены строковые константы и обращения к глобальным
переменным. Полное выполнение в gamesense не проверялось: нужны LuaJIT,
игровые API и внешние модули. Проверки отдельных функций не доказывают
эквивалентность всех путей выполнения.

Архив содержит Lua, 40 раскодированных пресетов, читаемые копии встроенных
JavaScript/C/FFI, указатель функций и журналы проверок.
`outlaw_deobfuscated.lua` и одноимённый ZIP сохранены как копии текущих файлов.
