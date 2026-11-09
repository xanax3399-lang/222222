# Карта полного исходника

- `notifications:register_callback`, `notifications:paint`: очередь уведомлений, время жизни и отрисовка.
- `menu:create`, `remember_ui_references`, `controls`: элементы меню и сохранение их ссылок.
- `reset_player_state`: отдельное состояние игрока и история найденных углов для 64 индексов.
- `weapon_is_selected`: фильтр конкретного оружия и его категории.
- `select_preset_yaw`: выбор угла из трёх значений для default/stand/slow.
- `normalize_yaw`, `yaw_between_points`, `angles_to_direction`: геометрия.
- `trace_hitbox_offsets`: семь пробных точек возле головы; первый положительный урон.
- `classify_movement`: stand/default/slow, скорость, duck, grounded и таймер в тиках.
- `on_setup_command`: боковые трассировки, pose parameter, выбор истории и запись Force body yaw.
- `on_aim_hit`, `on_aim_miss`: обновление найденной стороны и перебор при unknown.
- `update_callbacks`: видимость контролов, подключение и отключение обработчиков.
- `register_esp_flag`: RESOLVING, RESOLVED, SLOW и числовая диагностика.

Имена восстановлены по назначению. Здесь нет портированного нативного
резольвера Neverlose: это логика именно присланного Lua-скрипта.
