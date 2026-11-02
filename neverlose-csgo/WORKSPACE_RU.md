# Карта рабочего проекта CS:GO

Текущая сборка и загрузка: [BUILD_STATUS_RU.md](BUILD_STATUS_RU.md).

| Часть | Файлы |
|---|---|
| DLL и запуск ядра | `neverlose/main.cpp`, `neverlose.cpp`, `entry.cpp` |
| Инжектор и встроенный сервер | `injector/main.cpp`, `injector.rc`, `server/rust-server/` |
| Новое меню | `neverlose/ui/cs2_menu.cpp`, `menu_view.cpp`, `vendor/imgui/` |
| Связь с прежним меню | `neverlose/setup_hooks.cpp`, `neverlosesdk.hpp` |
| Патчи истории Ragebot | `fix_rage_records.cpp`, `rage_record_logic.h`, `fix_records_size.cpp` |
| Лимит экстраполяции | `fix_extrap_ticks.cpp` — штатные 2 тика |
| Точки и анимации | `fix_crouch_hitscan.cpp`, `fix_anim_layers_preserve.cpp`, `nl_anim_hook.cpp` |
| Старые дополнительные элементы меню | `fix_menu_extra.cpp`, `Hide.cpp`, `HideLegit.cpp` |
| Визуал гранат | `nadewarn.cpp` |
| Проверки | `tests/` |

Основное ядро остаётся в `neverlose/bins/nl.bin`, SHA-256 `682ce73b371349f87da6fd9365f8550e240dcdb97951e80445e70286275ad96e`. Полного читаемого C++ всех внутренних алгоритмов Ragebot здесь пока нет. Сборка DLL с бинарным ядром не означает завершённую декомпиляцию всего клиента.

Все изменения относятся к CS:GO. Материалы CS2 в эту сборку не включены; стиль нового интерфейса реализован отдельно от кода CS2.
