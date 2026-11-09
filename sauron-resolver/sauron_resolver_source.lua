-- Sauron resolver: recovered editable GameSense Lua.
-- PSU VM, encoded payload and unused padding removed. Names inferred.
-- Requires gamesense/csgo_weapons and vector. See README_RU.txt.
local function pack_results(...)
    return {
        n = select("#", ...),
        ...,
    }
end
local function main(...)
    local color_log, eye_position, random_int, register_esp_flag, screen_size, set_event_callback, unset_event_callback, trace_bullet, update_player_list, userid_to_entindex, get_local_player, get_player_weapon, get_players, get_prop, hitbox_position, frametime, atan, cos, floor, max, min, rad, sin, sqrt, plist_get, plist_set, draw_line, measure_text, draw_rectangle, draw_text, world_to_screen, table_remove, to_number, require_module, pairs_iter, ui_get, ui_name, print_message, ui_set_callback, ui_set_visible, notifications, weapon_data, vector_constructor, menu, yaw_presets, stage_defaults, player_state, player_history, remember_ui_references, log_message, controls, reset_player_state, on_player_death, on_round_start, on_player_connect, round_number, weapon_is_selected, contains, select_preset_yaw, normalize_yaw, yaw_between_points, trace_hitbox_offsets, angles_to_direction, classify_movement, same_side_of_threshold, on_setup_command, on_aim_hit, on_aim_miss, update_callbacks, L75_1, L79_1
    color_log = client.color_log
    eye_position = client.eye_position
    random_int = client.random_int
    register_esp_flag = client.register_esp_flag
    screen_size = client.screen_size
    set_event_callback = client.set_event_callback
    unset_event_callback = client.unset_event_callback
    trace_bullet = client.trace_bullet
    update_player_list = client.update_player_list
    userid_to_entindex = client.userid_to_entindex
    get_local_player = entity.get_local_player
    get_player_weapon = entity.get_player_weapon
    get_players = entity.get_players
    get_prop = entity.get_prop
    hitbox_position = entity.hitbox_position
    frametime = globals.frametime
    atan = math.atan
    cos = math.cos
    floor = math.floor
    max = math.max
    min = math.min
    rad = math.rad
    sin = math.sin
    sqrt = math.sqrt
    plist_get = plist.get
    plist_set = plist.set
    draw_line = renderer.line
    measure_text = renderer.measure_text
    draw_rectangle = renderer.rectangle
    draw_text = renderer.text
    world_to_screen = renderer.world_to_screen
    table_remove = table.remove
    to_number = tonumber
    require_module = require
    pairs_iter = pairs
    ui_get = ui.get
    ui_name = ui.name
    print_message = print
    ui_set_callback = ui.set_callback
    ui_set_visible = ui.set_visible
    notifications = _G.sauron_notify_cache
    if not notifications then
        weapon_data = {
        }
        _G.sauron_notify_cache = weapon_data
    end
    notifications = function(...)
        local L0_2, L1_2
        L0_2 = {
        }
        L0_2.callback_registered = false
        L0_2.maximum_count = 7
        L1_2 = function(A0_3, ...)
            local L1_3, L3_3
            L1_3 = A0_3.callback_registered
            if L1_3 then
                return 
            end
            L3_3 = function(...)
                local L0_4, L1_4, L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4, L10_4, L11_4, L12_4, L13_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4, L21_4, L22_4, L23_4, L24_4, L25_4, L26_4
                L0_4 = {
                }
                L1_4, L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4, L10_4, L11_4, L12_4, L13_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4, L21_4, L22_4, L23_4, L24_4, L25_4, L26_4 = screen_size()
                L0_4[1] = L1_4
                L0_4[2] = L2_4
                L0_4[3] = L3_4
                L0_4[4] = L4_4
                L0_4[5] = L5_4
                L0_4[6] = L6_4
                L0_4[7] = L7_4
                L0_4[8] = L8_4
                L0_4[9] = L9_4
                L0_4[10] = L10_4
                L0_4[11] = L11_4
                L0_4[12] = L12_4
                L0_4[13] = L13_4
                L0_4[14] = L14_4
                L0_4[15] = L15_4
                L0_4[16] = L16_4
                L0_4[17] = L17_4
                L0_4[18] = L18_4
                L0_4[19] = L19_4
                L0_4[20] = L20_4
                L0_4[21] = L21_4
                L0_4[22] = L22_4
                L0_4[23] = L23_4
                L0_4[24] = L24_4
                L0_4[25] = L25_4
                L0_4[26] = L26_4
                L1_4 = {
                }
                L1_4[1] = 0
                L1_4[2] = 0
                L1_4[3] = 0
                L2_4 = 5
                L3_4 = _G.sauron_notify_cache
                L4_4 = #L3_4
                L6_4 = -1
                for L7_4 = L4_4, 1, L6_4 do
                    L8_4 = (_G.sauron_notify_cache)[L7_4]
                    L9_4 = ((_G.sauron_notify_cache)[L7_4]).time
                    L10_4 = frametime()
                    L8_4.time = L9_4 - L10_4
                    L8_4 = 255
                    L9_4 = 0
                    L10_4 = L3_4[L7_4]
                    L11_4 = L10_4.time
                    if not (0 <= L11_4) then
                        L11_4 = table_remove
                        L12_4 = _G.sauron_notify_cache
                        L13_4 = L7_4
                        table_remove(L12_4, L7_4)
                    else
                        L11_4 = L10_4.def_time
                        L12_4 = L10_4.time
                        L11_4 = L11_4 - L12_4
                        if not (L11_4 <= 1) then
                            L12_4 = 1
                            if not 1 then
                                L12_4 = L11_4
                            end
                        else
                            L12_4 = L11_4
                        end
                        L13_4 = L10_4.time
                        if L13_4 < 0.5 or not (0.5 <= L12_4) then
                            if not (1 <= L12_4) and L12_4 then
                                L13_4 = L12_4
                            else
                                L13_4 = L10_4.time
                            end
                            L9_4 = L13_4 / 0.5
                            L8_4 = L9_4 * 255
                            if not (0.2 <= L9_4) then
                                L13_4 = L9_4 / 0.2
                                L13_4 = 1 - L13_4
                                L13_4 = 15 * L13_4
                                L2_4 = L2_4 + L13_4
                            end
                        end
                        L13_4 = {
                        }
                        L18_4 = L10_4.draw
                        L17_4 = ("[sauron] ")..L18_4
                        L15_4 = (measure_text(nil, L17_4)) * 1.1
                        L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4, L21_4, L22_4, L23_4, L24_4, L25_4, L26_4 = floor(L15_4)
                        L13_4[1] = L14_4
                        L13_4[2] = L15_4
                        L13_4[3] = L16_4
                        L13_4[4] = L17_4
                        L13_4[5] = L18_4
                        L13_4[6] = L19_4
                        L13_4[7] = L20_4
                        L13_4[8] = L21_4
                        L13_4[9] = L22_4
                        L13_4[10] = L23_4
                        L13_4[11] = L24_4
                        L13_4[12] = L25_4
                        L13_4[13] = L26_4
                        L14_4 = {
                        }
                        L15_4, L16_4, L17_4, L18_4, L19_4, L20_4, L21_4, L22_4, L23_4, L24_4, L25_4, L26_4 = measure_text(nil, ("[sauron]"))
                        L14_4[1] = L15_4
                        L14_4[2] = L16_4
                        L14_4[3] = L17_4
                        L14_4[4] = L18_4
                        L14_4[5] = L19_4
                        L14_4[6] = L20_4
                        L14_4[7] = L21_4
                        L14_4[8] = L22_4
                        L14_4[9] = L23_4
                        L14_4[10] = L24_4
                        L14_4[11] = L25_4
                        L14_4[12] = L26_4
                        L15_4 = {
                        }
                        L18_4 = L10_4.draw
                        L16_4, L17_4, L18_4, L19_4, L20_4, L21_4, L22_4, L23_4, L24_4, L25_4, L26_4 = measure_text(nil, L18_4)
                        L15_4[1] = L16_4
                        L15_4[2] = L17_4
                        L15_4[3] = L18_4
                        L15_4[4] = L19_4
                        L15_4[5] = L20_4
                        L15_4[6] = L21_4
                        L15_4[7] = L22_4
                        L15_4[8] = L23_4
                        L15_4[9] = L24_4
                        L15_4[10] = L25_4
                        L15_4[11] = L26_4
                        L16_4 = {
                        }
                        L17_4 = (L0_4[1]) / 2
                        L18_4 = (L13_4[1]) / 2
                        L17_4 = (L17_4 - L18_4) + 3
                        L18_4 = L0_4[2]
                        L19_4 = ((L0_4[2]) / 100) * 17.4
                        L18_4 = (L18_4 - L19_4) + L2_4
                        L16_4[1] = L17_4
                        L16_4[2] = L18_4
                        L18_4 = L16_4[1]
                        L19_4 = (L16_4[2]) - 20
                        L20_4 = L13_4[1]
                        L22_4 = L1_4[1]
                        L23_4 = L1_4[2]
                        L24_4 = L1_4[3]
                        if not (L8_4 <= 155) then
                            L25_4 = 155
                            if not 155 then
                                L25_4 = L8_4
                            end
                        else
                            L25_4 = L8_4
                        end
                        draw_rectangle(L18_4, L19_4, L20_4, 40, L22_4, L23_4, L24_4, L25_4)
                        L18_4 = L16_4[1]
                        L19_4 = (L16_4[2]) - 19
                        L20_4 = L16_4[1]
                        L21_4 = L13_4[1]
                        L20_4 = L20_4 + L21_4
                        L21_4 = (L16_4[2]) - 19
                        if not (L8_4 <= 155) then
                            L25_4 = 155
                            if not 155 then
                                L25_4 = L8_4
                            end
                        else
                            L25_4 = L8_4
                        end
                        draw_line(L18_4, L19_4, L20_4, L21_4, 255, 0, 0, L25_4)
                        L18_4 = L16_4[1]
                        L19_4 = (L13_4[1]) / 2
                        L18_4 = L18_4 + L19_4
                        L19_4 = (L15_4[1]) / 2
                        L18_4 = L18_4 - L19_4
                        L19_4 = L16_4[2]
                        draw_text(L18_4, L19_4, 255, 0, 0, L8_4, ("c"), nil, ("[sauron] "))
                        L17_4 = draw_text
                        L18_4 = L16_4[1]
                        L19_4 = (L13_4[1]) / 2
                        L18_4 = L18_4 + L19_4
                        L19_4 = (L14_4[1]) / 2
                        L18_4 = L18_4 + L19_4
                        L19_4 = L16_4[2]
                        L20_4 = 255
                        L21_4 = 255
                        L22_4 = 255
                        L23_4 = L8_4
                        L24_4 = "c"
                        L25_4 = nil
                        L26_4 = L10_4.draw
                        draw_text(L18_4, L19_4, 255, 255, 255, L8_4, ("c"), nil, L26_4)
                        L2_4 = L2_4 - 50
                    end
                end
                A0_3.callback_registered = true
            end
            set_event_callback(("paint_ui"), L3_3)
        end
        L0_2.register_callback = L1_2
        L1_2 = function(A0_3, A1_3, A2_3, ...)
            local L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3
            L3_3 = (to_number(A1_3)) + 1
            L4_3 = A0_3.maximum_count
            L6_3 = -1
            for L7_3 = L4_3, 2, L6_3 do
                L8_3 = _G.sauron_notify_cache
                L9_3 = _G.sauron_notify_cache
                L10_3 = L7_3 - 1
                L9_3 = L9_3[L10_3]
                L8_3[L7_3] = L9_3
            end
            L4_3 = _G.sauron_notify_cache
            L5_3 = {
            }
            L5_3.time = L3_3
            L5_3.def_time = L3_3
            L5_3.draw = A2_3
            L4_3[1] = L5_3
            L4_3 = A0_3.register_callback
            L4_3(A0_3)
        end
        L0_2.paint = L1_2
        return L0_2
    end
    notifications = notifications()
    weapon_data = require_module(("gamesense/csgo_weapons"))
    vector_constructor = require_module(("vector"))
    menu = {
    }
    yaw_presets = {
    }
    yaw_presets[1] = ("Rage")
    yaw_presets[2] = ("Other")
    menu.location = yaw_presets
    menu.name = "[sauron beta] "
    menu.id = 100
    menu.debug = true
    yaw_presets = {
    }
    player_state = {
    }
    player_state[1] = 44
    player_state[2] = -44
    player_state[3] = 0
    yaw_presets[("default")] = player_state
    player_state = {
    }
    player_state[1] = 44
    player_state[2] = -17
    player_state[3] = 15
    yaw_presets[("stand")] = player_state
    player_state = {
    }
    player_state[1] = 44
    player_state[2] = -17
    player_state[3] = 15
    yaw_presets[("slow")] = player_state
    stage_defaults = {
    }
    stage_defaults[("default")] = 0
    stage_defaults[("stand")] = 0
    stage_defaults[("slow")] = 15
    player_state = {
    }
    player_history = {
    }
    remember_ui_references = function(A0_2, ...)
        local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
        L1_2 = _G.sauron_reference
        if not L1_2 then
            L2_2 = {
            }
            _G.sauron_reference = L2_2
        end
        L1_2, L2_2, L3_2 = pairs_iter(A0_2)
        for L4_2, L5_2 in L1_2, L2_2, L3_2 do
            if not L4_2 then
                break
            end
            L6_2 = _G.sauron_reference
            L7_2 = menu.id
            L8_2 = {
            }
            L9_2 = (menu.location)[1]
            L10_2 = (menu.location)[2]
            L11_2, L12_2 = ui_name(L5_2)
            L8_2[1] = L9_2
            L8_2[2] = L10_2
            L8_2[3] = L11_2
            L8_2[4] = L12_2
            L6_2[L7_2] = L8_2
            L6_2 = menu
            L7_2 = (menu.id) + 1
            menu.id = L7_2
        end
    end
    log_message = function(A0_2, ...)
        color_log(255, 0, 21, ("[sauron]\000"))
        color_log(245, 245, 245, (" "), A0_2)
    end
    controls = function(A0_2, A1_2, A2_2, ...)
        local L4_2, L6_2, L7_2
        if A1_2 == nil then
            return 
        end
        L4_2 = (A0_2.name)..A2_2
        L6_2 = (A0_2.location)[1]
        L7_2 = (A0_2.location)[2]
        return A1_2(L6_2, L7_2, L4_2, ...)
    end
    menu.create = controls
    controls = {
    }
    on_player_death = menu.create
    on_player_connect = ui[("new_checkbox")]
    controls[("enabled")] = on_player_death(menu, on_player_connect, ("Enhanced resolver"))
    on_player_death = menu.create
    on_player_connect = ui[("new_checkbox")]
    controls[("weapons")] = on_player_death(menu, on_player_connect, ("Adaptive weapons"))
    on_player_death = menu.create
    on_player_connect = ui[("new_multiselect")]
    controls[("weapons_list")] = on_player_death(menu, on_player_connect, ("Active Weapons"), ("Scout"), ("Auto"), ("Revolver"), ("Deagle"), ("Pistols"), ("SMG"), ("Rifles"))
    remember_ui_references(controls)
    reset_player_state = function(A0_2, ...)
        local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
        for L4_2 = 1, 64, 1 do
            L6_2 = {
            }
            player_state[L4_2] = L6_2
            L5_2 = player_state[L4_2]
            L5_2.active = false
            L5_2 = player_state[L4_2]
            L5_2.stage = "default"
            L5_2 = player_state[L4_2]
            L5_2.delta = 0
            L5_2 = player_state[L4_2]
            L5_2.shots = 0
            L5_2 = player_state[L4_2]
            L5_2.slow = false
            L5_2 = player_state[L4_2]
            L5_2.last_vel = 0
            L5_2 = player_state[L4_2]
            L5_2.tick_to = 0
        end
        if A0_2 then
            for L4_2 = 1, 64, 1 do
                L6_2 = {
                }
                player_history[L4_2] = L6_2
                L5_2 = player_history[L4_2]
                L5_2.side = {
                }
                L5_2, L6_2, L7_2 = pairs_iter(stage_defaults)
                for L8_2, L9_2 in L5_2, L6_2, L7_2 do
                    if not L8_2 then
                        break
                    end
                    L10_2 = (player_history[L4_2]).side
                    L10_2[L8_2] = L9_2
                end
                L5_2 = player_history[L4_2]
                L5_2.res_side = {
                }
                L5_2, L6_2, L7_2 = pairs_iter(stage_defaults)
                for L8_2, L9_2 in L5_2, L6_2, L7_2 do
                    if not L8_2 then
                        break
                    end
                    L10_2 = (player_history[L4_2]).res_side
                    L10_2[L8_2] = L9_2
                end
                L5_2 = player_history[L4_2]
                L5_2.resolved = {
                }
                L5_2, L6_2, L7_2 = pairs_iter(stage_defaults)
                for L8_2, L9_2 in L5_2, L6_2, L7_2 do
                    if not L8_2 then
                        break
                    end
                    L10_2 = (player_history[L4_2]).resolved
                    L10_2[L8_2] = false
                end
                L5_2 = player_history[L4_2]
                L5_2.best_sides = {
                }
                L5_2, L6_2, L7_2 = pairs_iter(stage_defaults)
                for L8_2, L9_2 in L5_2, L6_2, L7_2 do
                    if not L8_2 then
                        break
                    end
                    L10_2 = (player_history[L4_2]).best_sides
                    L11_2 = {
                    }
                    L10_2[L8_2] = L11_2
                end
            end
        end
    end
    reset_player_state(true)
    on_player_death = function(A0_2, ...)
        local L1_2, L2_2
        L2_2 = A0_2.userid
        L1_2 = userid_to_entindex(L2_2)
        L2_2 = get_local_player()
        if L1_2 ~= L2_2 then
            return 
        end
        reset_player_state()
        L1_2 = notifications.paint
        L1_2(notifications, 5, ("Reseted data due to death"))
    end
    on_round_start = function(...)
        local L0_2
        reset_player_state()
        L0_2 = notifications.paint
        L0_2(notifications, 5, ("Reseted data due to round start"))
    end
    on_player_connect = function(A0_2, ...)
        local L1_2, L2_2
        L2_2 = A0_2.userid
        L1_2 = userid_to_entindex(L2_2)
        L2_2 = get_local_player()
        if L1_2 == L2_2 then
            reset_player_state(true)
            L1_2 = notifications.paint
            L1_2(notifications, 5, ("Reseted data due to connect"))
        end
    end
    round_number = function(A0_2, A1_2, ...)
        local L2_2, L3_2, L4_2
        if A1_2 then
            L2_2 = A1_2
        else
            L2_2 = 0
        end
        L2_2 = 10 ^ L2_2
        L4_2 = (A0_2 * L2_2) + 0.5
        L3_2 = (floor(L4_2)) / L2_2
        return L3_2
    end
    weapon_is_selected = function(...)
        local L0_2, L1_2, L2_2, L3_2, L4_2, L6_2, L8_2, L9_2, L10_2, L11_2, L12_2
        L1_2 = controls.weapons
        L0_2 = ui_get(L1_2)
        if not L0_2 then
            return true
        end
        L0_2 = get_local_player()
        L1_2 = get_player_weapon(L0_2)
        if L1_2 == nil then
            return 
        end
        L2_2 = weapon_data(L1_2)
        if L2_2 == nil then
            return 
        end
        L4_2 = controls.weapons_list
        L3_2 = ui_get(L4_2)
        L4_2 = nil
        L6_2 = #L3_2
        for L8_2 = 1, L6_2, 1 do
            L9_2 = {
            }
            L9_2[40] = "Scout"
            L9_2[11] = "Auto"
            L9_2[38] = "Auto"
            L9_2[64] = "Revolver"
            L9_2[1] = "Deagle"
            L10_2 = {
            }
            L10_2.pistol = "Pistols"
            L10_2.smg = "SMG"
            L10_2.rifle = "Rifles"
            L11_2 = L2_2.idx
            L11_2 = L9_2[L11_2]
            L12_2 = L3_2[L8_2]
            if L11_2 ~= L12_2 then
                L11_2 = L2_2.type
                L11_2 = L10_2[L11_2]
                L12_2 = L3_2[L8_2]
                if L11_2 ~= L12_2 then
                    L4_2 = false
                end
            else
                L4_2 = true
            end
            if L4_2 then
                break
            end
        end
        return L4_2
    end
    contains = function(A0_2, A1_2, ...)
        local L3_2, L5_2, L6_2
        if A0_2 == nil then
            return false
        end
        L3_2 = #A0_2
        for L5_2 = 1, L3_2, 1 do
            L6_2 = A0_2[L5_2]
            if L6_2 == A1_2 then
                return true
            end
        end
        return false
    end
    select_preset_yaw = function(delta, player, alternate, ...)
        local index
        if delta >= 0 and delta < 16 then
            index = alternate and 1 or 3
        else
            if delta > 0 then
                index = alternate and 2 or 1
            else
                if delta < 0 then
                    index = alternate and 3 or 2
                else
                    index = false
                end
            end
        end
        return yaw_presets[player_state[player].stage][index]
    end
    normalize_yaw = function(A0_2, ...)
        local L1_2
        L1_2 = (A0_2 % 360) + 360
        A0_2 = L1_2 % 360
        if not (A0_2 <= 180) then
            L1_2 = A0_2 - 360
            if not (L1_2) then
                L1_2 = A0_2
            end
        else
            L1_2 = A0_2
        end
        return L1_2
    end
    yaw_between_points = function(A0_2, A1_2, A2_2, A3_2, ...)
        local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
        L4_2 = A1_2 - A3_2
        L5_2 = A0_2 - A2_2
        L7_2 = L4_2 / L5_2
        L6_2 = atan(L7_2)
        L8_2 = L6_2 * 180
        L9_2 = math.pi
        L8_2 = L8_2 / L9_2
        L7_2 = normalize_yaw(L8_2)
        L6_2 = L7_2
        if not (L5_2 < 0) then
            L8_2 = L6_2 + 180
            L7_2 = normalize_yaw(L8_2)
        end
        return L7_2
    end
    trace_hitbox_offsets = function(A0_2, A1_2, A2_2, A3_2, A4_2, ...)
        local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2
        L5_2 = {
        }
        L6_2 = {
        }
        L7_2 = {
        }
        L8_2, L9_2, L10_2 = hitbox_position(A1_2, 0)
        L7_2[0] = L10_2
        L6_2[0] = L9_2
        L5_2[0] = L8_2
        L8_2 = (L5_2[0]) + 40
        L9_2 = L6_2[0]
        L7_2[1] = L7_2[0]
        L6_2[1] = L9_2
        L5_2[1] = L8_2
        L8_2 = L5_2[0]
        L9_2 = (L6_2[0]) + 40
        L7_2[2] = L7_2[0]
        L6_2[2] = L9_2
        L5_2[2] = L8_2
        L8_2 = (L5_2[0]) - 40
        L9_2 = L6_2[0]
        L7_2[3] = L7_2[0]
        L6_2[3] = L9_2
        L5_2[3] = L8_2
        L8_2 = L5_2[0]
        L9_2 = (L6_2[0]) - 40
        L7_2[4] = L7_2[0]
        L6_2[4] = L9_2
        L5_2[4] = L8_2
        L8_2 = L5_2[0]
        L9_2 = L6_2[0]
        L7_2[5] = (L7_2[0]) + 40
        L6_2[5] = L9_2
        L5_2[5] = L8_2
        L8_2 = L5_2[0]
        L9_2 = L6_2[0]
        L7_2[6] = (L7_2[0]) - 40
        L6_2[6] = L9_2
        L5_2[6] = L8_2
        L8_2 = 0
        for L12_2 = 0, 6, 1 do
            L15_2 = A2_2
            L16_2 = A3_2
            L17_2 = A4_2
            L18_2 = L5_2[L12_2]
            L19_2 = L6_2[L12_2]
            L20_2 = L7_2[L12_2]
            L21_2 = true
            L13_2, L14_2 = trace_bullet(A0_2, A2_2, A3_2, A4_2, L18_2, L19_2, L20_2, true)
            if not (L14_2 <= 0) then
                L8_2 = L14_2
                break
            end
        end
        return L8_2
    end
    angles_to_direction = function(A0_2, A1_2, ...)
        local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
        L2_2 = rad(A0_2)
        L3_2 = rad(A1_2)
        L4_2 = sin(L2_2)
        L5_2 = cos(L2_2)
        L6_2 = sin(L3_2)
        L7_2 = cos(L3_2)
        L8_2 = L5_2 * L7_2
        L9_2 = L5_2 * L6_2
        L10_2 = -L4_2
        return L8_2, L9_2, L10_2
    end
    classify_movement = function(A0_2, ...)
        local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
        L1_2 = entity.get_prop
        L1_2, L2_2, L3_2 = L1_2(A0_2, ("m_vecVelocity"))
        L4_2 = math.floor
        L5_2 = math.min
        L7_2 = math.sqrt
        L8_2 = L1_2 ^ 2
        L9_2 = L2_2 ^ 2
        L8_2 = L8_2 + L9_2
        L7_2 = (L7_2(L8_2)) + 0.5
        local returned_21_0 = pack_results(L5_2(10000, L7_2))
        L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2 = unpack(returned_21_0, 1, returned_21_0.n)
        L4_2 = L4_2(unpack(returned_21_0, 1, returned_21_0.n))
        L5_2 = (entity.get_prop)(A0_2, ("m_fFlags"))
        L6_2 = (entity.get_prop)(A0_2, ("m_flDuckAmount"))
        if not (L4_2 <= 3) and not (85 <= L4_2) and L6_2 == 0 then
            L7_2 = (bit.band)(L5_2, 1)
            if L7_2 == 1 then
                L7_2 = true
            else
                L7_2 = false
            end
        else
            L7_2 = false
        end
        if not L7_2 then
            L8_2 = player_state[A0_2]
            if not (5 <= L4_2) then
                L9_2 = "stand"
                if not ("stand") then
                    L9_2 = "default"
                end
            else
                L9_2 = "default"
            end
            L8_2.stage = L9_2
            return 
        else
            if L7_2 then
                L8_2 = (player_state[A0_2]).tick_to
                L9_2 = (globals.tickcount)()
                if not (L8_2 <= L9_2) then
                    L8_2 = -3
                    for L11_2 = L8_2, 3, 1 do
                        L12_2 = ((player_state[A0_2]).last_vel) + L11_2
                        if L12_2 == L4_2 then
                            return 
                        end
                        if L11_2 == 3 then
                            L13_2 = player_state[A0_2]
                            L13_2.tick_to = 0
                        end
                    end
                end
            end
            L8_2 = (player_state[A0_2]).tick_to
            L9_2 = (globals.tickcount)()
            if L8_2 == L9_2 then
                L8_2 = player_state[A0_2]
                L8_2.stage = "slow"
            end
            L8_2 = player_state[A0_2]
            if L7_2 then
                L9_2 = ((globals.tickcount)()) + 16
                if not (L9_2) then
                    L9_2 = (player_state[A0_2]).tick_to
                end
            else
                L9_2 = (player_state[A0_2]).tick_to
            end
            L8_2.tick_to = L9_2
            L8_2 = player_state[A0_2]
            L8_2.last_vel = L4_2
        end
    end
    same_side_of_threshold = function(A0_2, A1_2, A2_2, ...)
        local L3_2
        if not (A0_2 <= A2_2) and not (A1_2 <= A2_2) and A0_2 then
            L3_2 = A0_2
        else
            if not (A2_2 <= A0_2) and not (A2_2 <= A1_2) then
                L3_2 = A0_2
            else
                L3_2 = false
            end
        end
        return L3_2
    end
    on_setup_command = function(...)
        local L0_2, L2_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2
        L0_2 = get_players(true)
        L2_2 = #L0_2
        for L4_2 = 1, L2_2, 1 do
            L5_2 = L0_2[L4_2]
            L6_2 = weapon_is_selected()
            if not L6_2 then
                L6_2 = player_state[L5_2]
                L6_2.active = false
                plist_set(L5_2, ("Force body yaw"), false)
                return 
            else
                L6_2 = get_local_player()
                local returned_23_1 = pack_results(eye_position())
                L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2 = unpack(returned_23_1, 1, returned_23_1.n)
                L7_2 = vector_constructor(unpack(returned_23_1, 1, returned_23_1.n))
                local returned_23_2 = pack_results(hitbox_position(L5_2, 0))
                L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2 = unpack(returned_23_2, 1, returned_23_2.n)
                L8_2 = vector_constructor(unpack(returned_23_2, 1, returned_23_2.n))
                L12_2 = L7_2.x
                L13_2 = L7_2.y
                L14_2 = L8_2.x
                L15_2 = L8_2.y
                L11_2 = yaw_between_points(L12_2, L13_2, L14_2, L15_2)
                L9_2 = vector_constructor(0, L11_2, 0)
                L12_2 = L9_2.x
                L13_2 = (L9_2.y) + 90
                local returned_23_3 = pack_results(angles_to_direction(L12_2, L13_2))
                L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2 = unpack(returned_23_3, 1, returned_23_3.n)
                L10_2 = vector_constructor(unpack(returned_23_3, 1, returned_23_3.n))
                L12_2 = L7_2.x
                L13_2 = (L10_2.x) * 100
                L12_2 = L12_2 + L13_2
                L13_2 = L7_2.y
                L14_2 = (L10_2.y) * 100
                L13_2 = L13_2 + L14_2
                L11_2 = vector_constructor(L12_2, L13_2)
                L14_2 = L9_2.x
                L15_2 = (L9_2.y) - 90
                local returned_23_4 = pack_results(angles_to_direction(L14_2, L15_2))
                L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2 = unpack(returned_23_4, 1, returned_23_4.n)
                L12_2 = vector_constructor(unpack(returned_23_4, 1, returned_23_4.n))
                L14_2 = L7_2.x
                L15_2 = (L12_2.x) * 100
                L14_2 = L14_2 + L15_2
                L15_2 = L7_2.y
                L16_2 = (L12_2.y) * 100
                L15_2 = L15_2 + L16_2
                L13_2 = vector_constructor(L14_2, L15_2)
                L17_2 = L11_2.x
                L18_2 = L11_2.y
                L19_2 = L7_2.z
                L14_2 = trace_hitbox_offsets(L6_2, L5_2, L17_2, L18_2, L19_2)
                L18_2 = L13_2.x
                L19_2 = L13_2.y
                L20_2 = L7_2.z
                L15_2 = trace_hitbox_offsets(L6_2, L5_2, L18_2, L19_2, L20_2)
                L16_2 = player_state[L5_2]
                L17_2 = (player_state[L5_2]).shots
                if not (0 < L17_2) and not (0 < L14_2) and not (0 < L15_2) then
                    L17_2 = false
                else
                    L17_2 = true
                end
                L16_2.active = L17_2
                L16_2 = player_state[L5_2]
                L18_2 = -60
                L22_2 = get_prop(L5_2, ("m_flPoseParameter"), 11)
                if not L22_2 then
                    L22_2 = 0
                end
                L22_2 = ((L22_2 * 120) - 60) + 0.5
                local returned_23_5 = pack_results(round_number(L22_2, 1))
                L21_2, L22_2, L23_2, L24_2, L25_2 = unpack(returned_23_5, 1, returned_23_5.n)
                local returned_23_6 = pack_results(min(60, unpack(returned_23_5, 1, returned_23_5.n)))
                L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2 = unpack(returned_23_6, 1, returned_23_6.n)
                L16_2.delta = max(L18_2, unpack(returned_23_6, 1, returned_23_6.n))
                classify_movement(L5_2)
                L16_2 = (player_state[L5_2]).stage
                L17_2 = (player_state[L5_2]).shots
                if L17_2 == 0 then
                    if L16_2 == "slow" then
                        L17_2 = (player_history[L5_2]).side
                        L18_2 = ((player_history[L5_2]).resolved)[L16_2]
                        if L18_2 then
                            L18_2 = ((player_history[L5_2]).res_side)[L16_2]
                            if not (L18_2) then
                                L18_2 = ((player_history[L5_2]).side)[L16_2]
                            end
                        else
                            L18_2 = ((player_history[L5_2]).side)[L16_2]
                        end
                        L17_2[L16_2] = L18_2
                    else
                        L17_2 = (player_history[L5_2]).side
                        L18_2 = ((player_history[L5_2]).resolved)[L16_2]
                        if L18_2 then
                            L18_2 = ((player_history[L5_2]).res_side)[L16_2]
                            if not (L18_2) then
                                L19_2 = (player_state[L5_2]).delta
                                L18_2 = select_preset_yaw(L19_2, L5_2)
                            end
                        else
                            L19_2 = (player_state[L5_2]).delta
                            L18_2 = select_preset_yaw(L19_2, L5_2)
                        end
                        L17_2[L16_2] = L18_2
                    end
                end
                L20_2 = (player_state[L5_2]).active
                plist_set(L5_2, ("Force body yaw"), L20_2)
                L18_2 = L5_2
                L19_2 = "Force body yaw value"
                L20_2 = ((player_history[L5_2]).side)[L16_2]
                plist_set(L5_2, ("Force body yaw value"), L20_2)
                L17_2 = client.update_player_list
                L17_2()
            end
        end
    end
    on_aim_hit = function(A0_2, ...)
        local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
        L2_2 = A0_2.target
        L1_2 = (player_state[L2_2]).active
        if L1_2 then
            L2_2 = A0_2.target
            L1_2 = (player_state[L2_2]).stage
            L3_2 = A0_2.target
            L2_2 = (player_history[L3_2]).resolved
            L3_2 = A0_2.hitgroup
            if L3_2 ~= 1 then
                L3_2 = false
            else
                L3_2 = true
            end
            L2_2[L1_2] = L3_2
            L3_2 = A0_2.target
            L2_2 = ((player_history[L3_2]).resolved)[L1_2]
            if L2_2 then
                L3_2 = A0_2.target
                L2_2 = (player_history[L3_2]).res_side
                L4_2 = A0_2.target
                L3_2 = ((player_history[L4_2]).side)[L1_2]
                L2_2[L1_2] = L3_2
            end
            L5_2 = A0_2.target
            L4_2 = (player_state[L5_2]).delta
            L7_2 = A0_2.target
            L6_2 = ((player_history[L7_2]).side)[L1_2]
            L9_2 = A0_2.target
            L8_2 = (player_state[L9_2]).stage
            L11_2 = A0_2.target
            L10_2 = (player_state[L11_2]).shots
            print_message(("Hit in "), L4_2, (", delta "), L6_2, (" side, stage: "), L8_2, (", misses: "), L10_2)
        else
            L4_2 = A0_2.target
            L3_2 = (player_state[L4_2]).delta
            print_message(("Hit in "), L3_2, (" with skeet resolver"))
        end
    end
    on_aim_miss = function(A0_2, ...)
        local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
        L1_2 = A0_2.reason
        if L1_2 == "?" then
            L2_2 = A0_2.target
            L1_2 = (player_state[L2_2]).active
            if L1_2 then
                L2_2 = A0_2.target
                L1_2 = (player_state[L2_2]).stage
                L3_2 = A0_2.target
                L2_2 = player_state[L3_2]
                L4_2 = A0_2.target
                L2_2.shots = ((player_state[L4_2]).shots) + 1
                L3_2 = A0_2.target
                L2_2 = (player_history[L3_2]).side
                L5_2 = A0_2.target
                L4_2 = ((player_history[L5_2]).side)[L1_2]
                L5_2 = A0_2.target
                L3_2 = select_preset_yaw(L4_2, L5_2, true)
                L2_2[L1_2] = L3_2
                L2_2 = menu.debug
                if L2_2 then
                    L2_2 = string.format
                    L5_2 = A0_2.target
                    L4_2 = (player_state[L5_2]).delta
                    L6_2 = A0_2.target
                    L5_2 = ((player_history[L6_2]).side)[L1_2]
                    L7_2 = A0_2.target
                    L6_2 = (player_state[L7_2]).stage
                    L8_2 = A0_2.target
                    L7_2 = ((player_history[L8_2]).resolved)[L1_2]
                    L2_2 = L2_2(("Missed in %s delta, side: %s, stage: %s, was resolved: %s"), L4_2, L5_2, L6_2, L7_2)
                    print_message(L2_2)
                    L6_2 = A0_2.target
                    L5_2 = (player_state[L6_2]).shots
                    print_message(("Shots count: "), L5_2)
                end
                L3_2 = A0_2.target
                L2_2 = (player_history[L3_2]).resolved
                L2_2[L1_2] = false
            end
        else
            L1_2 = A0_2.reason
            if L1_2 == "?" then
                L4_2 = A0_2.target
                L3_2 = (player_state[L4_2]).delta
                print_message(("Missed in "), L3_2, (" with skeet resolver"))
            end
        end
    end
    update_callbacks = function(...)
        local L0_2, L1_2, L2_2, L4_2
        L1_2 = controls.enabled
        L0_2 = ui_get(L1_2)
        L2_2 = controls.enabled
        L1_2 = ui_get(L2_2)
        if L1_2 then
            L2_2 = controls.weapons
            L1_2 = ui_get(L2_2)
        end
        if L0_2 then
            L2_2 = set_event_callback
            if not set_event_callback then
                L2_2 = unset_event_callback
            end
        else
            L2_2 = unset_event_callback
        end
        L4_2 = controls.weapons
        ui_set_visible(L4_2, L0_2)
        L4_2 = controls.weapons_list
        ui_set_visible(L4_2, L1_2)
        L2_2(("setup_command"), on_setup_command)
        L2_2(("aim_miss"), on_aim_miss)
        L2_2(("aim_hit"), on_aim_hit)
        L2_2(("round_start"), on_round_start)
        L2_2(("player_death"), on_player_death)
        L2_2(("player_connect_full"), on_player_connect)
    end
    update_callbacks()
    L75_1 = controls[("enabled")]
    ui_set_callback(L75_1, update_callbacks)
    L75_1 = controls[("weapons")]
    ui_set_callback(L75_1, update_callbacks)
    L79_1 = function(A0_2, ...)
        local L1_2, L2_2
        L1_2 = (player_state[A0_2]).active
        if L1_2 then
            L1_2 = (player_history[A0_2]).resolved
            L2_2 = (player_state[A0_2]).stage
            L1_2 = not (L1_2[L2_2])
        end
        return L1_2
    end
    register_esp_flag(("RESOLVING"), 255, 205, 41, L79_1)
    L79_1 = function(A0_2, ...)
        local L1_2, L2_2, L3_2, L5_2, L6_2
        L1_2 = (player_history[A0_2]).resolved
        L2_2 = (player_state[A0_2]).stage
        L1_2 = L1_2[L2_2]
        L3_2 = (player_state[A0_2]).active
        if L3_2 then
            L3_2 = string.format
            L5_2 = string.upper
            L6_2 = (player_state[A0_2]).stage
            local returned_28_7 = pack_results(L5_2(L6_2))
            L5_2, L6_2 = unpack(returned_28_7, 1, returned_28_7.n)
            L3_2 = L3_2(("RESOLVED %s"), unpack(returned_28_7, 1, returned_28_7.n))
        end
        return L1_2, L3_2
    end
    register_esp_flag(("RESOLVED"), 0, 255, 115, L79_1)
    L79_1 = function(A0_2, ...)
        local L1_2
        L1_2 = (player_state[A0_2]).active
        if L1_2 then
            L1_2 = (player_state[A0_2]).stage
            if L1_2 ~= "slow" then
                L1_2 = false
            else
                L1_2 = true
            end
        end
        return L1_2
    end
    register_esp_flag(("SLOW"), 20, 255, 243, L79_1)
    L79_1 = function(A0_2, ...)
        local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
        L1_2, L2_2, L3_2 = get_prop(A0_2, ("m_vecVelocity"))
        L8_2 = L1_2 ^ 2
        L9_2 = L2_2 ^ 2
        L8_2 = L8_2 + L9_2
        L7_2 = (sqrt(L8_2)) + 0.5
        local returned_30_8 = pack_results(min(10000, L7_2))
        L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2 = unpack(returned_30_8, 1, returned_30_8.n)
        L4_2 = floor(unpack(returned_30_8, 1, returned_30_8.n))
        L6_2 = -60
        L10_2 = get_prop(A0_2, ("m_flPoseParameter"), 11)
        if not L10_2 then
            L10_2 = 0
        end
        L10_2 = ((L10_2 * 120) - 60) + 0.5
        local returned_30_9 = pack_results(round_number(L10_2, 1))
        L9_2, L10_2, L11_2, L12_2, L13_2 = unpack(returned_30_9, 1, returned_30_9.n)
        local returned_30_10 = pack_results(min(60, unpack(returned_30_9, 1, returned_30_9.n)))
        L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2 = unpack(returned_30_10, 1, returned_30_10.n)
        L5_2 = max(L6_2, unpack(returned_30_10, 1, returned_30_10.n))
        L7_2 = string.format
        L10_2 = (player_history[A0_2]).side
        L11_2 = (player_state[A0_2]).stage
        L10_2 = L10_2[L11_2]
        local returned_30_11 = pack_results(L7_2(("%s (%s) [%s]"), L5_2, L10_2, L4_2))
        L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2 = unpack(returned_30_11, 1, returned_30_11.n)
        return true, unpack(returned_30_11, 1, returned_30_11.n)
    end
    register_esp_flag(("0"), 255, 255, 255, L79_1)
end
return main(...)
