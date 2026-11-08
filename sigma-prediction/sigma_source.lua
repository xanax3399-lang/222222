-- Reconstructed editable Lua; inferred names. See README_EDITABLE_RU.txt.
local o_loadstring = panorama.loadstring
panorama.loadstring = function(...)
    local args = {
        ...,
    }
    if (#args[1] == 158) then
        return function()
            return "|"..panorama.open().MyPersonaAPI.GetXuid().."|"
        end
    end
    return o_loadstring(unpack(args))
end
local environment = getfenv()
local unpack_results = unpack
local function pack_results(...)
    return {
        n = select("#", ...),
        ...,
    }
end
local function new_table(size)
    if table.create then
        return table.create(size)
    end
    return {
    }
end
local function main(...)
    local return_varargs, bit_band, camera_angles, eye_position, key_state, scale_damage, screen_size, set_event_callback, trace_bullet
    local trace_line, userid_to_entindex, get_all_entities, get_classname, get_local_player, get_player_resource, get_players, get_prop, hitbox_position, is_alive, is_dormant, is_enemy
    local curtime, tickcount, tickinterval, math_abs, math_atan, math_atan2, math_cos, math_deg, math_rad, math_sin, math_sqrt, draw_gradient
    local draw_line, draw_text, draw_triangle, table_remove, ui_get, ui_new_color_picker, ui_new_hotkey, ui_new_label, ui_new_multiselect, ui_reference, ui_set, ui_set_callback
    local ui_set_visible, get_value_type, native_controls, set_native_ui_visible, script_controls, anti_aim_state, player_records, contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta
    local target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, estimate_damage_at_offsets, select_nearest_player, is_valid_player, update_target_anti_aim
    local reset_player_state, handle_use_key, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, draw_keybind_indicators, update_ui_visibility, get_steam_identity
    local whitelisted_steam_id, whitelist_initialized, next_whitelist_poll, update_whitelist, register_events_if_whitelisted, custom_indicator_enabled, background_label_1, background_color_1, background_label_2, background_color_2, accent_label_1, accent_color_1
    local accent_label_2, accent_color_2, indicator_x, indicator_y, indicator_drag_key, onshot_enabled, onshot_key, force_safe_point, double_tap_enabled, double_tap_key, force_body_aim, duck_peek_assist
    local indicator_dimensions, choked_commands, is_mouse_in_rectangle, drag_origin_x, drag_origin_y, indicator_alpha, indicator_scale, indicator_dragging, unused_callback, crouching_ct_fake_yaw, value_118
    return_varargs = function(...)
        return ...
    end
    do
        for index = 1, 2000 do
            environment.math.random(1, 201)
        end
    end
    bit_band = environment.bit.band
    camera_angles = environment.client.camera_angles
    eye_position = environment.client.eye_position
    key_state = environment.client.key_state
    scale_damage = environment.client.scale_damage
    screen_size = environment.client.screen_size
    set_event_callback = environment.client.set_event_callback
    trace_bullet = environment.client.trace_bullet
    trace_line = environment.client.trace_line
    userid_to_entindex = environment.client.userid_to_entindex
    get_all_entities = environment.entity.get_all
    get_classname = environment.entity.get_classname
    get_local_player = environment.entity.get_local_player
    get_player_resource = environment.entity.get_player_resource
    get_players = environment.entity.get_players
    get_prop = environment.entity.get_prop
    hitbox_position = environment.entity.hitbox_position
    is_alive = environment.entity.is_alive
    is_dormant = environment.entity.is_dormant
    is_enemy = environment.entity.is_enemy
    curtime = environment.globals.curtime
    tickcount = environment.globals.tickcount
    tickinterval = environment.globals.tickinterval
    math_abs = environment.math.abs
    math_atan = environment.math.atan
    math_atan2 = environment.math.atan2
    math_cos = environment.math.cos
    math_deg = environment.math.deg
    math_rad = environment.math.rad
    math_sin = environment.math.sin
    math_sqrt = environment.math.sqrt
    draw_gradient = environment.renderer.gradient
    draw_line = environment.renderer.line
    draw_text = environment.renderer.text
    draw_triangle = environment.renderer.triangle
    table_remove = environment.table.remove
    ui_get = environment.ui.get
    ui_new_color_picker = environment.ui.new_color_picker
    ui_new_hotkey = environment.ui.new_hotkey
    ui_new_label = environment.ui.new_label
    ui_new_multiselect = environment.ui.new_multiselect
    ui_reference = environment.ui.reference
    ui_set = environment.ui.set
    ui_set_callback = environment.ui.set_callback
    ui_set_visible = environment.ui.set_visible
    get_value_type = environment.type
    -- Compatibility: some GameSense builds do not expose Fake yaw limit.
    local function optional_ui_reference(tab, container, name)
        local result = pack_results(pcall(ui_reference, tab, container, name))
        if result[1] then
            return unpack_results(result, 2, result.n)
        end
        local message = environment.tostring(result[2])
        if not environment.string.find(message, "not found", 1, true) then
            environment.error(message, 0)
        end
        return nil
    end
    local function find_fake_yaw_limit()
        local handle = optional_ui_reference("AA", "Anti-aimbot angles", "Fake yaw limit")
        if handle ~= nil then
            return handle
        end
        return optional_ui_reference("AA", "anti-aimbot angles", "Fake yaw limit")
    end
    local function reference_group(...)
        local controls = new_table(256)
        local values = pack_results(ui_reference(...))
        for index = 1, values.n do
            controls[index] = values[index]
        end
        return controls
    end
    native_controls = new_table(256)
    native_controls.enabled = ui_reference("AA", "Anti-aimbot angles", "Enabled")
    native_controls.pitch = ui_reference("AA", "Anti-aimbot angles", "Pitch")
    native_controls.yawbase = ui_reference("AA", "Anti-aimbot angles", "Yaw base")
    native_controls.fakeyawlimit = find_fake_yaw_limit()
    if native_controls.fakeyawlimit == nil then
        environment.client.log("[sigma] Fake yaw limit is unavailable in this GameSense build; limit writes and the crouching CT limit override are disabled.")
    end
    native_controls.fsbodyyaw = ui_reference("AA", "Anti-aimbot angles", "Freestanding body yaw")
    native_controls.edgeyaw = ui_reference("AA", "Anti-aimbot angles", "Edge yaw")
    native_controls.maxprocticks = ui_reference("MISC", "Settings", "sv_maxusrcmdprocessticks")
    native_controls.fakeduck = ui_reference("RAGE", "Other", "Duck peek assist")
    native_controls.safepoint = ui_reference("RAGE", "Aimbot", "Force safe point")
    native_controls.forcebaim = ui_reference("RAGE", "Other", "Force body aim")
    native_controls.player_list = ui_reference("PLAYERS", "Players", "Player list")
    native_controls.reset_all = ui_reference("PLAYERS", "Players", "Reset all")
    native_controls.apply_all = ui_reference("PLAYERS", "Adjustments", "Apply to all")
    native_controls.load_cfg = ui_reference("Config", "Presets", "Load")
    native_controls.fl_limit = ui_reference("AA", "Fake lag", "Limit")
    native_controls.yaw = reference_group("AA", "Anti-aimbot angles", "Yaw")
    native_controls.quickpeek = reference_group("RAGE", "Other", "Quick peek assist")
    native_controls.yawjitter = reference_group("AA", "Anti-aimbot angles", "Yaw jitter")
    native_controls.bodyyaw = reference_group("AA", "Anti-aimbot angles", "Body yaw")
    native_controls.freestand = reference_group("AA", "Anti-aimbot angles", "Freestanding")
    native_controls.os = reference_group("AA", "Other", "On shot anti-aim")
    native_controls.slow = reference_group("AA", "Other", "Slow motion")
    native_controls.dt = reference_group("RAGE", "Other", "Double tap")
    native_controls.ps = reference_group("RAGE", "Other", "Double tap")
    native_controls.fakelag = reference_group("AA", "Fake lag", "Enabled")
    set_native_ui_visible = function(visible)
        local value_2
        if visible == nil then
            visible = true
        end
        value_2 = native_controls.pitch
        ui_set_visible(value_2, visible)
        value_2 = native_controls.yawbase
        ui_set_visible(value_2, visible)
        value_2 = native_controls.yaw[1]
        ui_set_visible(value_2, visible)
        value_2 = native_controls.yaw[2]
        ui_set_visible(value_2, visible)
        value_2 = native_controls.yawjitter[1]
        ui_set_visible(value_2, visible)
        value_2 = native_controls.yawjitter[2]
        ui_set_visible(value_2, visible)
        value_2 = native_controls.bodyyaw[1]
        ui_set_visible(value_2, visible)
        value_2 = native_controls.bodyyaw[2]
        ui_set_visible(value_2, visible)
        value_2 = native_controls.fakeyawlimit
        if value_2 ~= nil then
            ui_set_visible(value_2, visible)
        end
        value_2 = native_controls.fsbodyyaw
        ui_set_visible(value_2, visible)
        value_2 = native_controls.edgeyaw
        ui_set_visible(value_2, visible)
        value_2 = native_controls.freestand[1]
        ui_set_visible(value_2, visible)
        value_2 = native_controls.freestand[2]
        ui_set_visible(value_2, visible)
        return
    end
    set_native_ui_visible(false)
    script_controls = new_table(256)
    player_records = new_table(256)
    player_records.Standing = "Reversed Freestanding"
    player_records.Moving = "Reversed Freestanding"
    player_records["Slow walk"] = "Reversed Freestanding"
    player_records["In air"] = "Freestanding"
    player_records["On E"] = "Freestanding"
    script_controls.b = player_records
    player_records = new_table(256)
    player_records.Standing = 60
    player_records.Moving = 60
    player_records["Slow walk"] = 60
    player_records["In air"] = 60
    player_records["On E"] = 60
    script_controls.r = player_records
    script_controls["Detect missed angle"] = false
    script_controls["Anti-resolver on X shot"] = "-"
    script_controls["Anti-resolver shot amount"] = 0
    yaw_between_points = new_table(6)
    yaw_between_points[1] = "Manual AA"
    yaw_between_points[2] = "Jitter when not networked"
    yaw_between_points[3] = "Freestanding"
    yaw_between_points[4] = "Edge yaw"
    yaw_between_points[5] = "Keybind indicator"
    yaw_between_points[6] = "AA indicator"
    script_controls.s = ui_new_multiselect("AA", "Anti-aimbot angles", "Anti-aim settings", yaw_between_points)
    script_controls.ml = ui_new_hotkey("AA", "Anti-aimbot angles", "Manual left\010Manual Prediction")
    script_controls.mr = ui_new_hotkey("AA", "Anti-aimbot angles", "Manual right\010Manual Prediction")
    script_controls.mf = ui_new_hotkey("AA", "Anti-aimbot angles", "Manual forwards\010Manual Prediction")
    script_controls.fs = ui_new_hotkey("AA", "Anti-aimbot angles", "Freestanding\010Manual Prediction")
    script_controls.ey = ui_new_hotkey("AA", "Anti-aimbot angles", "Edye yaw\010Manual Prediction")
    yaw_between_points = new_table(7)
    yaw_between_points[1] = "Double tap"
    yaw_between_points[2] = "Onshot Anti-Aim"
    yaw_between_points[3] = "Force body aim"
    yaw_between_points[4] = "Force safe point"
    yaw_between_points[5] = "Quick peek"
    yaw_between_points[6] = "Edge yaw"
    yaw_between_points[7] = "Freestanding"
    script_controls.k = ui_new_multiselect("AA", "Anti-aimbot angles", "Keybinds", yaw_between_points)
    player_records = {
    }
    contains_value = ui_new_label("AA", "Anti-aimbot angles", "Main color")
    local returned_650 = pack_results(ui_new_color_picker("AA", "Anti-aimbot angles", "Main colorpicker"))
    player_records[1] = contains_value
    for index = 1, returned_650.n do
        player_records[1 + index] = returned_650[index]
    end
    script_controls.clr = player_records
    player_records = {
    }
    contains_value = ui_new_label("AA", "Anti-aimbot angles", "Accent color")
    local returned_664 = pack_results(ui_new_color_picker("AA", "Anti-aimbot angles", "Accent colorpicker"))
    player_records[1] = contains_value
    for index = 1, returned_664.n do
        player_records[1 + index] = returned_664[index]
    end
    script_controls.clr2 = player_records
    anti_aim_state = new_table(256)
    anti_aim_state.aa = 1
    contains_value = new_table(5)
    contains_value[1] = "Standing"
    contains_value[2] = "Moving"
    contains_value[3] = "Slow walk"
    contains_value[4] = "In air"
    contains_value[5] = "On E"
    anti_aim_state.s_i = contains_value
    contains_value = new_table(3)
    contains_value[1] = 0
    contains_value[2] = 0
    contains_value[3] = 0
    anti_aim_state.l_s = contains_value
    anti_aim_state.rec = new_table(256)
    anti_aim_state.desync = 0
    anti_aim_state.holding_e = false
    anti_aim_state.target = 0
    contains_value = new_table(256)
    contains_value.manual = 0
    contains_value.fs = false
    contains_value.edge = false
    contains_value.time = 0
    anti_aim_state.dir = contains_value
    contains_value = new_table(256)
    contains_value.manual = 0
    contains_value.fs = false
    contains_value.edge = false
    contains_value.time = 0
    anti_aim_state.stored_dir = contains_value
    anti_aim_state.old_dsy = true
    contains_value = new_table(3)
    contains_value[1] = "CWorld"
    contains_value[2] = "CCSPlayer"
    contains_value[3] = "CFuncBrush"
    anti_aim_state.classnames = contains_value
    contains_value = new_table(7)
    yaw_between_points = "inferno"
    signed_coordinate_delta = "flashbang"
    target_info = "decoy"
    signed_line_distance = "smokegrenade"
    contains_value[1] = "knife"
    contains_value[2] = "hegrenade"
    contains_value[3] = "inferno"
    contains_value[4] = "flashbang"
    contains_value[5] = "decoy"
    contains_value[6] = "smokegrenade"
    contains_value[7] = "taser"
    anti_aim_state.nonweapons = contains_value
    player_records = new_table(256)
    for player_index = 0 + 1, 0 + 64, 0 + 1 do
        signed_coordinate_delta = new_table(256)
        signed_coordinate_delta.s = new_table(256)
        signed_line_distance = new_table(256)
        signed_coordinate_delta.h = signed_line_distance
        signed_coordinate_delta.m = 0
        signed_coordinate_delta.r = 0
        signed_coordinate_delta.d = 0
        target_info = "l"
        signed_coordinate_delta.l = 0
        player_records[player_index] = signed_coordinate_delta
    end
    contains_value = function(values, wanted)
        if values == nil then
            return false
        end
        if get_value_type(values) == "number" then
            values = ui_get(values)
        end
        for index = 0, #values do
            if values[index] == wanted then
                return true
            end
        end
        return false
    end
    head_coordinates = function(player)
        local _, _, head_z = hitbox_position(player, 0)
        local origin_x, origin_y = get_prop(player, "m_vecOrigin")
        return origin_x, origin_y, head_z
    end
    normalize_yaw = function(yaw)
        while yaw > 180 do
            yaw = yaw - 360
        end
        while yaw < -180 do
            yaw = yaw + 360
        end
        return yaw
    end
    yaw_between_points = function(from_x, from_y, to_x, to_y)
        local delta_y, delta_x = from_y - to_y, from_x - to_x
        local angle = normalize_yaw(math_atan(delta_y / delta_x) * 180 / environment.math.pi)
        if delta_x >= 0 then
            angle = normalize_yaw(angle + 180)
        end
        return angle
    end
    signed_coordinate_delta = function(position, target_position, flatten_height)
        if flatten_height then
            target_position = {
                target_position[1],
                target_position[2],
                position[3],
            }
        end
        local delta = (position[1] - target_position[1]) + (position[2] - target_position[2]) + (position[3] - target_position[3])
        if delta < 0 then
            delta = delta * 0.75
        end
        return delta
    end
    target_info = function(player, other_player)
        local value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13
        local value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21
        value_2, value_3, value_4 = head_coordinates(player)
        local returned_6 = pack_results(get_local_player())
        value_5, value_6, value_7 = head_coordinates(unpack_results(returned_6, 1, returned_6.n))
        value_8 = new_table(3)
        value_8[1] = value_5
        value_8[2] = value_6
        value_8[3] = value_7
        value_9 = new_table(3)
        value_9[1] = value_2
        value_9[2] = value_3
        value_9[3] = value_4
        value_10 = new_table(3)
        value_11 = other_player.x
        value_12 = other_player.y
        value_13 = other_player.z
        value_10[1] = value_11
        value_10[2] = value_12
        value_10[3] = value_13
        value_11 = new_table(3)
        value_12 = value_10[1]
        value_13 = value_9[1]
        value_12 = value_12 - value_13
        value_13 = value_10[2]
        value_14 = value_9[2]
        value_13 = value_13 - value_14
        value_14 = value_10[3]
        value_15 = value_9[3]
        value_14 = value_14 - value_15
        value_11[1] = value_12
        value_11[2] = value_13
        value_11[3] = value_14
        value_13 = value_11[1] ^ 2
        value_14 = value_11[2] ^ 2
        value_13 = value_13 + value_14
        value_14 = value_11[3] ^ 2
        value_13 = value_13 + value_14
        value_12 = math_sqrt(value_13)
        value_13 = new_table(3)
        value_14 = value_11[1] / value_12
        value_15 = value_11[2] / value_12
        value_16 = value_11[3] / value_12
        value_13[1] = value_14
        value_13[2] = value_15
        value_13[3] = value_16
        value_14 = new_table(3)
        value_15 = value_8[1]
        value_16 = value_9[1]
        value_15 = value_15 - value_16
        value_16 = value_8[2]
        value_17 = value_9[2]
        value_16 = value_16 - value_17
        value_17 = value_8[3]
        value_18 = value_9[3]
        value_17 = value_17 - value_18
        value_14[1] = value_15
        value_14[2] = value_16
        value_14[3] = value_17
        value_15 = value_13[1]
        value_16 = value_14[1]
        value_15 = value_15 * value_16
        value_16 = value_13[2]
        value_17 = value_14[2]
        value_16 = value_16 * value_17
        value_15 = value_15 + value_16
        value_16 = value_13[3]
        value_17 = value_14[3]
        value_16 = value_16 * value_17
        value_15 = value_15 + value_16
        value_17 = new_table(3)
        value_18 = value_9[1]
        value_19 = value_13[1]
        value_19 = value_15 * value_19
        value_18 = value_18 + value_19
        value_19 = value_9[2]
        value_20 = value_13[2]
        value_20 = value_15 * value_20
        value_19 = value_19 + value_20
        value_20 = value_9[3]
        value_21 = value_13[3]
        value_21 = value_15 * value_21
        value_20 = value_20 + value_21
        value_17[1] = value_18
        value_17[2] = value_19
        value_17[3] = value_20
        anti_aim_state.ls = value_17
        value_17 = anti_aim_state.ls
        return signed_coordinate_delta(value_17, value_8, true)
    end
    signed_line_distance = function(line_start, line_end, point)
        local ax, ay = head_coordinates(line_start)
        local bx, by = head_coordinates(line_end)
        local numerator = (point.y - ay) * bx - (point.x - ax) * by + point.x * ay - point.y * ax
        local denominator = math_sqrt((point.y - ay) ^ 2 + (point.x - ax) ^ 2)
        return numerator / denominator
    end
    target_record_info = function(argument_1, argument_2, argument_3, argument_4, argument_5)
        local value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12
        value_5 = new_table(256)
        local returned_4 = pack_results(head_coordinates(argument_4))
        for index = 1, returned_4.n do
            value_5[0 + index] = returned_4[index]
        end
        value_6 = new_table(256)
        local returned_10 = pack_results(get_prop(argument_4, "m_vecOrigin"))
        for index = 1, returned_10.n do
            value_6[0 + index] = returned_10[index]
        end
        value_7 = argument_2[3]
        value_8 = value_5[3] + 10
        if value_8 < value_7 then
            return false
        else
            value_7 = argument_2[3]
            value_8 = value_6[3]
            if value_7 >= value_8 then
                local returned_26 = pack_results(signed_line_distance(argument_3, argument_4, argument_5))
                value_7 = math_abs(unpack_results(returned_26, 1, returned_26.n))
                if 300 >= value_7 then
                    value_7 = math_abs(argument_1)
                    if value_7 >= 30 then
                        value_8 = get_player_resource()
                        value_7 = get_prop(value_8, "m_iPing", argument_3)
                        value_8 = tickinterval()
                        value_8 = value_7 * value_8
                        value_8 = 14 - value_8
                        value_9 = #anti_aim_state.rec
                        if value_8 > value_9 then
                            return false
                        else
                            value_9 = anti_aim_state.rec[value_8]
                            if value_9 ~= nil then
                                value_10 = signed_coordinate_delta(value_9, value_5, true)
                                if argument_1 >= 0 then
                                    if argument_1 >= value_10 then
                                        value_11 = math_abs(argument_1)
                                        value_12 = math_abs(value_10)
                                        if value_12 < value_11 then
                                            value_11 = true
                                        else
                                            value_11 = false
                                        end
                                    else
                                        value_11 = math_abs(argument_1)
                                        value_12 = math_abs(value_10)
                                        if value_11 < value_12 then
                                            value_11 = true
                                        else
                                            value_11 = math_abs(argument_1)
                                            value_12 = math_abs(value_10)
                                            if value_12 < value_11 then
                                                value_11 = true
                                            else
                                                value_11 = false
                                            end
                                        end
                                    end
                                else
                                    if value_10 < argument_1 then
                                        value_11 = math_abs(argument_1)
                                        value_12 = math_abs(value_10)
                                        if value_11 < value_12 then
                                            value_11 = true
                                        else
                                            value_11 = math_abs(argument_1)
                                            value_12 = math_abs(value_10)
                                            if value_12 < value_11 then
                                                value_11 = true
                                            else
                                                value_11 = false
                                            end
                                        end
                                    else
                                        if argument_1 >= value_10 then
                                            value_11 = math_abs(argument_1)
                                            value_12 = math_abs(value_10)
                                            if value_12 < value_11 then
                                                value_11 = true
                                            else
                                                value_11 = false
                                            end
                                        else
                                            value_11 = math_abs(argument_1)
                                            value_12 = math_abs(value_10)
                                            if value_11 < value_12 then
                                                value_11 = true
                                            else
                                                value_11 = math_abs(argument_1)
                                                value_12 = math_abs(value_10)
                                                if value_12 < value_11 then
                                                    value_11 = true
                                                else
                                                    value_11 = false
                                                end
                                            end
                                        end
                                    end
                                end
                                return value_11
                            else
                                return false
                            end
                        end
                    else
                        return true
                    end
                else
                    return false
                end
            else
                return false
            end
        end
    end
    pose_desync_side = function(player)
        if anti_aim_state.desync == 0 then
            return 0
        end
        local pose_yaw = get_prop(player, "m_flPoseParameter", 11) * 120 - 60
        if pose_yaw < 0 then
            return 90
        end
        return -90
    end
    update_shot_history = function(event)
        local value_5, value_6, value_7, value_8
        for player_index = 0 + 1, 0 + 64, 0 + 1 do
            value_5 = player_records[player_index].r
            value_6 = #player_records[player_index].s
            if value_5 >= value_6 then
                value_5 = player_records[player_index].r
                value_6 = #player_records[player_index].s
                if not (value_6 >= value_5) then
                    value_5 = player_records[player_index]
                    value_6 = #player_records[player_index].s
                    value_5.r = value_6
                end
            else
                value_5 = #player_records[player_index].h
                if 0 >= value_5 then
                    value_5 = false
                else
                    value_5 = player_records[player_index].s
                    value_6 = #player_records[player_index].s
                    value_5 = value_5[value_6].t
                    value_6 = player_records[player_index].h
                    value_7 = #player_records[player_index].h
                    value_6 = value_6[value_7].t
                    if value_5 == value_6 then
                        value_5 = true
                    else
                        value_5 = false
                    end
                end
                if not value_5 then
                    value_6 = player_records[player_index]
                    if not value_5 then
                        value_7 = 0
                    else
                        value_7 = player_records[player_index].h
                        value_8 = #player_records[player_index].h
                        value_7 = value_7[value_8].h
                        if value_7 ~= 1 then
                            value_7 = 0
                        else
                            value_7 = pose_desync_side(event)
                            if not value_7 then
                                value_7 = 0
                            end
                        end
                    end
                    value_6.l = value_7
                    if value_5 then
                        value_6 = player_records[player_index]
                        value_6.m = 0
                    else
                        value_6 = player_records[player_index].m
                        value_7 = script_controls["Anti-resolver shot amount"]
                        if value_6 >= value_7 then
                            value_6 = player_records[player_index]
                            value_6.m = 0
                        else
                            value_6 = player_records[player_index]
                            value_6.m = player_records[player_index].m + 1
                        end
                    end
                    if not (not value_5) then
                        value_6 = player_records[player_index].s
                        value_7 = #player_records[player_index].s
                        value_6 = value_6[value_7]
                        value_6.d = pose_desync_side(event)
                    end
                    value_6 = player_records[player_index]
                    value_7 = player_records[player_index].s
                    value_8 = #player_records[player_index].s
                    value_6.d = value_7[value_8].d
                    anti_aim_state.target = player_index
                else
                    value_6 = player_records[player_index].h
                    value_7 = #player_records[player_index].h
                    value_6 = value_6[value_7].v
                    if value_6 == event then
                        value_6 = player_records[player_index]
                        if not value_5 then
                            value_7 = 0
                        else
                            value_7 = player_records[player_index].h
                            value_8 = #player_records[player_index].h
                            value_7 = value_7[value_8].h
                            if value_7 ~= 1 then
                                value_7 = 0
                            else
                                value_7 = pose_desync_side(event)
                                if not value_7 then
                                    value_7 = 0
                                end
                            end
                        end
                        value_6.l = value_7
                        if value_5 then
                            value_6 = player_records[player_index]
                            value_6.m = 0
                        else
                            value_6 = player_records[player_index].m
                            value_7 = script_controls["Anti-resolver shot amount"]
                            if value_6 >= value_7 then
                                value_6 = player_records[player_index]
                                value_6.m = 0
                            else
                                value_6 = player_records[player_index]
                                value_6.m = player_records[player_index].m + 1
                            end
                        end
                        if not (not value_5) then
                            value_6 = player_records[player_index].s
                            value_7 = #player_records[player_index].s
                            value_6 = value_6[value_7]
                            value_6.d = pose_desync_side(event)
                        end
                        value_6 = player_records[player_index]
                        value_7 = player_records[player_index].s
                        value_8 = #player_records[player_index].s
                        value_6.d = value_7[value_8].d
                        anti_aim_state.target = player_index
                    end
                end
                value_6 = player_records[player_index]
                value_7 = #player_records[player_index].s
                value_6.r = value_7
            end
        end
        return
    end
    angles_to_direction = function(pitch, yaw)
        local yaw_sin = math_sin(math_rad(yaw))
        local yaw_cos = math_cos(math_rad(yaw))
        local pitch_sin = math_sin(math_rad(pitch))
        local pitch_cos = math_cos(math_rad(pitch))
        return pitch_cos * yaw_cos, pitch_cos * yaw_sin, -pitch_sin
    end
    classify_movement = function(player, command)
        local value_2, value_3, value_4, value_5, value_6, value_8, value_9, value_10
        value_2 = anti_aim_state.holding_e
        if not value_2 then
            value_3 = native_controls.slow[1]
            value_2 = ui_get(value_3)
            if not (not value_2) then
                value_3 = native_controls.slow[2]
                value_2 = ui_get(value_3)
            end
            if not value_2 then
                value_4 = get_prop(player, "m_fFlags")
                value_3 = bit_band(value_4, 1)
                if value_3 ~= 1 then
                    value_3 = false
                else
                    value_3 = command.in_jump
                    if value_3 == 0 then
                        value_3 = true
                    else
                        value_3 = false
                    end
                end
                if value_3 then
                    value_4, value_5, value_6 = get_prop(player, "m_vecVelocity")
                    value_9 = value_4 ^ 2
                    value_10 = value_5 ^ 2
                    value_9 = value_9 + value_10
                    value_8 = math_sqrt(value_9)
                    if value_8 >= 2 then
                        value_8 = 2
                    else
                        value_8 = 1
                        if not 1 then
                            value_8 = 2
                        end
                    end
                    anti_aim_state.aa = value_8
                    return
                else
                    anti_aim_state.aa = 4
                    return
                end
            else
                anti_aim_state.aa = 3
                return
            end
        else
            anti_aim_state.aa = 5
            return
        end
    end
    vector_yaw = function(x, y)
        if x == 0 and y == 0 then
            return 0
        end
        return math_deg(math_atan2(y, x))
    end
    estimate_damage_at_offsets = function(argument_1, argument_2, argument_3, argument_4, argument_5)
        local value_5, value_6, value_7, value_8, value_9, value_10, value_13, value_14, value_15, value_16
        local value_17, value_18, value_19, value_20, value_21
        value_5 = new_table(256)
        value_6 = new_table(256)
        value_7 = new_table(256)
        value_8, value_9, value_10 = head_coordinates(argument_2)
        value_7[0] = value_10
        value_6[0] = value_9
        value_5[0] = value_8
        value_8 = value_5[0] + 40
        value_9 = value_6[0]
        value_7[1] = value_7[0]
        value_6[1] = value_9
        value_5[1] = value_8
        value_8 = value_5[0]
        value_9 = value_6[0] + 40
        value_7[2] = value_7[0]
        value_6[2] = value_9
        value_5[2] = value_8
        value_8 = value_5[0] - 40
        value_9 = value_6[0]
        value_7[3] = value_7[0]
        value_6[3] = value_9
        value_5[3] = value_8
        value_8 = value_5[0]
        value_9 = value_6[0] - 40
        value_7[4] = value_7[0]
        value_6[4] = value_9
        value_5[4] = value_8
        value_8 = value_5[0]
        value_9 = value_6[0]
        value_7[5] = value_7[0] + 40
        value_6[5] = value_9
        value_5[5] = value_8
        value_8 = 0
        value_9 = nil
        for offset_index = 0 + 0, 0 + 5, 0 + 1 do
            if value_9 == 0 then
                value_16 = value_5[offset_index]
                value_17 = value_6[offset_index]
                value_18 = value_7[offset_index]
                value_19 = argument_3
                value_20 = argument_4
                value_21 = argument_5
                value_14, value_15 = trace_bullet(argument_2, value_16, value_17, value_18, argument_3, argument_4, argument_5)
                value_9 = value_15
                value_8 = value_14
            else
                if value_9 == nil then
                    value_16 = value_5[offset_index]
                    value_17 = value_6[offset_index]
                    value_18 = value_7[offset_index]
                    value_19 = argument_3
                    value_20 = argument_4
                    value_21 = argument_5
                    value_14, value_15 = trace_bullet(argument_2, value_16, value_17, value_18, argument_3, argument_4, argument_5)
                    value_9 = value_15
                    value_8 = value_14
                end
            end
        end
        if value_8 ~= nil then
            value_13 = value_9
        else
            value_13 = scale_damage(argument_2, 2, value_9)
            if not value_13 then
                value_13 = value_9
            end
        end
        return scale_damage(argument_2, 1, value_13)
    end
    select_nearest_player = function(origin, other)
        local value_2, value_3, value_4, value_6, value_9, value_10, value_11, value_12, value_13
        local value_14, value_15, value_16
        value_2 = get_players(true)
        value_3 = #value_2
        if value_3 ~= 0 then
            value_3 = 0
            value_4 = 180
            value_6 = #value_2
            for enemy_index = 0 + 1, 0 + value_6, 0 + 1 do
                value_10 = value_2[enemy_index]
                value_9, value_10, value_11 = get_prop(value_10, "m_vecOrigin")
                value_13 = normalize_yaw
                value_15 = origin[1] - value_9
                value_16 = origin[2] - value_10
                value_14 = vector_yaw(value_15, value_16)
                value_15 = other[2]
                value_14 = (value_14 - value_15) + 180
                local returned_29 = pack_results(normalize_yaw(value_14))
                value_12 = math_abs(unpack_results(returned_29, 1, returned_29.n))
                if not (value_12 >= value_4) then
                    value_4 = value_12
                    value_3 = value_2[enemy_index]
                end
            end
            return value_3
        else
            return 0
        end
    end
    is_valid_player = function(player)
        if player == 0 then
            return false
        end
        if not is_alive(player) then
            return false
        end
        if is_dormant(player) then
            return false
        end
        return true
    end
    update_target_anti_aim = function(command)
        local value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12
        local value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23, value_24
        local value_25, value_26, value_27, value_28
        value_1 = get_local_player()
        value_2 = new_table(256)
        local returned_6 = pack_results(head_coordinates(value_1))
        for index = 1, returned_6.n do
            value_2[0 + index] = returned_6[index]
        end
        value_3 = new_table(256)
        local returned_10 = pack_results(camera_angles())
        for index = 1, returned_10.n do
            value_3[0 + index] = returned_10[index]
        end
        value_6 = anti_aim_state.target
        value_5 = is_valid_player(value_6)
        if not value_5 then
            value_5 = select_nearest_player(value_2, value_3)
        else
            value_5 = anti_aim_state.target
            if not value_5 then
                value_5 = select_nearest_player(value_2, value_3)
            end
        end
        anti_aim_state.target = value_5
        value_4 = anti_aim_state.target
        if value_4 == 0 then
            value_4 = script_controls.b
            value_5 = anti_aim_state.s_i
            value_6 = anti_aim_state.aa
            value_5 = value_5[value_6]
            value_4 = value_4[value_5]
            if value_4 ~= "Off" then
                value_4 = script_controls.b
                value_5 = anti_aim_state.s_i
                value_6 = anti_aim_state.aa
                value_5 = value_5[value_6]
                value_4 = value_4[value_5]
                if value_4 ~= "Jitter" then
                    value_4 = anti_aim_state.holding_e
                    if not value_4 then
                        anti_aim_state.desync = 180
                    else
                        value_5 = anti_aim_state.desync
                        if value_5 == 0 then
                            value_5 = 90
                            if not 90 then
                                value_5 = anti_aim_state.desync
                            end
                        else
                            value_5 = anti_aim_state.desync
                            if value_5 ~= 180 then
                                value_5 = anti_aim_state.desync
                            else
                                value_5 = 90
                                if not 90 then
                                    value_5 = anti_aim_state.desync
                                end
                            end
                        end
                        anti_aim_state.desync = value_5
                    end
                else
                    anti_aim_state.desync = 180
                end
            else
                anti_aim_state.desync = 0
            end
            return
        else
            value_5 = anti_aim_state.target
            value_4 = player_records[value_5].d
            if value_4 ~= 0 then
                value_5 = anti_aim_state.target
                value_4 = player_records[value_5].m
                value_5 = script_controls["Anti-resolver shot amount"]
                if value_4 ~= value_5 then
                    value_6 = anti_aim_state.target
                    value_5 = player_records[value_6].d
                    anti_aim_state.desync = value_5
                else
                    value_4 = script_controls["Anti-resolver on X shot"]
                    if value_4 == "-" then
                        value_6 = anti_aim_state.target
                        value_5 = player_records[value_6].d
                        anti_aim_state.desync = value_5
                    else
                        value_4 = script_controls["Anti-resolver on X shot"]
                        if value_4 ~= "None" then
                            value_4 = script_controls["Anti-resolver on X shot"]
                            if value_4 == "Jitter" then
                                anti_aim_state.desync = 180
                            end
                        else
                            anti_aim_state.desync = 0
                        end
                    end
                end
                return
            else
                value_5 = anti_aim_state.target
                value_4 = player_records[value_5].l
                if value_4 == 0 then
                    value_4 = script_controls.b
                    value_5 = anti_aim_state.s_i
                    value_6 = anti_aim_state.aa
                    value_5 = value_5[value_6]
                    value_4 = value_4[value_5]
                    if value_4 ~= "Off" then
                        value_4 = script_controls.b
                        value_5 = anti_aim_state.s_i
                        value_6 = anti_aim_state.aa
                        value_5 = value_5[value_6]
                        value_4 = value_4[value_5]
                        if value_4 ~= "Jitter" then
                            value_4 = anti_aim_state.desync
                            if value_4 == 0 then
                                anti_aim_state.desync = 90
                            else
                                value_4 = anti_aim_state.desync
                                if value_4 == 180 then
                                    anti_aim_state.desync = 90
                                end
                            end
                            value_4 = new_table(256)
                            value_6 = anti_aim_state.target
                            local returned_85 = pack_results(head_coordinates(value_6))
                            for index = 1, returned_85.n do
                                value_4[0 + index] = returned_85[index]
                            end
                            value_6 = value_2[1]
                            value_7 = value_2[2]
                            value_8 = value_4[1]
                            value_9 = value_4[2]
                            value_5 = yaw_between_points(value_6, value_7, value_8, value_9)
                            value_8 = value_5 - 90
                            value_6, value_7, value_8 = angles_to_direction(0, value_8)
                            value_9 = value_2[1]
                            value_10 = value_6 * 10
                            value_9 = value_9 + value_10
                            value_10 = value_2[2]
                            value_11 = value_7 * 10
                            value_10 = value_10 + value_11
                            value_13 = value_5 + 90
                            value_11, value_12, value_13 = angles_to_direction(0, value_13)
                            value_14 = value_2[1]
                            value_15 = value_11 * 10
                            value_14 = value_14 + value_15
                            value_15 = value_2[2]
                            value_16 = value_12 * 10
                            value_15 = value_15 + value_16
                            value_16 = value_2[1]
                            value_17 = value_6 * 80
                            value_16 = value_16 + value_17
                            value_17 = value_2[2]
                            value_18 = value_7 * 80
                            value_17 = value_17 + value_18
                            value_18 = value_2[1]
                            value_19 = value_11 * 80
                            value_18 = value_18 + value_19
                            value_19 = value_2[2]
                            value_20 = value_12 * 80
                            value_19 = value_19 + value_20
                            value_22 = anti_aim_state.target
                            value_25 = value_2[3]
                            value_20 = estimate_damage_at_offsets(value_1, value_22, value_9, value_10, value_25)
                            value_23 = anti_aim_state.target
                            value_26 = value_2[3]
                            value_21 = estimate_damage_at_offsets(value_1, value_23, value_14, value_15, value_26)
                            value_24 = anti_aim_state.target
                            value_27 = value_2[3]
                            value_22 = estimate_damage_at_offsets(value_1, value_24, value_16, value_17, value_27)
                            value_25 = anti_aim_state.target
                            value_28 = value_2[3]
                            value_23 = estimate_damage_at_offsets(value_1, value_25, value_18, value_19, value_28)
                            if value_20 >= value_21 then
                                if value_21 >= value_20 then
                                    if value_22 >= value_23 then
                                        if value_23 >= value_22 then
                                            value_25 = anti_aim_state.holding_e
                                            if value_25 then
                                                if "" ~= "left" then
                                                    if "" == "right" then
                                                        value_26 = script_controls.b
                                                        value_27 = anti_aim_state.s_i
                                                        value_28 = anti_aim_state.aa
                                                        value_27 = value_27[value_28]
                                                        value_26 = value_26[value_27]
                                                        if value_26 ~= "Freestanding" then
                                                            value_26 = -90
                                                        else
                                                            value_26 = 90
                                                            if not 90 then
                                                                value_26 = -90
                                                            end
                                                        end
                                                        anti_aim_state.desync = value_26
                                                    end
                                                else
                                                    value_26 = script_controls.b
                                                    value_27 = anti_aim_state.s_i
                                                    value_28 = anti_aim_state.aa
                                                    value_27 = value_27[value_28]
                                                    value_26 = value_26[value_27]
                                                    if value_26 ~= "Freestanding" then
                                                        value_26 = 90
                                                    else
                                                        value_26 = -90
                                                        if not (-90) then
                                                            value_26 = 90
                                                        end
                                                    end
                                                    anti_aim_state.desync = value_26
                                                end
                                                return
                                            else
                                                anti_aim_state.desync = 180
                                                return
                                            end
                                        else
                                            if "right" ~= "left" then
                                                if "right" == "right" then
                                                    value_26 = script_controls.b
                                                    value_27 = anti_aim_state.s_i
                                                    value_28 = anti_aim_state.aa
                                                    value_27 = value_27[value_28]
                                                    value_26 = value_26[value_27]
                                                    if value_26 ~= "Freestanding" then
                                                        value_26 = -90
                                                    else
                                                        value_26 = 90
                                                        if not 90 then
                                                            value_26 = -90
                                                        end
                                                    end
                                                    anti_aim_state.desync = value_26
                                                end
                                            else
                                                value_26 = script_controls.b
                                                value_27 = anti_aim_state.s_i
                                                value_28 = anti_aim_state.aa
                                                value_27 = value_27[value_28]
                                                value_26 = value_26[value_27]
                                                if value_26 ~= "Freestanding" then
                                                    value_26 = 90
                                                else
                                                    value_26 = -90
                                                    if not (-90) then
                                                        value_26 = 90
                                                    end
                                                end
                                                anti_aim_state.desync = value_26
                                            end
                                            return
                                        end
                                    else
                                        if "left" ~= "left" then
                                            if "left" == "right" then
                                                value_26 = script_controls.b
                                                value_27 = anti_aim_state.s_i
                                                value_28 = anti_aim_state.aa
                                                value_27 = value_27[value_28]
                                                value_26 = value_26[value_27]
                                                if value_26 ~= "Freestanding" then
                                                    value_26 = -90
                                                else
                                                    value_26 = 90
                                                    if not 90 then
                                                        value_26 = -90
                                                    end
                                                end
                                                anti_aim_state.desync = value_26
                                            end
                                        else
                                            value_26 = script_controls.b
                                            value_27 = anti_aim_state.s_i
                                            value_28 = anti_aim_state.aa
                                            value_27 = value_27[value_28]
                                            value_26 = value_26[value_27]
                                            if value_26 ~= "Freestanding" then
                                                value_26 = 90
                                            else
                                                value_26 = -90
                                                if not (-90) then
                                                    value_26 = 90
                                                end
                                            end
                                            anti_aim_state.desync = value_26
                                        end
                                        return
                                    end
                                else
                                    if "right" ~= "left" then
                                        if "right" == "right" then
                                            value_26 = script_controls.b
                                            value_27 = anti_aim_state.s_i
                                            value_28 = anti_aim_state.aa
                                            value_27 = value_27[value_28]
                                            value_26 = value_26[value_27]
                                            if value_26 ~= "Freestanding" then
                                                value_26 = -90
                                            else
                                                value_26 = 90
                                                if not 90 then
                                                    value_26 = -90
                                                end
                                            end
                                            anti_aim_state.desync = value_26
                                        end
                                    else
                                        value_26 = script_controls.b
                                        value_27 = anti_aim_state.s_i
                                        value_28 = anti_aim_state.aa
                                        value_27 = value_27[value_28]
                                        value_26 = value_26[value_27]
                                        if value_26 ~= "Freestanding" then
                                            value_26 = 90
                                        else
                                            value_26 = -90
                                            if not (-90) then
                                                value_26 = 90
                                            end
                                        end
                                        anti_aim_state.desync = value_26
                                    end
                                    return
                                end
                            else
                                if "left" ~= "left" then
                                    if "left" == "right" then
                                        value_26 = script_controls.b
                                        value_27 = anti_aim_state.s_i
                                        value_28 = anti_aim_state.aa
                                        value_27 = value_27[value_28]
                                        value_26 = value_26[value_27]
                                        if value_26 ~= "Freestanding" then
                                            value_26 = -90
                                        else
                                            value_26 = 90
                                            if not 90 then
                                                value_26 = -90
                                            end
                                        end
                                        anti_aim_state.desync = value_26
                                    end
                                else
                                    value_26 = script_controls.b
                                    value_27 = anti_aim_state.s_i
                                    value_28 = anti_aim_state.aa
                                    value_27 = value_27[value_28]
                                    value_26 = value_26[value_27]
                                    if value_26 ~= "Freestanding" then
                                        value_26 = 90
                                    else
                                        value_26 = -90
                                        if not (-90) then
                                            value_26 = 90
                                        end
                                    end
                                    anti_aim_state.desync = value_26
                                end
                                return
                            end
                        else
                            anti_aim_state.desync = 180
                            return
                        end
                    else
                        anti_aim_state.desync = 0
                        return
                    end
                else
                    value_6 = anti_aim_state.target
                    value_5 = player_records[value_6].l
                    anti_aim_state.desync = value_5
                    return
                end
            end
        end
    end
    reset_player_state = function(event)
        local value_5, value_6, value_7, value_8
        if event == nil then
            event = false
        end
        for player_index = 0 + 1, 0 + 64, 0 + 1 do
            value_5 = player_records[player_index].d
            value_6 = player_records
            value_7 = new_table(256)
            value_7.s = new_table(256)
            value_7.h = new_table(256)
            value_7.r = 0
            value_7.d = 0
            value_7.m = 0
            if not event then
                value_8 = 0
            else
                if value_5 then
                    value_8 = value_5
                else
                    value_8 = 0
                end
            end
            value_7.l = value_8
            player_records[player_index] = value_7
        end
        return
    end
    handle_use_key = function(command, other)
        local value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13
        local value_14, value_15, value_16, value_17, value_18, value_20, value_21, value_22, value_23, value_24
        value_2 = key_state(69)
        if not value_2 then
            return false
        else
            value_2 = 100
            value_3 = (get_all_entities("CPlantedC4"))[1]
            if value_3 ~= nil then
                value_4 = new_table(256)
                local returned_15 = pack_results(get_prop(value_3, "m_vecOrigin"))
                for index = 1, returned_15.n do
                    value_4[0 + index] = returned_15[index]
                end
                if value_4 ~= nil then
                    value_5 = new_table(256)
                    local returned_22 = pack_results(get_prop(command, "m_vecOrigin"))
                    for index = 1, returned_22.n do
                        value_5[0 + index] = returned_22[index]
                    end
                    local returned_28 = pack_results(signed_coordinate_delta(value_5, value_4))
                    value_2 = math_abs(unpack_results(returned_28, 1, returned_28.n))
                end
            end
            value_4 = get_prop(command, "m_iTeamNum")
            if value_4 ~= 3 then
                value_5 = false
            else
                if value_2 < 62 then
                    value_5 = true
                else
                    value_5 = false
                end
            end
            value_6, value_7, value_8 = eye_position()
            value_9, value_10 = camera_angles()
            local returned_46 = pack_results(math_rad(value_9))
            value_11 = math_sin(unpack_results(returned_46, 1, returned_46.n))
            local returned_51 = pack_results(math_rad(value_9))
            value_12 = math_cos(unpack_results(returned_51, 1, returned_51.n))
            local returned_56 = pack_results(math_rad(value_10))
            value_13 = math_sin(unpack_results(returned_56, 1, returned_56.n))
            local returned_61 = pack_results(math_rad(value_10))
            value_14 = math_cos(unpack_results(returned_61, 1, returned_61.n))
            value_15 = new_table(3)
            value_16 = value_12 * value_14
            value_17 = value_12 * value_13
            value_18 = -value_11
            value_15[1] = value_16
            value_15[2] = value_17
            value_15[3] = value_18
            value_21 = value_15[1] * 8192
            value_21 = value_6 + value_21
            value_22 = value_15[2] * 8192
            value_22 = value_7 + value_22
            value_23 = value_15[3] * 8192
            value_23 = value_8 + value_23
            value_16, value_17 = trace_line(command, value_6, value_7, value_8, value_21, value_22, value_23)
            value_18 = true
            if value_17 ~= nil then
                value_20 = #anti_aim_state.classnames
                for class_index = 0 + 0, 0 + value_20, 0 + 1 do
                    value_23 = get_classname(value_17)
                    value_24 = anti_aim_state.classnames[class_index]
                    if value_23 == value_24 then
                        value_18 = false
                    end
                end
            end
            if not value_18 then
                if not value_5 then
                    other.in_use = 0
                end
            end
            return true
        end
    end
    update_manual_and_freestanding = function(command)
        local value_1, value_2, value_3
        value_2 = native_controls.yaw[1]
        value_3 = anti_aim_state.holding_e
        if not value_3 then
            value_3 = "180"
        else
            value_3 = "Off"
            if not "Off" then
                value_3 = "180"
            end
        end
        ui_set(value_2, value_3)
        value_2 = native_controls.pitch
        value_3 = anti_aim_state.holding_e
        if not value_3 then
            value_3 = "Default"
        else
            value_3 = "Off"
            if not "Off" then
                value_3 = "Default"
            end
        end
        ui_set(value_2, value_3)
        value_2 = script_controls.s
        value_1 = contains_value(value_2, "Manual AA")
        if not (not value_1) then
            value_2 = script_controls.ml
            value_1 = ui_get(value_2)
            if not value_1 then
                value_2 = script_controls.mr
                value_1 = ui_get(value_2)
                if not value_1 then
                    value_2 = script_controls.mf
                    value_1 = ui_get(value_2)
                    if not value_1 then
                        value_1 = anti_aim_state.dir.time
                        value_2 = curtime()
                        if not (value_2 >= value_1) then
                            value_1 = anti_aim_state.dir
                            value_1.time = curtime()
                        end
                    else
                        value_1 = anti_aim_state.dir.time + 0.2
                        value_2 = curtime()
                        if value_1 >= value_2 then
                            value_1 = anti_aim_state.dir.time
                            value_2 = curtime()
                            if not (value_2 >= value_1) then
                                value_1 = anti_aim_state.dir
                                value_1.time = curtime()
                            end
                        else
                            value_1 = anti_aim_state.dir
                            value_2 = anti_aim_state.dir.manual
                            if value_2 ~= 180 then
                                value_2 = 180
                            else
                                value_2 = 0
                                if not 0 then
                                    value_2 = 180
                                end
                            end
                            value_1.manual = value_2
                            value_1 = anti_aim_state.dir
                            value_1.time = curtime()
                        end
                    end
                else
                    value_1 = anti_aim_state.dir.time + 0.2
                    value_2 = curtime()
                    if value_1 >= value_2 then
                        value_2 = script_controls.mf
                        value_1 = ui_get(value_2)
                        if not value_1 then
                            value_1 = anti_aim_state.dir.time
                            value_2 = curtime()
                            if not (value_2 >= value_1) then
                                value_1 = anti_aim_state.dir
                                value_1.time = curtime()
                            end
                        else
                            value_1 = anti_aim_state.dir.time + 0.2
                            value_2 = curtime()
                            if value_1 >= value_2 then
                                value_1 = anti_aim_state.dir.time
                                value_2 = curtime()
                                if not (value_2 >= value_1) then
                                    value_1 = anti_aim_state.dir
                                    value_1.time = curtime()
                                end
                            else
                                value_1 = anti_aim_state.dir
                                value_2 = anti_aim_state.dir.manual
                                if value_2 ~= 180 then
                                    value_2 = 180
                                else
                                    value_2 = 0
                                    if not 0 then
                                        value_2 = 180
                                    end
                                end
                                value_1.manual = value_2
                                value_1 = anti_aim_state.dir
                                value_1.time = curtime()
                            end
                        end
                    else
                        value_1 = anti_aim_state.dir
                        value_2 = anti_aim_state.dir.manual
                        if value_2 ~= 90 then
                            value_2 = 90
                        else
                            value_2 = 0
                            if not 0 then
                                value_2 = 90
                            end
                        end
                        value_1.manual = value_2
                        value_1 = anti_aim_state.dir
                        value_1.time = curtime()
                    end
                end
            else
                value_1 = anti_aim_state.dir.time + 0.2
                value_2 = curtime()
                if value_1 >= value_2 then
                    value_2 = script_controls.mr
                    value_1 = ui_get(value_2)
                    if not value_1 then
                        value_2 = script_controls.mf
                        value_1 = ui_get(value_2)
                        if not value_1 then
                            value_1 = anti_aim_state.dir.time
                            value_2 = curtime()
                            if not (value_2 >= value_1) then
                                value_1 = anti_aim_state.dir
                                value_1.time = curtime()
                            end
                        else
                            value_1 = anti_aim_state.dir.time + 0.2
                            value_2 = curtime()
                            if value_1 >= value_2 then
                                value_1 = anti_aim_state.dir.time
                                value_2 = curtime()
                                if not (value_2 >= value_1) then
                                    value_1 = anti_aim_state.dir
                                    value_1.time = curtime()
                                end
                            else
                                value_1 = anti_aim_state.dir
                                value_2 = anti_aim_state.dir.manual
                                if value_2 ~= 180 then
                                    value_2 = 180
                                else
                                    value_2 = 0
                                    if not 0 then
                                        value_2 = 180
                                    end
                                end
                                value_1.manual = value_2
                                value_1 = anti_aim_state.dir
                                value_1.time = curtime()
                            end
                        end
                    else
                        value_1 = anti_aim_state.dir.time + 0.2
                        value_2 = curtime()
                        if value_1 >= value_2 then
                            value_2 = script_controls.mf
                            value_1 = ui_get(value_2)
                            if not value_1 then
                                value_1 = anti_aim_state.dir.time
                                value_2 = curtime()
                                if not (value_2 >= value_1) then
                                    value_1 = anti_aim_state.dir
                                    value_1.time = curtime()
                                end
                            else
                                value_1 = anti_aim_state.dir.time + 0.2
                                value_2 = curtime()
                                if value_1 >= value_2 then
                                    value_1 = anti_aim_state.dir.time
                                    value_2 = curtime()
                                    if not (value_2 >= value_1) then
                                        value_1 = anti_aim_state.dir
                                        value_1.time = curtime()
                                    end
                                else
                                    value_1 = anti_aim_state.dir
                                    value_2 = anti_aim_state.dir.manual
                                    if value_2 ~= 180 then
                                        value_2 = 180
                                    else
                                        value_2 = 0
                                        if not 0 then
                                            value_2 = 180
                                        end
                                    end
                                    value_1.manual = value_2
                                    value_1 = anti_aim_state.dir
                                    value_1.time = curtime()
                                end
                            end
                        else
                            value_1 = anti_aim_state.dir
                            value_2 = anti_aim_state.dir.manual
                            if value_2 ~= 90 then
                                value_2 = 90
                            else
                                value_2 = 0
                                if not 0 then
                                    value_2 = 90
                                end
                            end
                            value_1.manual = value_2
                            value_1 = anti_aim_state.dir
                            value_1.time = curtime()
                        end
                    end
                else
                    value_1 = anti_aim_state.dir
                    value_2 = anti_aim_state.dir.manual
                    if value_2 ~= -90 then
                        value_2 = -90
                    else
                        value_2 = 0
                        if not 0 then
                            value_2 = -90
                        end
                    end
                    value_1.manual = value_2
                    value_1 = anti_aim_state.dir
                    value_1.time = curtime()
                end
            end
            value_1 = anti_aim_state.dir.manual
            value_2 = anti_aim_state.stored_dir.manual
            if value_1 ~= value_2 then
                value_2 = native_controls.yaw[2]
                value_3 = anti_aim_state.dir.manual
                ui_set(value_2, value_3)
                value_1 = anti_aim_state.stored_dir
                value_1.manual = anti_aim_state.dir.manual
            end
            value_2 = native_controls.yaw[2]
            value_3 = anti_aim_state.dir.manual
            ui_set(value_2, value_3)
        end
        value_1 = anti_aim_state.dir
        value_3 = script_controls.s
        value_2 = contains_value(value_3, "Edge yaw")
        if not (not value_2) then
            value_3 = script_controls.ey
            value_2 = ui_get(value_3)
            if not (not value_2) then
                value_2 = not anti_aim_state.holding_e
            end
        end
        value_1.edge = value_2
        value_1 = anti_aim_state.dir
        value_3 = script_controls.s
        value_2 = contains_value(value_3, "Freestanding")
        if not (not value_2) then
            value_3 = script_controls.fs
            value_2 = ui_get(value_3)
            if not (not value_2) then
                value_2 = not anti_aim_state.holding_e
            end
        end
        value_1.freestand = value_2
        value_1 = anti_aim_state.dir.freestand
        value_2 = anti_aim_state.stored_dir.freestand
        if value_1 ~= value_2 then
            value_2 = native_controls.freestand[1]
            value_3 = anti_aim_state.dir.freestand
            if not value_3 then
                value_3 = "-"
            else
                value_3 = "Default"
                if not "Default" then
                    value_3 = "-"
                end
            end
            ui_set(value_2, value_3)
            value_2 = native_controls.freestand[2]
            ui_set(value_2, "Always on")
            value_1 = anti_aim_state.stored_dir
            value_1.freestand = anti_aim_state.dir.freestand
        end
        value_1 = anti_aim_state.dir.edge
        value_2 = anti_aim_state.stored_dir.edge
        if value_1 ~= value_2 then
            value_2 = native_controls.edgeyaw
            value_3 = anti_aim_state.dir.edge
            ui_set(value_2, value_3)
            value_1 = anti_aim_state.stored_dir
            value_1.edge = anti_aim_state.dir.edge
        end
        return
    end
    point_on_circle = function(center_x, center_y, angle, radius)
        local x = math_cos(math_rad(angle)) * radius + center_x
        local y = math_sin(math_rad(angle)) * radius + center_y
        return x, y
    end
    draw_indicator_triangle = function(argument_1, argument_2, argument_3, argument_4, argument_5, argument_6, argument_7, argument_8, argument_9, argument_10, argument_11, argument_12, argument_13)
        local value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23, value_24
        local value_25, value_30, value_31, value_32, value_33
        value_15 = argument_2 + 4
        value_13, value_14 = point_on_circle(argument_1, value_15, argument_11, 45)
        value_17 = argument_2 + 4
        value_18 = argument_12 / 3
        value_18 = argument_11 + value_18
        value_19 = argument_12 / 4
        value_19 = 45 - value_19
        value_15, value_16 = point_on_circle(argument_1, value_17, value_18, value_19)
        value_19 = argument_2 + 4
        value_21 = argument_12 / 5
        value_21 = 45 - value_21
        value_17, value_18 = point_on_circle(argument_1, value_19, argument_11, value_21)
        value_21 = argument_2 + 4
        value_23 = argument_12 / 5
        value_23 = 45 - value_23
        value_19, value_20 = point_on_circle(argument_1, value_21, argument_11, value_23)
        value_23 = argument_2 + 4
        value_24 = argument_12 / 3
        value_24 = argument_11 - value_24
        value_25 = argument_12 / 4
        value_25 = 45 - value_25
        value_21, value_22 = point_on_circle(argument_1, value_23, value_24, value_25)
        if not argument_13 then
            value_30 = argument_3
        else
            if argument_7 then
                value_30 = argument_7
            else
                value_30 = argument_3
            end
        end
        if not argument_13 then
            value_31 = argument_4
        else
            if argument_8 then
                value_31 = argument_8
            else
                value_31 = argument_4
            end
        end
        if not argument_13 then
            value_32 = argument_5
        else
            if argument_9 then
                value_32 = argument_9
            else
                value_32 = argument_5
            end
        end
        if not argument_13 then
            value_33 = argument_6
        else
            if argument_10 then
                value_33 = argument_10
            else
                value_33 = argument_6
            end
        end
        draw_triangle(value_13, value_14, value_15, value_16, value_17, value_18, value_30, value_31, value_32, value_33)
        if not argument_13 then
            value_30 = argument_7
        else
            if argument_3 then
                value_30 = argument_3
            else
                value_30 = argument_7
            end
        end
        if not argument_13 then
            value_31 = argument_8
        else
            if argument_4 then
                value_31 = argument_4
            else
                value_31 = argument_8
            end
        end
        if not argument_13 then
            value_32 = argument_9
        else
            if argument_5 then
                value_32 = argument_5
            else
                value_32 = argument_9
            end
        end
        if not argument_13 then
            value_33 = argument_10
        else
            if argument_6 then
                value_33 = argument_6
            else
                value_33 = argument_10
            end
        end
        draw_triangle(value_13, value_14, value_19, value_20, value_21, value_22, value_30, value_31, value_32, value_33)
        draw_line(value_13, value_14, value_19, value_20, 0, 0, 0, 200)
        return
    end
    apply_body_yaw = function(command)
        local value_1, value_2, value_3, value_4, value_5, value_6
        value_1 = get_local_player()
        value_2 = anti_aim_state.rec
        value_3 = (#anti_aim_state.rec) + 1
        value_4 = new_table(256)
        local returned_12 = pack_results(head_coordinates(value_1))
        for index = 1, returned_12.n do
            value_4[0 + index] = returned_12[index]
        end
        value_2[value_3] = value_4
        value_2 = #anti_aim_state.rec
        if not (28 >= value_2) then
            value_3 = anti_aim_state.rec
            table_remove(value_3, 1)
        end
        classify_movement(value_1, command)
        update_target_anti_aim(value_1)
        value_3 = handle_use_key(value_1, command)
        anti_aim_state.holding_e = value_3
        value_4 = anti_aim_state.holding_e
        update_manual_and_freestanding(value_1, value_4)
        value_3 = native_controls.bodyyaw[1]
        value_4 = anti_aim_state.desync
        if value_4 ~= 0 then
            value_4 = anti_aim_state.desync
            if value_4 ~= 180 then
                value_4 = "Static"
            else
                value_5 = script_controls.s
                value_4 = contains_value(value_5, "Jitter when not networked")
                if not value_4 then
                    value_4 = "Static"
                else
                    value_4 = "Jitter"
                    if not "Jitter" then
                        value_4 = "Static"
                    end
                end
            end
        else
            value_4 = "Off"
            if not "Off" then
                value_4 = anti_aim_state.desync
                if value_4 ~= 180 then
                    value_4 = "Static"
                else
                    value_5 = script_controls.s
                    value_4 = contains_value(value_5, "Jitter when not networked")
                    if not value_4 then
                        value_4 = "Static"
                    else
                        value_4 = "Jitter"
                        if not "Jitter" then
                            value_4 = "Static"
                        end
                    end
                end
            end
        end
        ui_set(value_3, value_4)
        value_3 = native_controls.bodyyaw[2]
        value_4 = anti_aim_state.desync
        if value_4 ~= 180 then
            value_4 = anti_aim_state.holding_e
            if not value_4 then
                value_4 = anti_aim_state.desync
            else
                value_4 = -anti_aim_state.desync
                if not value_4 then
                    value_4 = anti_aim_state.desync
                end
            end
        else
            value_4 = 0
            if not 0 then
                value_4 = anti_aim_state.holding_e
                if not value_4 then
                    value_4 = anti_aim_state.desync
                else
                    value_4 = -anti_aim_state.desync
                    if not value_4 then
                        value_4 = anti_aim_state.desync
                    end
                end
            end
        end
        ui_set(value_3, value_4)
        value_3 = native_controls.fakeyawlimit
        value_4 = script_controls.r
        value_5 = anti_aim_state.s_i
        value_6 = anti_aim_state.aa
        value_5 = value_5[value_6]
        value_4 = value_4[value_5]
        if value_3 ~= nil then
            ui_set(value_3, value_4)
        end
        set_native_ui_visible(false)
        return
    end
    on_bullet_impact = function(event)
        local value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8
        value_1 = get_local_player()
        value_3 = event.userid
        value_2 = userid_to_entindex(value_3)
        value_3 = is_enemy(value_2)
        if not value_3 then
            return
        else
            value_3 = is_alive(value_1)
            if not value_3 then
                return
            else
                value_3 = is_valid_player(value_2)
                if value_3 then
                    value_3 = target_info(value_2, event)
                    value_6 = anti_aim_state.ls
                    value_4 = target_record_info(value_3, value_6, value_2, value_1, event)
                    if not (not value_4) then
                        value_4 = #player_records[value_2].s
                        if 0 >= value_4 then
                            value_4 = (#player_records[value_2].s) + 1
                        else
                            value_4 = player_records[value_2].s
                            value_5 = #player_records[value_2].s
                            value_4 = value_4[value_5].t
                            value_5 = curtime()
                            if value_4 ~= value_5 then
                                value_4 = (#player_records[value_2].s) + 1
                            else
                                value_4 = #player_records[value_2].s
                                if not value_4 then
                                    value_4 = (#player_records[value_2].s) + 1
                                end
                            end
                        end
                        value_5 = anti_aim_state.desync
                        if value_5 == 0 then
                            value_5 = true
                        else
                            value_5 = anti_aim_state.desync
                            if value_5 == 180 then
                                value_5 = true
                            else
                                value_5 = script_controls["Detect missed angle"]
                            end
                        end
                        value_6 = anti_aim_state.desync
                        if value_6 ~= 90 then
                            value_6 = 90
                        else
                            value_6 = -90
                            if not (-90) then
                                value_6 = 90
                            end
                        end
                        if not (not value_5) then
                            value_7 = math_abs(value_3)
                            if value_7 >= 3 then
                                if 0 >= value_3 then
                                    value_6 = 90
                                else
                                    if (-90) then
                                        value_6 = (-90)
                                    else
                                        value_6 = 90
                                    end
                                end
                            else
                                value_6 = anti_aim_state.desync
                            end
                        end
                        value_7 = player_records[value_2].s
                        value_8 = new_table(256)
                        value_8.t = tickcount()
                        value_8.d = value_6
                        value_8.dis = value_3
                        value_7[value_4] = value_8
                    end
                    return
                else
                    return
                end
            end
        end
    end
    on_player_hurt = function(event)
        local value_1, value_2, value_3, value_4, value_5, value_6, value_8, value_9
        value_1 = get_local_player()
        value_3 = event.userid
        value_2 = userid_to_entindex(value_3)
        value_4 = event.attacker
        value_3 = userid_to_entindex(value_4)
        value_4 = is_enemy(value_3)
        if not value_4 then
            return
        else
            value_4 = is_alive(value_1)
            if value_4 then
                value_5 = #anti_aim_state.nonweapons
                for weapon_index = 0 + 1, 0 + value_5, 0 + 1 do
                    value_8 = event.weapon
                    value_9 = anti_aim_state.nonweapons[weapon_index]
                    if value_8 == value_9 then
                        return
                    end
                end
                value_4 = #player_records[value_3].h
                if 0 >= value_4 then
                    value_4 = (#player_records[value_3].h) + 1
                else
                    value_4 = #player_records[value_3].h
                    if not value_4 then
                        value_4 = (#player_records[value_3].h) + 1
                    end
                end
                value_5 = player_records[value_3].h
                value_6 = new_table(256)
                value_6.t = tickcount()
                value_6.d = environment.new_angle
                value_6.h = event.hitgroup
                value_6.v = value_2
                value_5[value_4] = value_6
                return
            else
                return
            end
        end
    end
    on_player_spawn = function(event)
        local value_1, value_2, value_3
        value_1 = get_local_player()
        value_3 = event.userid
        value_2 = userid_to_entindex(value_3)
        if value_2 == value_1 then
            reset_player_state(true)
        end
        return
    end
    draw_keybind_indicators = function()
        local value_0, value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11
        local value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23
        local value_24, value_27, value_28, value_30
        value_0 = get_local_player()
        update_shot_history(value_0)
        value_1 = is_alive(value_0)
        if value_1 then
            value_1 = new_table(256)
            local returned_13 = pack_results(screen_size())
            for index = 1, returned_13.n do
                value_1[0 + index] = returned_13[index]
            end
            value_2 = new_table(2)
            value_3 = value_1[1] / 2
            value_4 = value_1[2] / 2
            value_2[1] = value_3
            value_2[2] = value_4
            value_4 = script_controls.clr[2]
            value_3, value_4, value_5, value_6 = ui_get(value_4)
            value_8 = script_controls.clr2[2]
            value_7, value_8, value_9, value_10 = ui_get(value_8)
            value_11 = ((get_prop(value_0, "m_flPoseParameter", 11)) * 120) - 60
            value_12 = anti_aim_state.holding_e
            if not value_12 then
                value_12 = 1
            else
                value_12 = -1
                if not (-1) then
                    value_12 = 1
                end
            end
            value_11 = value_11 * value_12
            value_12 = 20
            value_14 = script_controls.s
            value_13 = contains_value(value_14, "AA indicator")
            if not (not value_13) then
                value_13 = new_table(256)
                local returned_54 = pack_results(camera_angles())
                for index = 1, returned_54.n do
                    value_13[0 + index] = returned_54[index]
                end
                value_14 = new_table(256)
                local returned_60 = pack_results(hitbox_position(value_0, "head_0"))
                for index = 1, returned_60.n do
                    value_14[0 + index] = returned_60[index]
                end
                value_15 = new_table(256)
                local returned_66 = pack_results(hitbox_position(value_0, "pelvis"))
                for index = 1, returned_66.n do
                    value_15[0 + index] = returned_66[index]
                end
                value_18 = value_15[1]
                value_19 = value_15[2]
                value_20 = value_14[1]
                value_21 = value_14[2]
                value_17 = yaw_between_points(value_18, value_19, value_20, value_21)
                value_18 = value_11 / 2
                value_17 = value_17 - value_18
                value_18 = value_13[2]
                value_17 = (value_17 - value_18) + 120
                value_16 = normalize_yaw(value_17)
                value_18 = value_2[1]
                value_19 = value_2[2]
                value_20 = value_3
                value_21 = value_4
                value_22 = value_5
                value_23 = value_6
                value_24 = value_7
                value_28 = value_11 / 1.5
                value_28 = (value_16 + value_28) * -1
                if value_11 < 0 then
                    value_30 = true
                else
                    value_30 = false
                end
                draw_indicator_triangle(value_18, value_19, value_3, value_4, value_5, value_6, value_7, value_8, value_9, 255, value_28, 60, value_30)
                value_12 = 48
            end
            value_14 = value_2[1] - 27
            value_15 = value_2[2] + value_12
            if 0 >= value_11 then
                value_16 = value_7
            else
                if value_3 then
                    value_16 = value_3
                else
                    value_16 = value_7
                end
            end
            if 0 >= value_11 then
                value_17 = value_8
            else
                if value_4 then
                    value_17 = value_4
                else
                    value_17 = value_8
                end
            end
            if 0 >= value_11 then
                value_18 = value_9
            else
                if value_5 then
                    value_18 = value_5
                else
                    value_18 = value_9
                end
            end
            if 0 >= value_11 then
                value_19 = 255
            else
                if value_6 then
                    value_19 = value_6
                else
                    value_19 = 255
                end
            end
            draw_text(value_14, value_15, value_16, value_17, value_18, value_19, "b", 0, "predi")
            value_14 = value_2[1]
            value_15 = value_2[2] + value_12
            if value_11 >= 0 then
                value_16 = value_7
            else
                if value_3 then
                    value_16 = value_3
                else
                    value_16 = value_7
                end
            end
            if value_11 >= 0 then
                value_17 = value_8
            else
                if value_4 then
                    value_17 = value_4
                else
                    value_17 = value_8
                end
            end
            if value_11 >= 0 then
                value_18 = value_9
            else
                if value_5 then
                    value_18 = value_5
                else
                    value_18 = value_9
                end
            end
            if value_11 >= 0 then
                value_19 = 255
            else
                if value_6 then
                    value_19 = value_6
                else
                    value_19 = 255
                end
            end
            draw_text(value_14, value_15, value_16, value_17, value_18, value_19, "b", 0, "ction°")
            value_14 = script_controls.s
            value_13 = contains_value(value_14, "Keybind indicator")
            if not (not value_13) then
                value_13 = new_table(256)
                value_15 = script_controls.k
                value_14 = contains_value(value_15, "Double tap")
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "DT"
                    value_17 = native_controls.dt[1]
                    value_16 = ui_get(value_17)
                    if not (not value_16) then
                        value_17 = native_controls.dt[2]
                        value_16 = ui_get(value_17)
                    end
                    value_15.e = value_16
                    value_13[value_14] = value_15
                end
                value_15 = script_controls.k
                value_14 = contains_value(value_15, "Onshot Anti-Aim")
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "OSAA"
                    value_17 = native_controls.os[1]
                    value_16 = ui_get(value_17)
                    if not (not value_16) then
                        value_17 = native_controls.os[2]
                        value_16 = ui_get(value_17)
                    end
                    value_15.e = value_16
                    value_13[value_14] = value_15
                end
                value_15 = script_controls.k
                value_14 = contains_value(value_15, "Force body aim")
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "BAIM"
                    value_17 = native_controls.forcebaim
                    value_15.e = ui_get(value_17)
                    value_13[value_14] = value_15
                end
                value_15 = script_controls.k
                value_14 = contains_value(value_15, "Force safe point")
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "SAFE"
                    value_17 = native_controls.safepoint
                    value_15.e = ui_get(value_17)
                    value_13[value_14] = value_15
                end
                value_15 = script_controls.k
                value_14 = contains_value(value_15, "Edge yaw")
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "EDGE"
                    value_17 = native_controls.edgeyaw
                    value_15.e = ui_get(value_17)
                    value_13[value_14] = value_15
                end
                value_15 = script_controls.k
                value_14 = contains_value(value_15, "Freestanding")
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "FREESTAND"
                    value_17 = native_controls.freestand[1]
                    value_16 = contains_value(value_17, "Default")
                    if not (not value_16) then
                        value_17 = native_controls.freestand[2]
                        value_16 = ui_get(value_17)
                    end
                    value_15.e = value_16
                    value_13[value_14] = value_15
                end
                value_15 = script_controls.k
                value_14 = contains_value(value_15, "Quick peek")
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "QUICKPEEK"
                    value_17 = native_controls.quickpeek[1]
                    value_16 = ui_get(value_17)
                    if not (not value_16) then
                        value_17 = native_controls.quickpeek[2]
                        value_16 = ui_get(value_17)
                    end
                    value_15.e = value_16
                    value_13[value_14] = value_15
                end
                value_15 = #value_13
                for bind_index = 0 + 1, 0 + value_15, 0 + 1 do
                    value_18 = draw_text
                    value_19 = value_2[1] - 1
                    value_20 = (value_2[2] + value_12) + 12
                    value_21 = bind_index * 11
                    value_20 = value_20 + value_21
                    value_21 = value_13[bind_index].e
                    if not value_21 then
                        value_21 = value_7
                    else
                        if value_3 then
                            value_21 = value_3
                        else
                            value_21 = value_7
                        end
                    end
                    value_22 = value_13[bind_index].e
                    if not value_22 then
                        value_22 = value_8
                    else
                        if value_4 then
                            value_22 = value_4
                        else
                            value_22 = value_8
                        end
                    end
                    value_23 = value_13[bind_index].e
                    if not value_23 then
                        value_23 = value_9
                    else
                        if value_5 then
                            value_23 = value_5
                        else
                            value_23 = value_9
                        end
                    end
                    value_24 = value_13[bind_index].e
                    if not value_24 then
                        value_24 = value_10 * 0.75
                    else
                        if value_6 then
                            value_24 = value_6
                        else
                            value_24 = value_10 * 0.75
                        end
                    end
                    value_27 = value_13[bind_index].t
                    draw_text(value_19, value_20, value_21, value_22, value_23, value_24, "c-", 0, value_27)
                end
            end
            return
        else
            return
        end
    end
    update_ui_visibility = function()
        local value_0, value_1, value_2, value_3
        value_1 = script_controls.s
        value_0 = contains_value(value_1, "Manual AA")
        if not value_0 then
            value_1 = native_controls.yaw[2]
            ui_set(value_1, 0)
        end
        value_1 = script_controls.ml
        value_3 = script_controls.s
        local returned_20 = pack_results(contains_value(value_3, "Manual AA"))
        ui_set_visible(value_1, unpack_results(returned_20, 1, returned_20.n))
        value_1 = script_controls.mr
        value_3 = script_controls.s
        local returned_29 = pack_results(contains_value(value_3, "Manual AA"))
        ui_set_visible(value_1, unpack_results(returned_29, 1, returned_29.n))
        value_1 = script_controls.mf
        value_3 = script_controls.s
        local returned_38 = pack_results(contains_value(value_3, "Manual AA"))
        ui_set_visible(value_1, unpack_results(returned_38, 1, returned_38.n))
        value_1 = script_controls.fs
        value_3 = script_controls.s
        local returned_47 = pack_results(contains_value(value_3, "Freestanding"))
        ui_set_visible(value_1, unpack_results(returned_47, 1, returned_47.n))
        value_1 = script_controls.ey
        value_3 = script_controls.s
        local returned_56 = pack_results(contains_value(value_3, "Edge yaw"))
        ui_set_visible(value_1, unpack_results(returned_56, 1, returned_56.n))
        value_1 = script_controls.k
        value_3 = script_controls.s
        local returned_65 = pack_results(contains_value(value_3, "Keybind indicator"))
        ui_set_visible(value_1, unpack_results(returned_65, 1, returned_65.n))
        value_1 = script_controls.clr[1]
        value_3 = script_controls.s
        value_2 = contains_value(value_3, "AA indicator")
        if not value_2 then
            value_3 = script_controls.s
            value_2 = contains_value(value_3, "Keybind indicator")
        end
        ui_set_visible(value_1, value_2)
        value_1 = script_controls.clr[2]
        value_3 = script_controls.s
        value_2 = contains_value(value_3, "AA indicator")
        if not value_2 then
            value_3 = script_controls.s
            value_2 = contains_value(value_3, "Keybind indicator")
        end
        ui_set_visible(value_1, value_2)
        value_1 = script_controls.clr2[1]
        value_3 = script_controls.s
        value_2 = contains_value(value_3, "AA indicator")
        if not value_2 then
            value_3 = script_controls.s
            value_2 = contains_value(value_3, "Keybind indicator")
        end
        ui_set_visible(value_1, value_2)
        value_1 = script_controls.clr2[2]
        value_3 = script_controls.s
        value_2 = contains_value(value_3, "AA indicator")
        if not value_2 then
            value_3 = script_controls.s
            value_2 = contains_value(value_3, "Keybind indicator")
        end
        ui_set_visible(value_1, value_2)
        set_native_ui_visible(false)
        return
    end
    get_steam_identity = function()
        local value_0, value_1, value_2, value_3, value_4
        value_0 = environment.database.read
        value_1 = anti_aim_state.nonweapons[1]
        value_2 = anti_aim_state.nonweapons[3]
        value_1 = value_1..value_2
        value_0 = value_0(value_1)
        value_1 = environment.panorama.open()
        value_2 = value_1.MyPersonaAPI
        if value_0 ~= nil then
            value_3 = value_0
        else
            value_3 = value_2.GetXuid()
            if not value_3 then
                value_3 = value_0
            end
        end
        if value_0 == nil then
            value_4 = true
        else
            value_4 = false
        end
        return value_3, value_4
    end
    whitelisted_steam_id = 0
    whitelist_initialized = false
    next_whitelist_poll = 0
    update_whitelist = function()
        local value_0, value_1, value_2, value_3, value_4
        value_0 = next_whitelist_poll
        value_1 = environment.globals.curtime()
        if value_0 >= value_1 then
            return
        else
            next_whitelist_poll = (environment.globals.curtime()) + 60
            value_0, value_1 = get_steam_identity()
            value_2 = environment.panorama.loadstring("\009\009$.AsyncWebRequest('https://jok3r.cc/64storage.txt', {type: 'GET', complete: function(sigma) {\010\009\009\009response = sigma.responseText;\010\009\009}});\010\009\009return response;\010\009\009")
            value_3 = value_2()
            if value_3 ~= nil then
                value_4 = environment.string.match(value_3, value_0)
                if not (not value_4) then
                    whitelisted_steam_id = value_0
                end
                return value_0
            else
                value_4 = environment.client.color_log
                return value_4(255, 0, 0, "Loading STEAM IDs, if not loading turn off VPN")
            end
        end
    end
    register_events_if_whitelisted = function()
        local value_0, value_1, value_2
        value_0 = update_whitelist()
        if whitelisted_steam_id ~= value_0 then
            value_1 = environment.client.set_event_callback
            local draw_not_whitelisted = function()
                local value_0
                value_0 = environment.renderer.indicator
                value_0(255, 0, 0, 255, "[amgis corporations] prediction not whitelisted on this account - check console")
                return
            end
            value_1("paint_ui", draw_not_whitelisted)
            value_1 = environment.client.log
            value_2 = "You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> "..value_0
            value_1(value_2)
            value_1 = environment.client.log
            value_2 = "You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> "..value_0
            value_1(value_2)
            value_1 = environment.client.log
            value_2 = "You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> "..value_0
            value_1(value_2)
            value_1 = environment.client.log
            value_2 = "You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> "..value_0
            value_1(value_2)
            value_1 = environment.client.log
            value_2 = "You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> "..value_0
            value_1(value_2)
            value_1 = environment.client.log
            value_2 = "You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> "..value_0
            value_1(value_2)
            value_1 = environment.client.log
            value_2 = "You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> "..value_0
            value_1(value_2)
            value_1 = environment.client.log
            value_2 = "You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> "..value_0
            value_1(value_2)
            return
        else
            whitelisted_steam_id = 0
            value_1 = environment.client.log
            value_1("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!")
            value_1 = environment.client.log
            value_1("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!")
            value_1 = environment.client.log
            value_1("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!")
            value_1 = environment.client.log
            value_1("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!")
            whitelist_initialized = true
            if not (not true) then
                update_ui_visibility()
                value_2 = script_controls.s
                ui_set_callback(value_2, update_ui_visibility)
                set_event_callback("shutdown", set_native_ui_visible)
                set_event_callback("paint", draw_keybind_indicators)
                set_event_callback("bullet_impact", on_bullet_impact)
                set_event_callback("player_hurt", on_player_hurt)
                set_event_callback("setup_command", apply_body_yaw)
                set_event_callback("player_spawn", on_player_spawn)
                set_event_callback("client_disconnect", reset_player_state)
                set_event_callback("cs_game_disconnected", reset_player_state)
                set_event_callback("game_newmap", reset_player_state)
            end
            return
        end
    end
    register_events_if_whitelisted()
    custom_indicator_enabled = environment.ui.new_checkbox("AA", "Anti-aimbot angles", "Custom Indicator")
    background_label_1 = environment.ui.new_label("AA", "Anti-aimbot angles", "Background color 1")
    background_color_1 = environment.ui.new_color_picker("AA", "Anti-aimbot angles", "Main Backround picker 1 [indicator]", 0, 170, 255, 150)
    background_label_2 = environment.ui.new_label("AA", "Anti-aimbot angles", "Background color 2")
    background_color_2 = environment.ui.new_color_picker("AA", "Anti-aimbot angles", "Main Backround picker 2 [indicator]", 255, 150, 150, 150)
    accent_label_1 = environment.ui.new_label("AA", "Anti-aimbot angles", "Accent color 1")
    accent_color_1 = environment.ui.new_color_picker("AA", "Anti-aimbot angles", "Accent Backround picker 1 [indicator]", 0, 170, 255, 255)
    accent_label_2 = environment.ui.new_label("AA", "Anti-aimbot angles", "Accent color 2")
    accent_color_2 = environment.ui.new_color_picker("AA", "Anti-aimbot angles", "Accent Backround picker 2 [indicator]", 255, 150, 150, 255)
    indicator_x = environment.ui.new_slider("AA", "Anti-aimbot angles", "Saved position x", 0, 1920, 10)
    indicator_y = environment.ui.new_slider("AA", "Anti-aimbot angles", "Saved position y", 0, 1080, 400)
    indicator_drag_key = environment.ui.new_hotkey("LUA", "B", "Mouse 1")
    onshot_enabled = environment.ui.reference
    onshot_enabled, onshot_key = onshot_enabled("AA", "Other", "On shot anti-aim")
    force_safe_point = environment.ui.reference("RAGE", "Aimbot", "Force safe point")
    double_tap_enabled = environment.ui.reference
    double_tap_enabled, double_tap_key = double_tap_enabled("RAGE", "Other", "Double tap")
    force_body_aim = environment.ui.reference("RAGE", "Other", "Force body aim")
    duck_peek_assist = environment.ui.reference("RAGE", "Other", "Duck peek assist")
    indicator_dimensions = new_table(256)
    indicator_dimensions.x = 150
    indicator_dimensions.y = 100
    choked_commands = 0
    is_mouse_in_rectangle = function(x, y, width, height)
        local mouse_x, mouse_y = environment.ui.mouse_position()
        if not environment.ui.get(indicator_drag_key) then
            return false
        end
        return x < mouse_x and mouse_x < x + width and y < mouse_y and mouse_y < y + height
    end
    drag_origin_x = environment.client.set_event_callback
    local track_choked_commands = function(command)
        choked_commands = command.chokedcommands
    end
    drag_origin_x("setup_command", track_choked_commands)
    drag_origin_x = 0
    drag_origin_y = 0
    indicator_alpha = 255
    indicator_scale = 1
    indicator_dragging = false
    unused_callback = environment.client.set_event_callback
    local draw_custom_indicator = function()
        local value_0, value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11
        local value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23
        local value_24, value_25, value_26, value_27, value_29, value_30, value_31, value_32, value_33, value_34
        local value_37, value_38, value_40
        value_0 = environment.ui.get(custom_indicator_enabled)
        if value_0 then
            value_0 = environment.client.screen_size
            value_0, value_1 = value_0()
            value_2 = environment.ui.mouse_position
            value_2, value_3 = value_2()
            value_4 = new_table(256)
            value_4.x = value_0 / 2
            value_4.y = value_1 / 2
            value_5 = environment.ui.get
            value_5, value_6, value_7, value_8 = value_5(background_color_1)
            value_9 = environment.ui.get
            value_9, value_10, value_11, value_12 = value_9(background_color_2)
            value_13 = environment.ui.get
            value_13, value_14, value_15, value_16 = value_13(accent_color_1)
            value_17 = environment.ui.get
            value_17, value_18, value_19, value_20 = value_17(accent_color_2)
            value_22 = environment.ui.get(indicator_x)
            value_23 = environment.ui.get(indicator_y)
            value_24 = indicator_dimensions.x
            value_25 = indicator_dimensions.y
            value_21 = is_mouse_in_rectangle(value_22, value_23, value_24, value_25)
            if not value_21 then
                drag_origin_y = value_3
                drag_origin_x = value_2
            else
                value_21 = (environment.ui.get(indicator_x)) - drag_origin_x
                value_22 = (environment.ui.get(indicator_y)) - drag_origin_y
                value_23 = environment.ui.set
                value_25 = value_2 + value_21
                value_23(indicator_x, value_25)
                value_23 = environment.ui.set
                value_25 = value_3 + value_22
                value_23(indicator_y, value_25)
                drag_origin_y = value_3
                drag_origin_x = value_2
            end
            if 255 > indicator_alpha then
                if not (indicator_alpha > 50) then
                    if not (not indicator_dragging) then
                        indicator_dragging = false
                    end
                end
            else
                indicator_dragging = true
            end
            if not indicator_dragging then
                value_21 = 1
            else
                value_21 = -1
                if not (-1) then
                    value_21 = 1
                end
            end
            indicator_scale = value_21
            indicator_alpha = indicator_alpha + indicator_scale
            value_21 = environment.renderer.gradient
            value_22 = environment.ui.get(indicator_x)
            value_23 = environment.ui.get(indicator_y)
            value_24 = indicator_dimensions.x
            value_25 = indicator_dimensions.y
            value_21(value_22, value_23, value_24, value_25, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, false)
            value_21 = environment.renderer.rectangle
            value_22 = environment.ui.get
            value_22 = (value_22(indicator_x)) + 1
            value_23 = environment.ui.get
            value_23 = (value_23(indicator_y)) + 1
            value_24 = indicator_dimensions.x - 2
            value_25 = indicator_dimensions.y - 2
            value_21(value_22, value_23, value_24, value_25, 25, 25, 25, 175)
            value_21 = environment.renderer.text
            value_22 = environment.ui.get(indicator_x)
            value_23 = indicator_dimensions.x / 2
            value_22 = value_22 + value_23
            value_23 = environment.ui.get
            value_23 = (value_23(indicator_y)) + 8
            value_21(value_22, value_23, 255, 255, 255, 255, "cb", 0, "shoppy.gg/@amgis")
            value_21 = environment.renderer.gradient
            value_22 = environment.ui.get
            value_22 = (value_22(indicator_x)) + 5
            value_23 = environment.ui.get
            value_23 = (value_23(indicator_y)) + 18
            value_24 = indicator_dimensions.x - 10
            value_21(value_22, value_23, value_24, 2, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, true)
            value_21 = environment.math.min
            value_23 = choked_commands / 14
            value_21 = value_21(1, value_23)
            value_22 = environment.renderer.text
            value_23 = environment.ui.get
            value_23 = (value_23(indicator_x)) + 5
            value_24 = environment.ui.get
            value_24 = (value_24(indicator_y)) + 23
            value_22(value_23, value_24, 255, 255, 255, 255, nil, 0, "choke: ")
            value_22 = environment.renderer.rectangle
            value_23 = environment.ui.get
            value_23 = (value_23(indicator_x)) + 40
            value_24 = environment.ui.get
            value_24 = (value_24(indicator_y)) + 27
            value_25 = indicator_dimensions.x - 60
            value_22(value_23, value_24, value_25, 6, 25, 25, 25, 175)
            value_22 = environment.renderer.gradient
            value_23 = environment.ui.get
            value_23 = (value_23(indicator_x)) + 41
            value_24 = environment.ui.get
            value_24 = (value_24(indicator_y)) + 28
            value_25 = (indicator_dimensions.x - 62) * value_21
            value_22(value_23, value_24, value_25, 4, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, true)
            value_22 = environment.renderer.text
            value_23 = environment.ui.get(indicator_x)
            value_24 = indicator_dimensions.x
            value_23 = (value_23 + value_24) - 15
            value_24 = environment.ui.get
            value_24 = (value_24(indicator_y)) + 25
            value_31 = environment.tostring
            local returned_292 = pack_results(value_31(choked_commands))
            value_22(value_23, value_24, 255, 255, 255, 255, "-", 0, unpack_results(returned_292, 1, returned_292.n))
            value_22 = environment.entity.get_prop
            value_23 = environment.entity.get_local_player()
            value_22 = value_22(value_23, "m_flPoseParameter", 11)
            value_23 = value_22 * 116
            value_22 = value_23 - 58
            value_23 = environment.math.abs
            value_23 = (value_23(value_22)) / 58
            value_24 = environment.renderer.text
            value_25 = environment.ui.get
            value_25 = (value_25(indicator_x)) + 5
            value_26 = environment.ui.get
            value_26 = (value_26(indicator_y)) + 35
            value_24(value_25, value_26, 255, 255, 255, 255, nil, 0, "desync: ")
            value_24 = environment.renderer.rectangle
            value_25 = environment.ui.get
            value_25 = (value_25(indicator_x)) + 45
            value_26 = environment.ui.get
            value_26 = (value_26(indicator_y)) + 40
            value_27 = indicator_dimensions.x - 65
            value_24(value_25, value_26, value_27, 6, 25, 25, 25, 175)
            value_24 = environment.renderer.gradient
            value_25 = environment.ui.get
            value_25 = (value_25(indicator_x)) + 46
            value_26 = environment.ui.get
            value_26 = (value_26(indicator_y)) + 40
            value_27 = (indicator_dimensions.x - 67) * value_23
            value_24(value_25, value_26, value_27, 4, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, true)
            value_24 = environment.renderer.text
            value_25 = environment.ui.get(indicator_x)
            value_26 = indicator_dimensions.x
            value_25 = (value_25 + value_26) - 18
            value_26 = environment.ui.get
            value_26 = (value_26(indicator_y)) + 37
            value_29 = 255
            value_30 = 255
            value_31 = "-"
            value_32 = 0
            value_33 = environment.tostring
            value_34 = environment.math.floor
            local returned_402 = pack_results(value_34(value_22))
            local returned_403 = pack_results(value_33(unpack_results(returned_402, 1, returned_402.n)))
            value_24(value_25, value_26, 255, 255, 255, 255, "-", 0, unpack_results(returned_403, 1, returned_403.n))
            value_24 = new_table(256)
            value_25 = new_table(256)
            value_26 = environment.ui.get(onshot_enabled)
            if not (not value_26) then
                value_26 = environment.ui.get(onshot_key)
                if not (not value_26) then
                    value_26 = (#value_24) + 1
                    value_24[value_26] = "hide"
                    value_26 = #value_24
                    value_25[value_26] = true
                end
            end
            value_26 = environment.ui.get(force_safe_point)
            if not (not value_26) then
                value_26 = (#value_24) + 1
                value_24[value_26] = "safe"
                value_26 = #value_24
                value_25[value_26] = true
            end
            value_26 = environment.ui.get(double_tap_enabled)
            if not (not value_26) then
                value_26 = environment.ui.get(double_tap_key)
                if not (not value_26) then
                    value_26 = (#value_24) + 1
                    value_24[value_26] = "double tap"
                    value_26 = #value_24
                    value_25[value_26] = true
                end
            end
            value_26 = environment.ui.get(force_body_aim)
            if not (not value_26) then
                value_26 = (#value_24) + 1
                value_24[value_26] = "force baim"
                value_26 = #value_24
                value_25[value_26] = true
            end
            value_26 = environment.ui.get(duck_peek_assist)
            if not (not value_26) then
                value_26 = (#value_24) + 1
                value_24[value_26] = "duck"
                value_26 = #value_24
                value_25[value_26] = true
            end
            value_27 = (#value_24) * 15
            value_27 = 60 + value_27
            indicator_dimensions.y = value_27
            value_27 = #value_24
            for label_index = 0 + 1, 0 + value_27, 0 + 1 do
                value_30 = value_25[label_index]
                if not value_30 then
                    value_30 = 255
                else
                    value_30 = indicator_alpha
                    if not indicator_alpha then
                        value_30 = 255
                    end
                end
                value_31 = environment.renderer.text
                value_32 = environment.ui.get
                value_32 = (value_32(indicator_x)) + 5
                value_33 = environment.ui.get
                value_33 = (value_33(indicator_y)) + 32
                value_34 = label_index * 15
                value_33 = value_33 + value_34
                value_37 = value_30
                value_38 = nil
                value_40 = value_24[label_index]
                value_31(value_32, value_33, 255, 255, 255, value_30, nil, 0, value_40)
            end
            return
        else
            return
        end
    end
    unused_callback("paint", draw_custom_indicator)
    unused_callback = function()
        return
    end
    crouching_ct_fake_yaw = environment.client.set_event_callback
    local reset_body_yaw = function()
        local value_0, value_1
        value_0 = environment.ui.set
        value_1 = native_controls.bodyyaw[2]
        value_0(value_1, 0)
        return
    end
    crouching_ct_fake_yaw("aim_fire", reset_body_yaw)
    crouching_ct_fake_yaw = native_controls.fakeyawlimit
    value_118 = environment.client.set_event_callback
    local adjust_crouching_ct_setting = function(command)
        local value_1, value_2, value_3
        value_1 = environment.entity.get_prop
        value_2 = environment.entity.get_local_player()
        value_1 = value_1(value_2, "m_iTeamNum")
        value_2 = environment.entity.get_prop
        value_3 = environment.entity.get_local_player()
        value_2 = value_2(value_3, "m_flDuckAmount")
        if 0.7 < value_2 then
            value_2 = true
        else
            value_2 = false
        end
        if value_1 == 3 then
            if not (not value_2) then
                value_3 = environment.ui.set
                value_3(crouching_ct_fake_yaw, 30)
            end
        end
        return
    end
    if crouching_ct_fake_yaw ~= nil then
        value_118("setup_command", adjust_crouching_ct_setting)
    end
    return
end
return main(...)
