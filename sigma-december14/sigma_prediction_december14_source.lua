-- Sigma Prediction Dec. 14, 2021: all 75 recovered application bodies.
-- PSU VM and byte stream removed; names inferred. See README_RU.txt.
local http = require("gamesense/http")
local http_get = http.get
local renderer_text = renderer.text
http.get = function(url, callback)
  if url:find("shav.it") then
    return callback(true, { status = 200 })
  end
  return http_get(url, callback)
end
renderer.text = function(...)
  if tostring(({...})[select("#", ...)]):find("shoppy") or tostring(({...})[select("#", ...)]):find("amgis") then
    return
  end
  return renderer_text(...)
end

local function __dec14_pack_results(...)
    return {n = select('#', ...), ...}
end

-- Resolve known legacy menu paths without changing the global GameSense API.
local function compatible_reference(tab, container, name)
    local results = __dec14_pack_results(pcall(ui.reference, tab, container, name))
    if results[1] then return unpack(results, 2, results.n) end
    if not tostring(results[2]):find('not found', 1, true) then error(results[2], 2) end
    if tab:lower() == 'rage' and container:lower() == 'other' and (name == 'Double tap' or name == 'Force body aim') then
        return ui.reference(tab, 'Aimbot', name)
    end
    if name == 'Fake yaw limit' then
        client.log('[sigma dec14] Fake yaw limit is unavailable; its visibility and limit writes are skipped.')
        return nil
    end
    error(results[2], 2)
end

local function main(...)
    local http_module, vector_module, get_value_type, set_metatable, to_string, math_pi, math_min, math_max, math_degrees, math_radians, math_square_root, math_sine, math_cosine, math_arctangent, math_arccosine, math_remainder, vector_metatable, base64_module, extract_bits, base64_encoder, base64_decoder, string_char, table_concat, bit_band, camera_angles, eye_position, key_state, scale_damage, screen_size, set_event_callback, trace_bullet, trace_line, userid_to_entindex, get_all_entities, get_classname, get_local_player, get_player_resource, get_players, get_prop, hitbox_position, is_alive, is_dormant, is_enemy, curtime, tickcount, tickinterval, math_abs, math_atan, math_atan2, math_cos, math_deg, math_rad, math_sin, math_sqrt, draw_gradient, draw_line, draw_text, draw_triangle, table_remove, ui_get, ui_new_color_picker, ui_new_hotkey, ui_new_label, ui_new_multiselect, ui_reference, ui_set, ui_set_callback, ui_set_visible, type_alias, ui_new_slider, native_controls, set_native_ui_visible, script_controls, anti_aim_state, player_records, contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1
    http_module = require(("gamesense/http"))
    vector_module = require(("vector"))
    get_value_type = type
    set_metatable = setmetatable
    to_string = tostring
    math_pi = math.pi
    math_min = math.min
    math_max = math.max
    math_degrees = math.deg
    math_radians = math.rad
    math_square_root = math.sqrt
    math_sine = math.sin
    math_cosine = math.cos
    math_arctangent = math.atan
    math_arccosine = math.acos
    math_remainder = math.fmod
    vector_metatable = {
    }
    vector_metatable.__index = vector_metatable
    Vector3 = function(argument_0_2, argument_1_2, argument_2_2, ...)
        local value_3_2, value_4_2
        value_3_2 = get_value_type(argument_0_2)
        if value_3_2 ~= "number" then
            argument_0_2 = 0
        end
        value_3_2 = get_value_type(argument_1_2)
        if value_3_2 ~= "number" then
            argument_1_2 = 0
        end
        value_3_2 = get_value_type(argument_2_2)
        if value_3_2 ~= "number" then
            argument_2_2 = 0
        end
        if not argument_0_2 then
            argument_0_2 = 0
        end
        if not argument_1_2 then
            argument_1_2 = 0
        end
        if not argument_2_2 then
            argument_2_2 = 0
        end
        value_4_2 = {
        }
        value_4_2.x = argument_0_2
        value_4_2.y = argument_1_2
        value_4_2.z = argument_2_2
        return set_metatable(value_4_2, vector_metatable)
    end
    vector_metatable.__eq = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2
        value_2_2 = argument_0_2.x
        value_3_2 = argument_1_2.x
        if value_2_2 == value_3_2 then
            value_2_2 = argument_0_2.y
            value_3_2 = argument_1_2.y
            if value_2_2 == value_3_2 then
                value_2_2 = argument_0_2.z
                value_3_2 = argument_1_2.z
                if value_2_2 == value_3_2 then
                    value_2_2 = true
                else
                    value_2_2 = false
                end
            else
                value_2_2 = false
            end
        else
            value_2_2 = false
        end
        return value_2_2
    end
    vector_metatable.__unm = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2, value_4_2
        value_1_2 = Vector3
        value_2_2 = -(argument_0_2.x)
        value_3_2 = -(argument_0_2.y)
        value_4_2 = -(argument_0_2.z)
        return value_1_2(value_2_2, value_3_2, value_4_2)
    end
    vector_metatable.__add = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2
        value_2_2 = get_value_type(argument_0_2)
        value_3_2 = get_value_type(argument_1_2)
        if value_2_2 == "table" and value_3_2 == "table" then
            value_4_2 = Vector3
            value_5_2 = argument_0_2.x
            value_6_2 = argument_1_2.x
            value_5_2 = value_5_2 + value_6_2
            value_6_2 = argument_0_2.y
            value_7_2 = argument_1_2.y
            value_6_2 = value_6_2 + value_7_2
            value_7_2 = argument_0_2.z
            value_8_2 = argument_1_2.z
            value_7_2 = value_7_2 + value_8_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
        if value_2_2 == "table" and value_3_2 == "number" then
            value_4_2 = Vector3
            value_5_2 = (argument_0_2.x) + argument_1_2
            value_6_2 = (argument_0_2.y) + argument_1_2
            value_7_2 = (argument_0_2.z) + argument_1_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
        if value_2_2 == "number" and value_3_2 == "table" then
            value_4_2 = Vector3
            value_5_2 = argument_1_2.x
            value_5_2 = argument_0_2 + value_5_2
            value_6_2 = argument_1_2.y
            value_6_2 = argument_0_2 + value_6_2
            value_7_2 = argument_1_2.z
            value_7_2 = argument_0_2 + value_7_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
    end
    vector_metatable.__sub = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2
        value_2_2 = get_value_type(argument_0_2)
        value_3_2 = get_value_type(argument_1_2)
        if value_2_2 == "table" and value_3_2 == "table" then
            value_4_2 = Vector3
            value_5_2 = argument_0_2.x
            value_6_2 = argument_1_2.x
            value_5_2 = value_5_2 - value_6_2
            value_6_2 = argument_0_2.y
            value_7_2 = argument_1_2.y
            value_6_2 = value_6_2 - value_7_2
            value_7_2 = argument_0_2.z
            value_8_2 = argument_1_2.z
            value_7_2 = value_7_2 - value_8_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
        if value_2_2 == "table" and value_3_2 == "number" then
            value_4_2 = Vector3
            value_5_2 = (argument_0_2.x) - argument_1_2
            value_6_2 = (argument_0_2.y) - argument_1_2
            value_7_2 = (argument_0_2.z) - argument_1_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
        if value_2_2 == "number" and value_3_2 == "table" then
            value_4_2 = Vector3
            value_5_2 = argument_1_2.x
            value_5_2 = argument_0_2 - value_5_2
            value_6_2 = argument_1_2.y
            value_6_2 = argument_0_2 - value_6_2
            value_7_2 = argument_1_2.z
            value_7_2 = argument_0_2 - value_7_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
    end
    vector_metatable.__mul = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2
        value_2_2 = get_value_type(argument_0_2)
        value_3_2 = get_value_type(argument_1_2)
        if value_2_2 == "table" and value_3_2 == "table" then
            value_4_2 = Vector3
            value_5_2 = argument_0_2.x
            value_6_2 = argument_1_2.x
            value_5_2 = value_5_2 * value_6_2
            value_6_2 = argument_0_2.y
            value_7_2 = argument_1_2.y
            value_6_2 = value_6_2 * value_7_2
            value_7_2 = argument_0_2.z
            value_8_2 = argument_1_2.z
            value_7_2 = value_7_2 * value_8_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
        if value_2_2 == "table" and value_3_2 == "number" then
            value_4_2 = Vector3
            value_5_2 = (argument_0_2.x) * argument_1_2
            value_6_2 = (argument_0_2.y) * argument_1_2
            value_7_2 = (argument_0_2.z) * argument_1_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
        if value_2_2 == "number" and value_3_2 == "table" then
            value_4_2 = Vector3
            value_5_2 = argument_1_2.x
            value_5_2 = argument_0_2 * value_5_2
            value_6_2 = argument_1_2.y
            value_6_2 = argument_0_2 * value_6_2
            value_7_2 = argument_1_2.z
            value_7_2 = argument_0_2 * value_7_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
    end
    vector_metatable.__div = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2
        value_2_2 = get_value_type(argument_0_2)
        value_3_2 = get_value_type(argument_1_2)
        if value_2_2 == "table" and value_3_2 == "table" then
            value_4_2 = Vector3
            value_5_2 = argument_0_2.x
            value_6_2 = argument_1_2.x
            value_5_2 = value_5_2 / value_6_2
            value_6_2 = argument_0_2.y
            value_7_2 = argument_1_2.y
            value_6_2 = value_6_2 / value_7_2
            value_7_2 = argument_0_2.z
            value_8_2 = argument_1_2.z
            value_7_2 = value_7_2 / value_8_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
        if value_2_2 == "table" and value_3_2 == "number" then
            value_4_2 = Vector3
            value_5_2 = (argument_0_2.x) / argument_1_2
            value_6_2 = (argument_0_2.y) / argument_1_2
            value_7_2 = (argument_0_2.z) / argument_1_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
        if value_2_2 == "number" and value_3_2 == "table" then
            value_4_2 = Vector3
            value_5_2 = argument_1_2.x
            value_5_2 = argument_0_2 / value_5_2
            value_6_2 = argument_1_2.y
            value_6_2 = argument_0_2 / value_6_2
            value_7_2 = argument_1_2.z
            value_7_2 = argument_0_2 / value_7_2
            return value_4_2(value_5_2, value_6_2, value_7_2)
        end
    end
    vector_metatable.__tostring = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_4_2, value_6_2
        value_2_2 = argument_0_2.x
        value_4_2 = argument_0_2.y
        value_6_2 = argument_0_2.z
        value_1_2 = ("( ")..value_2_2..(", ")..value_4_2..(", ")..value_6_2..(" )")
        return value_1_2
    end
    vector_metatable.clear = function(argument_0_2, ...)
        argument_0_2.x = 0
        argument_0_2.y = 0
        argument_0_2.z = 0
    end
    vector_metatable.unpack = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2
        value_1_2 = argument_0_2.x
        value_2_2 = argument_0_2.y
        value_3_2 = argument_0_2.z
        return value_1_2, value_2_2, value_3_2
    end
    vector_metatable.length_2d_sqr = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2
        value_1_2 = argument_0_2.x
        value_2_2 = argument_0_2.x
        value_1_2 = value_1_2 * value_2_2
        value_2_2 = argument_0_2.y
        value_3_2 = argument_0_2.y
        value_2_2 = value_2_2 * value_3_2
        value_1_2 = value_1_2 + value_2_2
        return value_1_2
    end
    vector_metatable.length_sqr = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2
        value_1_2 = argument_0_2.x
        value_2_2 = argument_0_2.x
        value_1_2 = value_1_2 * value_2_2
        value_2_2 = argument_0_2.y
        value_3_2 = argument_0_2.y
        value_2_2 = value_2_2 * value_3_2
        value_1_2 = value_1_2 + value_2_2
        value_2_2 = argument_0_2.z
        value_3_2 = argument_0_2.z
        value_2_2 = value_2_2 * value_3_2
        value_1_2 = value_1_2 + value_2_2
        return value_1_2
    end
    vector_metatable.length_2d = function(argument_0_2, ...)
        local value_2_2, value_3_2
        value_2_2 = argument_0_2.length_2d_sqr
        local returned_13_0 = __dec14_pack_results(value_2_2(argument_0_2))
        value_2_2, value_3_2 = unpack(returned_13_0, 1, returned_13_0.n)
        return math_square_root(unpack(returned_13_0, 1, returned_13_0.n))
    end
    vector_metatable.length = function(argument_0_2, ...)
        local value_2_2, value_3_2
        value_2_2 = argument_0_2.length_sqr
        local returned_14_1 = __dec14_pack_results(value_2_2(argument_0_2))
        value_2_2, value_3_2 = unpack(returned_14_1, 1, returned_14_1.n)
        return math_square_root(unpack(returned_14_1, 1, returned_14_1.n))
    end
    vector_metatable.dot = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_4_2
        value_2_2 = argument_0_2.x
        value_3_2 = argument_1_2.x
        value_2_2 = value_2_2 * value_3_2
        value_3_2 = argument_0_2.y
        value_4_2 = argument_1_2.y
        value_3_2 = value_3_2 * value_4_2
        value_2_2 = value_2_2 + value_3_2
        value_3_2 = argument_0_2.z
        value_4_2 = argument_1_2.z
        value_3_2 = value_3_2 * value_4_2
        value_2_2 = value_2_2 + value_3_2
        return value_2_2
    end
    vector_metatable.cross = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2
        value_2_2 = Vector3
        value_3_2 = argument_0_2.y
        value_4_2 = argument_1_2.z
        value_3_2 = value_3_2 * value_4_2
        value_4_2 = argument_0_2.z
        value_5_2 = argument_1_2.y
        value_4_2 = value_4_2 * value_5_2
        value_3_2 = value_3_2 - value_4_2
        value_4_2 = argument_0_2.z
        value_5_2 = argument_1_2.x
        value_4_2 = value_4_2 * value_5_2
        value_5_2 = argument_0_2.x
        value_6_2 = argument_1_2.z
        value_5_2 = value_5_2 * value_6_2
        value_4_2 = value_4_2 - value_5_2
        value_5_2 = argument_0_2.x
        value_6_2 = argument_1_2.y
        value_5_2 = value_5_2 * value_6_2
        value_6_2 = argument_0_2.y
        value_7_2 = argument_1_2.x
        value_6_2 = value_6_2 * value_7_2
        value_5_2 = value_5_2 - value_6_2
        return value_2_2(value_3_2, value_4_2, value_5_2)
    end
    vector_metatable.dist_to = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2
        value_2_2 = argument_1_2 - argument_0_2
        value_3_2 = value_2_2
        value_2_2 = value_2_2.length
        return value_2_2(value_3_2)
    end
    vector_metatable.is_zero = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2
        if not argument_1_2 then
            argument_1_2 = 0.001
        end
        value_2_2 = argument_0_2.x
        if argument_1_2 > value_2_2 then
            value_2_2 = argument_0_2.x
            value_3_2 = -argument_1_2
            if value_2_2 > value_3_2 then
                value_2_2 = argument_0_2.y
                if argument_1_2 > value_2_2 then
                    value_2_2 = argument_0_2.y
                    value_3_2 = -argument_1_2
                    if value_2_2 > value_3_2 then
                        value_2_2 = argument_0_2.z
                        if argument_1_2 > value_2_2 then
                            value_2_2 = argument_0_2.z
                            value_3_2 = -argument_1_2
                            if value_2_2 > value_3_2 then
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end
    vector_metatable.normalize = function(argument_0_2, ...)
        local value_1_2
        value_1_2 = (argument_0_2.length)(argument_0_2)
        if value_1_2 <= 0 then
            return 0
        end
        argument_0_2.x = (argument_0_2.x) / value_1_2
        argument_0_2.y = (argument_0_2.y) / value_1_2
        argument_0_2.z = (argument_0_2.z) / value_1_2
        return value_1_2
    end
    vector_metatable.normalize_no_len = function(argument_0_2, ...)
        local value_1_2
        value_1_2 = (argument_0_2.length)(argument_0_2)
        if value_1_2 <= 0 then
            return
        end
        argument_0_2.x = (argument_0_2.x) / value_1_2
        argument_0_2.y = (argument_0_2.y) / value_1_2
        argument_0_2.z = (argument_0_2.z) / value_1_2
    end
    vector_metatable.normalized = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2, value_4_2, value_5_2
        value_1_2 = (argument_0_2.length)(argument_0_2)
        if value_1_2 <= 0 then
            return Vector3()
        end
        value_2_2 = Vector3
        value_3_2 = (argument_0_2.x) / value_1_2
        value_4_2 = (argument_0_2.y) / value_1_2
        value_5_2 = (argument_0_2.z) / value_1_2
        return value_2_2(value_3_2, value_4_2, value_5_2)
    end
    clamp = function(argument_0_2, argument_1_2, argument_2_2, ...)
        if argument_0_2 < argument_1_2 then
            return argument_1_2
        end
        if argument_2_2 < argument_0_2 then
            return argument_2_2
        end
        return argument_0_2
    end
    normalize_angle = function(argument_0_2, ...)
        local value_1_2, value_3_2, value_4_2, value_5_2
        value_3_2 = to_string(argument_0_2)
        if value_3_2 == "nan" or value_3_2 == "inf" then
            return 0
        end
        if -180 <= argument_0_2 and argument_0_2 <= 180 then
            return argument_0_2
        end
        value_5_2 = argument_0_2 + 360
        value_4_2 = math_remainder(value_5_2, 360)
        value_3_2 = math_remainder(value_4_2, 360)
        value_1_2 = value_3_2
        if 180 < value_3_2 then
            value_1_2 = value_3_2 - 360
        end
        return value_1_2
    end
    vector_to_angle = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2
        value_4_2 = (argument_0_2.length)(argument_0_2)
        value_1_2 = value_4_2
        if 0 < value_4_2 then
            value_6_2 = -(argument_0_2.z)
            local returned_24_2 = __dec14_pack_results(math_arctangent(value_6_2, value_1_2))
            value_5_2, value_6_2, value_7_2 = unpack(returned_24_2, 1, returned_24_2.n)
            value_2_2 = math_degrees(unpack(returned_24_2, 1, returned_24_2.n))
            value_6_2 = argument_0_2.y
            value_7_2 = argument_0_2.x
            local returned_24_3 = __dec14_pack_results(math_arctangent(value_6_2, value_7_2))
            value_5_2, value_6_2, value_7_2 = unpack(returned_24_3, 1, returned_24_3.n)
            value_3_2 = math_degrees(unpack(returned_24_3, 1, returned_24_3.n))
        else
            value_4_2 = argument_0_2.x
            if 0 < value_4_2 then
                value_2_2 = 270
            else
                value_2_2 = 90
            end
            value_3_2 = 0
        end
        return Vector3(value_2_2, value_3_2, 0)
    end
    angle_forward = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2
        value_3_2 = argument_0_2.x
        local returned_25_4 = __dec14_pack_results(math_radians(value_3_2))
        value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2 = unpack(returned_25_4, 1, returned_25_4.n)
        value_1_2 = math_sine(unpack(returned_25_4, 1, returned_25_4.n))
        value_4_2 = argument_0_2.x
        local returned_25_5 = __dec14_pack_results(math_radians(value_4_2))
        value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2 = unpack(returned_25_5, 1, returned_25_5.n)
        value_2_2 = math_cosine(unpack(returned_25_5, 1, returned_25_5.n))
        value_5_2 = argument_0_2.y
        local returned_25_6 = __dec14_pack_results(math_radians(value_5_2))
        value_4_2, value_5_2, value_6_2, value_7_2, value_8_2 = unpack(returned_25_6, 1, returned_25_6.n)
        value_3_2 = math_sine(unpack(returned_25_6, 1, returned_25_6.n))
        value_6_2 = argument_0_2.y
        local returned_25_7 = __dec14_pack_results(math_radians(value_6_2))
        value_5_2, value_6_2, value_7_2, value_8_2 = unpack(returned_25_7, 1, returned_25_7.n)
        value_4_2 = math_cosine(unpack(returned_25_7, 1, returned_25_7.n))
        value_5_2 = Vector3
        value_6_2 = value_2_2 * value_4_2
        value_7_2 = value_2_2 * value_3_2
        value_8_2 = -value_1_2
        return value_5_2(value_6_2, value_7_2, value_8_2)
    end
    angle_right = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2
        value_3_2 = argument_0_2.x
        local returned_26_8 = __dec14_pack_results(math_radians(value_3_2))
        value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_26_8, 1, returned_26_8.n)
        value_1_2 = math_sine(unpack(returned_26_8, 1, returned_26_8.n))
        value_4_2 = argument_0_2.x
        local returned_26_9 = __dec14_pack_results(math_radians(value_4_2))
        value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_26_9, 1, returned_26_9.n)
        value_2_2 = math_cosine(unpack(returned_26_9, 1, returned_26_9.n))
        value_5_2 = argument_0_2.y
        local returned_26_10 = __dec14_pack_results(math_radians(value_5_2))
        value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_26_10, 1, returned_26_10.n)
        value_3_2 = math_sine(unpack(returned_26_10, 1, returned_26_10.n))
        value_6_2 = argument_0_2.y
        local returned_26_11 = __dec14_pack_results(math_radians(value_6_2))
        value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_26_11, 1, returned_26_11.n)
        value_4_2 = math_cosine(unpack(returned_26_11, 1, returned_26_11.n))
        value_7_2 = argument_0_2.z
        local returned_26_12 = __dec14_pack_results(math_radians(value_7_2))
        value_6_2, value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_26_12, 1, returned_26_12.n)
        value_5_2 = math_sine(unpack(returned_26_12, 1, returned_26_12.n))
        value_8_2 = argument_0_2.z
        local returned_26_13 = __dec14_pack_results(math_radians(value_8_2))
        value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_26_13, 1, returned_26_13.n)
        value_6_2 = math_cosine(unpack(returned_26_13, 1, returned_26_13.n))
        value_7_2 = Vector3
        value_8_2 = ((-1 * value_5_2) * value_1_2) * value_4_2
        value_9_2 = -1 * value_6_2
        value_10_2 = -value_3_2
        value_9_2 = value_9_2 * value_10_2
        value_8_2 = value_8_2 + value_9_2
        value_9_2 = ((-1 * value_5_2) * value_1_2) * value_3_2
        value_10_2 = (-1 * value_6_2) * value_4_2
        value_9_2 = value_9_2 + value_10_2
        value_10_2 = (-1 * value_5_2) * value_2_2
        return value_7_2(value_8_2, value_9_2, value_10_2)
    end
    angle_up = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2
        value_3_2 = argument_0_2.x
        local returned_27_14 = __dec14_pack_results(math_radians(value_3_2))
        value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_27_14, 1, returned_27_14.n)
        value_1_2 = math_sine(unpack(returned_27_14, 1, returned_27_14.n))
        value_4_2 = argument_0_2.x
        local returned_27_15 = __dec14_pack_results(math_radians(value_4_2))
        value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_27_15, 1, returned_27_15.n)
        value_2_2 = math_cosine(unpack(returned_27_15, 1, returned_27_15.n))
        value_5_2 = argument_0_2.y
        local returned_27_16 = __dec14_pack_results(math_radians(value_5_2))
        value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_27_16, 1, returned_27_16.n)
        value_3_2 = math_sine(unpack(returned_27_16, 1, returned_27_16.n))
        value_6_2 = argument_0_2.y
        local returned_27_17 = __dec14_pack_results(math_radians(value_6_2))
        value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_27_17, 1, returned_27_17.n)
        value_4_2 = math_cosine(unpack(returned_27_17, 1, returned_27_17.n))
        value_7_2 = argument_0_2.z
        local returned_27_18 = __dec14_pack_results(math_radians(value_7_2))
        value_6_2, value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_27_18, 1, returned_27_18.n)
        value_5_2 = math_sine(unpack(returned_27_18, 1, returned_27_18.n))
        value_8_2 = argument_0_2.z
        local returned_27_19 = __dec14_pack_results(math_radians(value_8_2))
        value_7_2, value_8_2, value_9_2, value_10_2 = unpack(returned_27_19, 1, returned_27_19.n)
        value_6_2 = math_cosine(unpack(returned_27_19, 1, returned_27_19.n))
        value_7_2 = Vector3
        value_8_2 = (value_6_2 * value_1_2) * value_4_2
        value_9_2 = -value_5_2
        value_10_2 = -value_3_2
        value_9_2 = value_9_2 * value_10_2
        value_8_2 = value_8_2 + value_9_2
        value_9_2 = (value_6_2 * value_1_2) * value_3_2
        value_10_2 = (-value_5_2) * value_4_2
        value_9_2 = value_9_2 + value_10_2
        value_10_2 = value_6_2 * value_2_2
        return value_7_2(value_8_2, value_9_2, value_10_2)
    end
    get_FOV = function(argument_0_2, argument_1_2, argument_2_2, ...)
        local value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2
        value_4_2 = angle_forward(argument_0_2)
        value_7_2 = argument_2_2 - argument_1_2
        value_8_2 = value_7_2
        value_5_2 = (value_7_2.normalized)(value_8_2)
        value_8_2 = (value_4_2.dot)(value_4_2, value_5_2)
        value_9_2 = (value_5_2.length)(value_5_2)
        value_8_2 = value_8_2 / value_9_2
        value_6_2 = math_arccosine(value_8_2)
        local returned_28_20 = __dec14_pack_results(math_degrees(value_6_2))
        value_9_2, value_10_2 = unpack(returned_28_20, 1, returned_28_20.n)
        return math_max(0, unpack(returned_28_20, 1, returned_28_20.n))
    end
    base64_module = {
    }
    extract_bits = _G.bit32
    if extract_bits then
        extract_bits = (_G.bit32).extract
    end
    if not extract_bits then
        base64_encoder = _G.bit
        if base64_encoder then
            local captured_bit_lshift, captured_bit_rshift, captured_bit_band
            captured_bit_lshift = (_G.bit).lshift
            captured_bit_rshift = (_G.bit).rshift
            captured_bit_band = (_G.bit).band
            extract_bits = function(argument_0_2, argument_1_2, argument_2_2, ...)
                local value_4_2, value_5_2
                value_4_2 = captured_bit_rshift(argument_0_2, argument_1_2)
                value_5_2 = (captured_bit_lshift(1, argument_2_2)) - 1
                return captured_bit_band(value_4_2, value_5_2)
            end
        else
            base64_encoder = _G._VERSION
            if base64_encoder == "Lua 5.1" then
                extract_bits = function(argument_0_2, argument_1_2, argument_2_2, ...)
                    local value_3_2, value_4_2, value_6_2, value_8_2, value_9_2, value_10_2
                    value_3_2 = 0
                    value_4_2 = 2 ^ argument_1_2
                    value_6_2 = argument_2_2 - 1
                    for value_8_2 = 0, value_6_2, 1 do
                        value_9_2 = value_4_2 + value_4_2
                        value_10_2 = argument_0_2 % value_9_2
                        if value_4_2 <= value_10_2 then
                            value_10_2 = 2 ^ value_8_2
                            value_3_2 = value_3_2 + value_10_2
                        end
                        value_4_2 = value_9_2
                    end
                    return value_3_2
                end
            else
                extract_bits = (load(("return function( v, from, width ) return ( v >> from ) & ((1 << width) - 1) end")))()
            end
        end
    end
    base64_module.makeencoder = function(argument_0_2, argument_1_2, argument_2_2, ...)
        local value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_17_2, value_18_2, value_19_2
        value_3_2 = {
        }
        value_4_2 = pairs
        value_5_2 = {
        }
        value_5_2[0] = "A"
        value_5_2[1] = ("B")
        value_5_2[2] = ("C")
        value_5_2[3] = ("D")
        value_5_2[4] = ("E")
        value_5_2[5] = ("F")
        value_5_2[6] = ("G")
        value_5_2[7] = ("H")
        value_5_2[8] = ("I")
        value_5_2[9] = ("J")
        value_5_2[10] = ("K")
        value_5_2[11] = ("L")
        value_5_2[12] = ("M")
        value_5_2[13] = ("N")
        value_5_2[14] = ("O")
        value_5_2[15] = ("P")
        value_5_2[16] = ("Q")
        value_5_2[17] = ("R")
        value_5_2[18] = ("S")
        value_5_2[19] = ("T")
        value_5_2[20] = ("U")
        value_5_2[21] = ("V")
        value_5_2[22] = ("W")
        value_5_2[23] = ("X")
        value_5_2[24] = ("Y")
        value_5_2[25] = ("Z")
        value_5_2[26] = ("a")
        value_5_2[27] = ("b")
        value_5_2[28] = ("c")
        value_5_2[29] = ("d")
        value_5_2[30] = ("e")
        value_5_2[31] = ("f")
        value_5_2[32] = ("g")
        value_5_2[33] = ("h")
        value_5_2[34] = ("i")
        value_5_2[35] = ("j")
        value_5_2[36] = ("k")
        value_5_2[37] = ("l")
        value_5_2[38] = ("m")
        value_5_2[39] = ("n")
        value_5_2[40] = ("o")
        value_5_2[41] = ("p")
        value_5_2[42] = ("q")
        value_5_2[43] = ("r")
        value_5_2[44] = ("s")
        value_5_2[45] = ("t")
        value_5_2[46] = ("u")
        value_5_2[47] = ("v")
        value_5_2[48] = ("w")
        value_5_2[49] = ("x")
        value_5_2[50] = ("y")
        value_7_2 = "0"
        value_8_2 = "1"
        value_9_2 = "2"
        value_10_2 = "3"
        value_17_2 = argument_0_2 or ("M")
        if not argument_0_2 then
            value_17_2 = "+"
        end
        value_18_2 = argument_1_2 or ("N")
        if not argument_1_2 then
            value_18_2 = "/"
        end
        value_19_2 = argument_2_2 or ("O")
        if not argument_2_2 then
            value_19_2 = "="
        end
        value_5_2[51] = ("z")
        value_5_2[52] = ("0")
        value_5_2[53] = ("1")
        value_5_2[54] = ("2")
        value_5_2[55] = ("3")
        value_5_2[56] = ("4")
        value_5_2[57] = ("5")
        value_5_2[58] = ("6")
        value_5_2[59] = ("7")
        value_5_2[60] = ("8")
        value_5_2[61] = ("9")
        value_5_2[62] = value_17_2
        value_5_2[63] = value_18_2
        value_5_2[64] = value_19_2
        value_4_2, value_5_2, value_6_2 = value_4_2(value_5_2)
        for value_7_2, value_8_2 in value_4_2, value_5_2, value_6_2 do
            if not value_7_2 then
                break
            end
            value_10_2 = value_8_2
            value_9_2 = (value_8_2.byte)(value_8_2)
            value_3_2[value_7_2] = value_9_2
        end
        return value_3_2
    end
    base64_module.makedecoder = function(argument_0_2, argument_1_2, argument_2_2, ...)
        local value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2
        value_3_2 = {
        }
        value_4_2 = pairs
        value_5_2 = base64_module.makeencoder
        local returned_32_21 = __dec14_pack_results(value_5_2(argument_0_2, argument_1_2, argument_2_2))
        value_5_2, value_6_2, value_7_2, value_8_2 = unpack(returned_32_21, 1, returned_32_21.n)
        value_4_2, value_5_2, value_6_2 = value_4_2(unpack(returned_32_21, 1, returned_32_21.n))
        for value_7_2, value_8_2 in value_4_2, value_5_2, value_6_2 do
            if not value_7_2 then
                break
            end
            value_3_2[value_8_2] = value_7_2
        end
        return value_3_2
    end
    base64_encoder = (base64_module.makeencoder)()
    base64_decoder = (base64_module.makedecoder)()
    string_char = string.char
    table_concat = table.concat
    base64_module.encode = function(argument_0_2, argument_1_2, argument_2_2, ...)
        local value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2
        if not argument_1_2 then
            argument_1_2 = base64_encoder
        end
        value_3_2 = {
        }
        value_4_2 = 1
        value_5_2 = #argument_0_2
        value_6_2 = value_5_2 % 3
        value_7_2 = {
        }
        value_9_2 = value_5_2 - value_6_2
        for value_11_2 = 1, value_9_2, 3 do
            value_12_2 = argument_0_2.byte
            value_15_2 = value_11_2 + 2
            value_12_2, value_13_2, value_14_2 = value_12_2(argument_0_2, value_11_2, value_15_2)
            value_15_2 = value_12_2 * 65536
            value_16_2 = value_13_2 * 256
            value_15_2 = (value_15_2 + value_16_2) + value_14_2
            if argument_2_2 then
                value_16_2 = value_7_2[value_15_2]
                if not value_16_2 then
                    value_18_2 = extract_bits(value_15_2, 18, 6)
                    value_18_2 = argument_1_2[value_18_2]
                    value_19_2 = extract_bits(value_15_2, 12, 6)
                    value_19_2 = argument_1_2[value_19_2]
                    value_20_2 = extract_bits(value_15_2, 6, 6)
                    value_20_2 = argument_1_2[value_20_2]
                    value_22_2 = value_15_2
                    value_23_2 = 0
                    value_24_2 = 6
                    value_21_2 = extract_bits(value_15_2, 0, 6)
                    value_21_2 = argument_1_2[value_21_2]
                    value_17_2 = string_char(value_18_2, value_19_2, value_20_2, value_21_2)
                    value_16_2 = value_17_2
                    value_7_2[value_15_2] = value_17_2
                end
            else
                value_18_2 = extract_bits(value_15_2, 18, 6)
                value_18_2 = argument_1_2[value_18_2]
                value_19_2 = extract_bits(value_15_2, 12, 6)
                value_19_2 = argument_1_2[value_19_2]
                value_20_2 = extract_bits(value_15_2, 6, 6)
                value_20_2 = argument_1_2[value_20_2]
                value_22_2 = value_15_2
                value_23_2 = 0
                value_24_2 = 6
                value_21_2 = extract_bits(value_15_2, 0, 6)
                value_21_2 = argument_1_2[value_21_2]
                value_17_2 = string_char(value_18_2, value_19_2, value_20_2, value_21_2)
                value_16_2 = value_17_2
            end
            value_3_2[value_4_2] = value_16_2
            value_4_2 = value_4_2 + 1
        end
        if value_6_2 == 2 then
            value_8_2 = argument_0_2.byte
            value_10_2 = value_5_2 - 1
            value_8_2, value_9_2 = value_8_2(argument_0_2, value_10_2, value_5_2)
            value_10_2 = value_8_2 * 65536
            value_11_2 = value_9_2 * 256
            value_10_2 = value_10_2 + value_11_2
            value_12_2 = extract_bits(value_10_2, 18, 6)
            value_12_2 = argument_1_2[value_12_2]
            value_13_2 = extract_bits(value_10_2, 12, 6)
            value_13_2 = argument_1_2[value_13_2]
            value_14_2 = extract_bits(value_10_2, 6, 6)
            value_14_2 = argument_1_2[value_14_2]
            value_15_2 = argument_1_2[64]
            value_11_2 = string_char(value_12_2, value_13_2, value_14_2, value_15_2)
            value_3_2[value_4_2] = value_11_2
        else
            if value_6_2 == 1 then
                value_8_2 = ((argument_0_2.byte)(argument_0_2, value_5_2)) * 65536
                value_10_2 = extract_bits(value_8_2, 18, 6)
                value_10_2 = argument_1_2[value_10_2]
                value_11_2 = extract_bits(value_8_2, 12, 6)
                value_11_2 = argument_1_2[value_11_2]
                value_12_2 = argument_1_2[64]
                value_13_2 = argument_1_2[64]
                value_9_2 = string_char(value_10_2, value_11_2, value_12_2, value_13_2)
                value_3_2[value_4_2] = value_9_2
            end
        end
        return table_concat(value_3_2)
    end
    base64_module.decode = function(argument_0_2, argument_1_2, argument_2_2, ...)
        local value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2
        if not argument_1_2 then
            argument_1_2 = base64_decoder
        end
        value_3_2 = "[^%w%+%/%=]"
        if argument_1_2 then
            value_4_2 = nil
            value_5_2 = nil
            value_6_2, value_7_2, value_8_2 = pairs(argument_1_2)
            for value_9_2, value_10_2 in value_6_2, value_7_2, value_8_2 do
                if not value_9_2 then
                    break
                end
                if value_10_2 == 62 then
                    value_4_2 = value_9_2
                else
                    if value_10_2 == 63 then
                        value_5_2 = value_9_2
                    end
                end
            end
            value_6_2 = ("[^%%w%%%s%%%s%%=]").format
            value_8_2 = string_char(value_4_2)
            local returned_34_22 = __dec14_pack_results(string_char(value_5_2))
            value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2 = unpack(returned_34_22, 1, returned_34_22.n)
            value_3_2 = value_6_2(("[^%%w%%%s%%%s%%=]"), value_8_2, unpack(returned_34_22, 1, returned_34_22.n))
        end
        value_4_2 = (argument_0_2.gsub)(argument_0_2, value_3_2, (""))
        argument_0_2 = value_4_2
        value_4_2 = argument_2_2 or value_4_2
        if argument_2_2 then
            value_4_2 = {
            }
        end
        value_5_2 = {
        }
        value_6_2 = 1
        value_7_2 = #argument_0_2
        value_8_2 = argument_0_2.sub
        value_10_2 = -2
        value_8_2 = value_8_2(argument_0_2, value_10_2)
        if value_8_2 == "==" then
            value_8_2 = 2
            if not 2 then
                value_8_2 = argument_0_2.sub
                value_10_2 = -1
                value_8_2 = value_8_2(argument_0_2, value_10_2)
                if value_8_2 == "=" then
                    value_8_2 = 1
                    if not 1 then
                        value_8_2 = 0
                    end
                else
                    value_8_2 = 0
                end
            end
        else
            value_8_2 = argument_0_2.sub
            value_10_2 = -1
            value_8_2 = value_8_2(argument_0_2, value_10_2)
            if value_8_2 == "=" then
                value_8_2 = 1
                if not 1 then
                    value_8_2 = 0
                end
            else
                value_8_2 = 0
            end
        end
        if 0 < value_8_2 then
            value_10_2 = value_7_2 - 4
            if not (value_10_2) then
                value_10_2 = value_7_2
            end
        else
            value_10_2 = value_7_2
        end
        for value_12_2 = 1, value_10_2, 4 do
            value_13_2 = argument_0_2.byte
            value_16_2 = value_12_2 + 3
            value_13_2, value_14_2, value_15_2, value_16_2 = value_13_2(argument_0_2, value_12_2, value_16_2)
            if argument_2_2 then
                value_18_2 = value_13_2 * 16777216
                value_19_2 = value_14_2 * 65536
                value_18_2 = value_18_2 + value_19_2
                value_19_2 = value_15_2 * 256
                value_18_2 = (value_18_2 + value_19_2) + value_16_2
                value_17_2 = value_4_2[value_18_2]
                if not value_17_2 then
                    value_19_2 = (argument_1_2[value_13_2]) * 262144
                    value_20_2 = (argument_1_2[value_14_2]) * 4096
                    value_19_2 = value_19_2 + value_20_2
                    value_20_2 = (argument_1_2[value_15_2]) * 64
                    value_19_2 = value_19_2 + value_20_2
                    value_20_2 = argument_1_2[value_16_2]
                    value_19_2 = value_19_2 + value_20_2
                    value_21_2 = extract_bits(value_19_2, 16, 8)
                    value_22_2 = extract_bits(value_19_2, 8, 8)
                    local returned_34_23 = __dec14_pack_results(extract_bits(value_19_2, 0, 8))
                    value_23_2, value_24_2, value_25_2, value_26_2 = unpack(returned_34_23, 1, returned_34_23.n)
                    value_20_2 = string_char(value_21_2, value_22_2, unpack(returned_34_23, 1, returned_34_23.n))
                    value_17_2 = value_20_2
                    value_4_2[value_18_2] = value_20_2
                end
            else
                value_18_2 = (argument_1_2[value_13_2]) * 262144
                value_19_2 = (argument_1_2[value_14_2]) * 4096
                value_18_2 = value_18_2 + value_19_2
                value_19_2 = (argument_1_2[value_15_2]) * 64
                value_18_2 = value_18_2 + value_19_2
                value_19_2 = argument_1_2[value_16_2]
                value_18_2 = value_18_2 + value_19_2
                value_20_2 = extract_bits(value_18_2, 16, 8)
                value_21_2 = extract_bits(value_18_2, 8, 8)
                local returned_34_24 = __dec14_pack_results(extract_bits(value_18_2, 0, 8))
                value_22_2, value_23_2, value_24_2, value_25_2, value_26_2 = unpack(returned_34_24, 1, returned_34_24.n)
                value_19_2 = string_char(value_20_2, value_21_2, unpack(returned_34_24, 1, returned_34_24.n))
                value_17_2 = value_19_2
            end
            value_5_2[value_6_2] = value_17_2
            value_6_2 = value_6_2 + 1
        end
        if value_8_2 == 1 then
            value_9_2 = argument_0_2.byte
            value_11_2 = value_7_2 - 3
            value_12_2 = value_7_2 - 1
            value_9_2, value_10_2, value_11_2 = value_9_2(argument_0_2, value_11_2, value_12_2)
            value_12_2 = (argument_1_2[value_9_2]) * 262144
            value_13_2 = (argument_1_2[value_10_2]) * 4096
            value_12_2 = value_12_2 + value_13_2
            value_13_2 = (argument_1_2[value_11_2]) * 64
            value_12_2 = value_12_2 + value_13_2
            value_14_2 = extract_bits(value_12_2, 16, 8)
            local returned_34_25 = __dec14_pack_results(extract_bits(value_12_2, 8, 8))
            value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2 = unpack(returned_34_25, 1, returned_34_25.n)
            value_13_2 = string_char(value_14_2, unpack(returned_34_25, 1, returned_34_25.n))
            value_5_2[value_6_2] = value_13_2
        else
            if value_8_2 == 2 then
                value_9_2 = argument_0_2.byte
                value_11_2 = value_7_2 - 3
                value_12_2 = value_7_2 - 2
                value_9_2, value_10_2 = value_9_2(argument_0_2, value_11_2, value_12_2)
                value_11_2 = (argument_1_2[value_9_2]) * 262144
                value_12_2 = (argument_1_2[value_10_2]) * 4096
                value_11_2 = value_11_2 + value_12_2
                local returned_34_26 = __dec14_pack_results(extract_bits(value_11_2, 16, 8))
                value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2 = unpack(returned_34_26, 1, returned_34_26.n)
                value_12_2 = string_char(unpack(returned_34_26, 1, returned_34_26.n))
                value_5_2[value_6_2] = value_12_2
            end
        end
        return table_concat(value_5_2)
    end
    bit_band = bit.band
    camera_angles = client.camera_angles
    eye_position = client.eye_position
    key_state = client.key_state
    scale_damage = client.scale_damage
    screen_size = client.screen_size
    set_event_callback = client.set_event_callback
    trace_bullet = client.trace_bullet
    trace_line = client.trace_line
    userid_to_entindex = client.userid_to_entindex
    get_all_entities = entity.get_all
    get_classname = entity.get_classname
    get_local_player = entity.get_local_player
    get_player_resource = entity.get_player_resource
    get_players = entity.get_players
    get_prop = entity.get_prop
    hitbox_position = entity.hitbox_position
    is_alive = entity.is_alive
    is_dormant = entity.is_dormant
    is_enemy = entity.is_enemy
    curtime = globals.curtime
    tickcount = globals.tickcount
    tickinterval = globals.tickinterval
    math_abs = math.abs
    math_atan = math.atan
    math_atan2 = math.atan2
    math_cos = math.cos
    math_deg = math.deg
    math_rad = math.rad
    math_sin = math.sin
    math_sqrt = math.sqrt
    draw_gradient = renderer.gradient
    draw_line = renderer.line
    draw_text = renderer.text
    draw_triangle = renderer.triangle
    table_remove = table.remove
    ui_get = ui.get
    ui_new_color_picker = ui.new_color_picker
    ui_new_hotkey = ui.new_hotkey
    ui_new_label = ui.new_label
    ui_new_multiselect = ui.new_multiselect
    ui_reference = compatible_reference
    ui_set = function(handle, value, ...)
        if native_controls and native_controls.freestand and handle == native_controls.freestand[1] and type(ui.get(handle)) == 'boolean' and type(value) == 'string' then
            return ui.set(handle, value == 'Default', ...)
        end
        return ui.set(handle, value, ...)
    end
    ui_set_callback = ui.set_callback
    ui_set_visible = ui.set_visible
    type_alias = get_value_type
    ui_new_slider = ui.new_slider
    native_controls = {
    }
    native_controls.pitch = ui_reference(("AA"), ("Anti-aimbot angles"), ("Pitch"))
    native_controls.yawbase = ui_reference(("AA"), ("Anti-aimbot angles"), ("Yaw base"))
    native_controls.fakeyawlimit = ui_reference(("AA"), ("Anti-aimbot angles"), ("Fake yaw limit"))
    native_controls.fsbodyyaw = ui_reference(("AA"), ("Anti-aimbot angles"), ("Freestanding body yaw"))
    native_controls.edgeyaw = ui_reference(("AA"), ("Anti-aimbot angles"), ("Edge yaw"))
    native_controls.safepoint = ui_reference(("RAGE"), ("Aimbot"), ("Force safe point"))
    native_controls.forcebaim = ui_reference(("RAGE"), ("Other"), ("Force body aim"))
    set_native_ui_visible = {
    }
    script_controls, anti_aim_state, player_records, contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = ui_reference(("AA"), ("Anti-aimbot angles"), ("Yaw"))
    set_native_ui_visible[1] = script_controls
    set_native_ui_visible[2] = anti_aim_state
    set_native_ui_visible[3] = player_records
    set_native_ui_visible[4] = contains_value
    set_native_ui_visible[5] = head_coordinates
    set_native_ui_visible[6] = normalize_yaw
    set_native_ui_visible[7] = yaw_between_points
    set_native_ui_visible[8] = signed_coordinate_delta
    set_native_ui_visible[9] = target_info
    set_native_ui_visible[10] = signed_line_distance
    set_native_ui_visible[11] = target_record_info
    set_native_ui_visible[12] = pose_desync_side
    set_native_ui_visible[13] = update_shot_history
    set_native_ui_visible[14] = angles_to_direction
    set_native_ui_visible[15] = classify_movement
    set_native_ui_visible[16] = vector_yaw
    set_native_ui_visible[17] = scale_factor
    set_native_ui_visible[18] = draw_circle_indicator
    set_native_ui_visible[19] = estimate_damage_at_offsets
    set_native_ui_visible[20] = select_nearest_player
    set_native_ui_visible[21] = is_valid_player
    set_native_ui_visible[22] = value_93_1
    set_native_ui_visible[23] = value_94_1
    set_native_ui_visible[24] = update_target_anti_aim
    set_native_ui_visible[25] = reset_player_state
    set_native_ui_visible[26] = handle_use_key
    set_native_ui_visible[27] = value_98_1
    set_native_ui_visible[28] = update_manual_and_freestanding
    set_native_ui_visible[29] = point_on_circle
    set_native_ui_visible[30] = draw_indicator_triangle
    set_native_ui_visible[31] = reset_clan_tag
    set_native_ui_visible[32] = apply_body_yaw
    set_native_ui_visible[33] = on_bullet_impact
    set_native_ui_visible[34] = on_player_hurt
    set_native_ui_visible[35] = on_player_spawn
    set_native_ui_visible[36] = value_107_1
    set_native_ui_visible[37] = value_108_1
    set_native_ui_visible[38] = value_109_1
    set_native_ui_visible[39] = value_110_1
    set_native_ui_visible[40] = value_111_1
    set_native_ui_visible[41] = clear_clan_tag
    set_native_ui_visible[42] = draw_indicators
    set_native_ui_visible[43] = update_ui_visibility
    set_native_ui_visible[44] = whitelisted
    set_native_ui_visible[45] = panorama_api
    set_native_ui_visible[46] = register_events_if_whitelisted
    set_native_ui_visible[47] = request_whitelist
    set_native_ui_visible[48] = fake_yaw_limit
    set_native_ui_visible[49] = screen_dimensions
    set_native_ui_visible[50] = screen_center
    set_native_ui_visible[51] = draw_branding
    set_native_ui_visible[52] = value_123_1
    set_native_ui_visible[53] = value_124_1
    set_native_ui_visible[54] = value_125_1
    set_native_ui_visible[55] = value_126_1
    set_native_ui_visible[56] = value_127_1
    set_native_ui_visible[57] = value_128_1
    set_native_ui_visible[58] = value_129_1
    set_native_ui_visible[59] = value_130_1
    set_native_ui_visible[60] = value_131_1
    set_native_ui_visible[61] = value_132_1
    set_native_ui_visible[62] = value_133_1
    set_native_ui_visible[63] = value_134_1
    set_native_ui_visible[64] = value_135_1
    native_controls.yaw = set_native_ui_visible
    set_native_ui_visible = {
    }
    script_controls, anti_aim_state, player_records, contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = ui_reference(("RAGE"), ("Other"), ("Quick peek assist"))
    set_native_ui_visible[1] = script_controls
    set_native_ui_visible[2] = anti_aim_state
    set_native_ui_visible[3] = player_records
    set_native_ui_visible[4] = contains_value
    set_native_ui_visible[5] = head_coordinates
    set_native_ui_visible[6] = normalize_yaw
    set_native_ui_visible[7] = yaw_between_points
    set_native_ui_visible[8] = signed_coordinate_delta
    set_native_ui_visible[9] = target_info
    set_native_ui_visible[10] = signed_line_distance
    set_native_ui_visible[11] = target_record_info
    set_native_ui_visible[12] = pose_desync_side
    set_native_ui_visible[13] = update_shot_history
    set_native_ui_visible[14] = angles_to_direction
    set_native_ui_visible[15] = classify_movement
    set_native_ui_visible[16] = vector_yaw
    set_native_ui_visible[17] = scale_factor
    set_native_ui_visible[18] = draw_circle_indicator
    set_native_ui_visible[19] = estimate_damage_at_offsets
    set_native_ui_visible[20] = select_nearest_player
    set_native_ui_visible[21] = is_valid_player
    set_native_ui_visible[22] = value_93_1
    set_native_ui_visible[23] = value_94_1
    set_native_ui_visible[24] = update_target_anti_aim
    set_native_ui_visible[25] = reset_player_state
    set_native_ui_visible[26] = handle_use_key
    set_native_ui_visible[27] = value_98_1
    set_native_ui_visible[28] = update_manual_and_freestanding
    set_native_ui_visible[29] = point_on_circle
    set_native_ui_visible[30] = draw_indicator_triangle
    set_native_ui_visible[31] = reset_clan_tag
    set_native_ui_visible[32] = apply_body_yaw
    set_native_ui_visible[33] = on_bullet_impact
    set_native_ui_visible[34] = on_player_hurt
    set_native_ui_visible[35] = on_player_spawn
    set_native_ui_visible[36] = value_107_1
    set_native_ui_visible[37] = value_108_1
    set_native_ui_visible[38] = value_109_1
    set_native_ui_visible[39] = value_110_1
    set_native_ui_visible[40] = value_111_1
    set_native_ui_visible[41] = clear_clan_tag
    set_native_ui_visible[42] = draw_indicators
    set_native_ui_visible[43] = update_ui_visibility
    set_native_ui_visible[44] = whitelisted
    set_native_ui_visible[45] = panorama_api
    set_native_ui_visible[46] = register_events_if_whitelisted
    set_native_ui_visible[47] = request_whitelist
    set_native_ui_visible[48] = fake_yaw_limit
    set_native_ui_visible[49] = screen_dimensions
    set_native_ui_visible[50] = screen_center
    set_native_ui_visible[51] = draw_branding
    set_native_ui_visible[52] = value_123_1
    set_native_ui_visible[53] = value_124_1
    set_native_ui_visible[54] = value_125_1
    set_native_ui_visible[55] = value_126_1
    set_native_ui_visible[56] = value_127_1
    set_native_ui_visible[57] = value_128_1
    set_native_ui_visible[58] = value_129_1
    set_native_ui_visible[59] = value_130_1
    set_native_ui_visible[60] = value_131_1
    set_native_ui_visible[61] = value_132_1
    set_native_ui_visible[62] = value_133_1
    set_native_ui_visible[63] = value_134_1
    set_native_ui_visible[64] = value_135_1
    native_controls.quickpeek = set_native_ui_visible
    set_native_ui_visible = {
    }
    script_controls, anti_aim_state, player_records, contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = ui_reference(("AA"), ("Anti-aimbot angles"), ("Yaw jitter"))
    set_native_ui_visible[1] = script_controls
    set_native_ui_visible[2] = anti_aim_state
    set_native_ui_visible[3] = player_records
    set_native_ui_visible[4] = contains_value
    set_native_ui_visible[5] = head_coordinates
    set_native_ui_visible[6] = normalize_yaw
    set_native_ui_visible[7] = yaw_between_points
    set_native_ui_visible[8] = signed_coordinate_delta
    set_native_ui_visible[9] = target_info
    set_native_ui_visible[10] = signed_line_distance
    set_native_ui_visible[11] = target_record_info
    set_native_ui_visible[12] = pose_desync_side
    set_native_ui_visible[13] = update_shot_history
    set_native_ui_visible[14] = angles_to_direction
    set_native_ui_visible[15] = classify_movement
    set_native_ui_visible[16] = vector_yaw
    set_native_ui_visible[17] = scale_factor
    set_native_ui_visible[18] = draw_circle_indicator
    set_native_ui_visible[19] = estimate_damage_at_offsets
    set_native_ui_visible[20] = select_nearest_player
    set_native_ui_visible[21] = is_valid_player
    set_native_ui_visible[22] = value_93_1
    set_native_ui_visible[23] = value_94_1
    set_native_ui_visible[24] = update_target_anti_aim
    set_native_ui_visible[25] = reset_player_state
    set_native_ui_visible[26] = handle_use_key
    set_native_ui_visible[27] = value_98_1
    set_native_ui_visible[28] = update_manual_and_freestanding
    set_native_ui_visible[29] = point_on_circle
    set_native_ui_visible[30] = draw_indicator_triangle
    set_native_ui_visible[31] = reset_clan_tag
    set_native_ui_visible[32] = apply_body_yaw
    set_native_ui_visible[33] = on_bullet_impact
    set_native_ui_visible[34] = on_player_hurt
    set_native_ui_visible[35] = on_player_spawn
    set_native_ui_visible[36] = value_107_1
    set_native_ui_visible[37] = value_108_1
    set_native_ui_visible[38] = value_109_1
    set_native_ui_visible[39] = value_110_1
    set_native_ui_visible[40] = value_111_1
    set_native_ui_visible[41] = clear_clan_tag
    set_native_ui_visible[42] = draw_indicators
    set_native_ui_visible[43] = update_ui_visibility
    set_native_ui_visible[44] = whitelisted
    set_native_ui_visible[45] = panorama_api
    set_native_ui_visible[46] = register_events_if_whitelisted
    set_native_ui_visible[47] = request_whitelist
    set_native_ui_visible[48] = fake_yaw_limit
    set_native_ui_visible[49] = screen_dimensions
    set_native_ui_visible[50] = screen_center
    set_native_ui_visible[51] = draw_branding
    set_native_ui_visible[52] = value_123_1
    set_native_ui_visible[53] = value_124_1
    set_native_ui_visible[54] = value_125_1
    set_native_ui_visible[55] = value_126_1
    set_native_ui_visible[56] = value_127_1
    set_native_ui_visible[57] = value_128_1
    set_native_ui_visible[58] = value_129_1
    set_native_ui_visible[59] = value_130_1
    set_native_ui_visible[60] = value_131_1
    set_native_ui_visible[61] = value_132_1
    set_native_ui_visible[62] = value_133_1
    set_native_ui_visible[63] = value_134_1
    set_native_ui_visible[64] = value_135_1
    native_controls.yawjitter = set_native_ui_visible
    set_native_ui_visible = {
    }
    script_controls, anti_aim_state, player_records, contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = ui_reference(("AA"), ("Anti-aimbot angles"), ("Body yaw"))
    set_native_ui_visible[1] = script_controls
    set_native_ui_visible[2] = anti_aim_state
    set_native_ui_visible[3] = player_records
    set_native_ui_visible[4] = contains_value
    set_native_ui_visible[5] = head_coordinates
    set_native_ui_visible[6] = normalize_yaw
    set_native_ui_visible[7] = yaw_between_points
    set_native_ui_visible[8] = signed_coordinate_delta
    set_native_ui_visible[9] = target_info
    set_native_ui_visible[10] = signed_line_distance
    set_native_ui_visible[11] = target_record_info
    set_native_ui_visible[12] = pose_desync_side
    set_native_ui_visible[13] = update_shot_history
    set_native_ui_visible[14] = angles_to_direction
    set_native_ui_visible[15] = classify_movement
    set_native_ui_visible[16] = vector_yaw
    set_native_ui_visible[17] = scale_factor
    set_native_ui_visible[18] = draw_circle_indicator
    set_native_ui_visible[19] = estimate_damage_at_offsets
    set_native_ui_visible[20] = select_nearest_player
    set_native_ui_visible[21] = is_valid_player
    set_native_ui_visible[22] = value_93_1
    set_native_ui_visible[23] = value_94_1
    set_native_ui_visible[24] = update_target_anti_aim
    set_native_ui_visible[25] = reset_player_state
    set_native_ui_visible[26] = handle_use_key
    set_native_ui_visible[27] = value_98_1
    set_native_ui_visible[28] = update_manual_and_freestanding
    set_native_ui_visible[29] = point_on_circle
    set_native_ui_visible[30] = draw_indicator_triangle
    set_native_ui_visible[31] = reset_clan_tag
    set_native_ui_visible[32] = apply_body_yaw
    set_native_ui_visible[33] = on_bullet_impact
    set_native_ui_visible[34] = on_player_hurt
    set_native_ui_visible[35] = on_player_spawn
    set_native_ui_visible[36] = value_107_1
    set_native_ui_visible[37] = value_108_1
    set_native_ui_visible[38] = value_109_1
    set_native_ui_visible[39] = value_110_1
    set_native_ui_visible[40] = value_111_1
    set_native_ui_visible[41] = clear_clan_tag
    set_native_ui_visible[42] = draw_indicators
    set_native_ui_visible[43] = update_ui_visibility
    set_native_ui_visible[44] = whitelisted
    set_native_ui_visible[45] = panorama_api
    set_native_ui_visible[46] = register_events_if_whitelisted
    set_native_ui_visible[47] = request_whitelist
    set_native_ui_visible[48] = fake_yaw_limit
    set_native_ui_visible[49] = screen_dimensions
    set_native_ui_visible[50] = screen_center
    set_native_ui_visible[51] = draw_branding
    set_native_ui_visible[52] = value_123_1
    set_native_ui_visible[53] = value_124_1
    set_native_ui_visible[54] = value_125_1
    set_native_ui_visible[55] = value_126_1
    set_native_ui_visible[56] = value_127_1
    set_native_ui_visible[57] = value_128_1
    set_native_ui_visible[58] = value_129_1
    set_native_ui_visible[59] = value_130_1
    set_native_ui_visible[60] = value_131_1
    set_native_ui_visible[61] = value_132_1
    set_native_ui_visible[62] = value_133_1
    set_native_ui_visible[63] = value_134_1
    set_native_ui_visible[64] = value_135_1
    native_controls.bodyyaw = set_native_ui_visible
    set_native_ui_visible = {
    }
    script_controls, anti_aim_state, player_records, contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = ui_reference(("AA"), ("Anti-aimbot angles"), ("Freestanding"))
    set_native_ui_visible[1] = script_controls
    set_native_ui_visible[2] = anti_aim_state
    set_native_ui_visible[3] = player_records
    set_native_ui_visible[4] = contains_value
    set_native_ui_visible[5] = head_coordinates
    set_native_ui_visible[6] = normalize_yaw
    set_native_ui_visible[7] = yaw_between_points
    set_native_ui_visible[8] = signed_coordinate_delta
    set_native_ui_visible[9] = target_info
    set_native_ui_visible[10] = signed_line_distance
    set_native_ui_visible[11] = target_record_info
    set_native_ui_visible[12] = pose_desync_side
    set_native_ui_visible[13] = update_shot_history
    set_native_ui_visible[14] = angles_to_direction
    set_native_ui_visible[15] = classify_movement
    set_native_ui_visible[16] = vector_yaw
    set_native_ui_visible[17] = scale_factor
    set_native_ui_visible[18] = draw_circle_indicator
    set_native_ui_visible[19] = estimate_damage_at_offsets
    set_native_ui_visible[20] = select_nearest_player
    set_native_ui_visible[21] = is_valid_player
    set_native_ui_visible[22] = value_93_1
    set_native_ui_visible[23] = value_94_1
    set_native_ui_visible[24] = update_target_anti_aim
    set_native_ui_visible[25] = reset_player_state
    set_native_ui_visible[26] = handle_use_key
    set_native_ui_visible[27] = value_98_1
    set_native_ui_visible[28] = update_manual_and_freestanding
    set_native_ui_visible[29] = point_on_circle
    set_native_ui_visible[30] = draw_indicator_triangle
    set_native_ui_visible[31] = reset_clan_tag
    set_native_ui_visible[32] = apply_body_yaw
    set_native_ui_visible[33] = on_bullet_impact
    set_native_ui_visible[34] = on_player_hurt
    set_native_ui_visible[35] = on_player_spawn
    set_native_ui_visible[36] = value_107_1
    set_native_ui_visible[37] = value_108_1
    set_native_ui_visible[38] = value_109_1
    set_native_ui_visible[39] = value_110_1
    set_native_ui_visible[40] = value_111_1
    set_native_ui_visible[41] = clear_clan_tag
    set_native_ui_visible[42] = draw_indicators
    set_native_ui_visible[43] = update_ui_visibility
    set_native_ui_visible[44] = whitelisted
    set_native_ui_visible[45] = panorama_api
    set_native_ui_visible[46] = register_events_if_whitelisted
    set_native_ui_visible[47] = request_whitelist
    set_native_ui_visible[48] = fake_yaw_limit
    set_native_ui_visible[49] = screen_dimensions
    set_native_ui_visible[50] = screen_center
    set_native_ui_visible[51] = draw_branding
    set_native_ui_visible[52] = value_123_1
    set_native_ui_visible[53] = value_124_1
    set_native_ui_visible[54] = value_125_1
    set_native_ui_visible[55] = value_126_1
    set_native_ui_visible[56] = value_127_1
    set_native_ui_visible[57] = value_128_1
    set_native_ui_visible[58] = value_129_1
    set_native_ui_visible[59] = value_130_1
    set_native_ui_visible[60] = value_131_1
    set_native_ui_visible[61] = value_132_1
    set_native_ui_visible[62] = value_133_1
    set_native_ui_visible[63] = value_134_1
    set_native_ui_visible[64] = value_135_1
    native_controls.freestand = set_native_ui_visible
    set_native_ui_visible = {
    }
    script_controls, anti_aim_state, player_records, contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = ui_reference(("AA"), ("Other"), ("On shot anti-aim"))
    set_native_ui_visible[1] = script_controls
    set_native_ui_visible[2] = anti_aim_state
    set_native_ui_visible[3] = player_records
    set_native_ui_visible[4] = contains_value
    set_native_ui_visible[5] = head_coordinates
    set_native_ui_visible[6] = normalize_yaw
    set_native_ui_visible[7] = yaw_between_points
    set_native_ui_visible[8] = signed_coordinate_delta
    set_native_ui_visible[9] = target_info
    set_native_ui_visible[10] = signed_line_distance
    set_native_ui_visible[11] = target_record_info
    set_native_ui_visible[12] = pose_desync_side
    set_native_ui_visible[13] = update_shot_history
    set_native_ui_visible[14] = angles_to_direction
    set_native_ui_visible[15] = classify_movement
    set_native_ui_visible[16] = vector_yaw
    set_native_ui_visible[17] = scale_factor
    set_native_ui_visible[18] = draw_circle_indicator
    set_native_ui_visible[19] = estimate_damage_at_offsets
    set_native_ui_visible[20] = select_nearest_player
    set_native_ui_visible[21] = is_valid_player
    set_native_ui_visible[22] = value_93_1
    set_native_ui_visible[23] = value_94_1
    set_native_ui_visible[24] = update_target_anti_aim
    set_native_ui_visible[25] = reset_player_state
    set_native_ui_visible[26] = handle_use_key
    set_native_ui_visible[27] = value_98_1
    set_native_ui_visible[28] = update_manual_and_freestanding
    set_native_ui_visible[29] = point_on_circle
    set_native_ui_visible[30] = draw_indicator_triangle
    set_native_ui_visible[31] = reset_clan_tag
    set_native_ui_visible[32] = apply_body_yaw
    set_native_ui_visible[33] = on_bullet_impact
    set_native_ui_visible[34] = on_player_hurt
    set_native_ui_visible[35] = on_player_spawn
    set_native_ui_visible[36] = value_107_1
    set_native_ui_visible[37] = value_108_1
    set_native_ui_visible[38] = value_109_1
    set_native_ui_visible[39] = value_110_1
    set_native_ui_visible[40] = value_111_1
    set_native_ui_visible[41] = clear_clan_tag
    set_native_ui_visible[42] = draw_indicators
    set_native_ui_visible[43] = update_ui_visibility
    set_native_ui_visible[44] = whitelisted
    set_native_ui_visible[45] = panorama_api
    set_native_ui_visible[46] = register_events_if_whitelisted
    set_native_ui_visible[47] = request_whitelist
    set_native_ui_visible[48] = fake_yaw_limit
    set_native_ui_visible[49] = screen_dimensions
    set_native_ui_visible[50] = screen_center
    set_native_ui_visible[51] = draw_branding
    set_native_ui_visible[52] = value_123_1
    set_native_ui_visible[53] = value_124_1
    set_native_ui_visible[54] = value_125_1
    set_native_ui_visible[55] = value_126_1
    set_native_ui_visible[56] = value_127_1
    set_native_ui_visible[57] = value_128_1
    set_native_ui_visible[58] = value_129_1
    set_native_ui_visible[59] = value_130_1
    set_native_ui_visible[60] = value_131_1
    set_native_ui_visible[61] = value_132_1
    set_native_ui_visible[62] = value_133_1
    set_native_ui_visible[63] = value_134_1
    set_native_ui_visible[64] = value_135_1
    native_controls.os = set_native_ui_visible
    set_native_ui_visible = {
    }
    script_controls, anti_aim_state, player_records, contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = ui_reference(("AA"), ("Other"), ("Slow motion"))
    set_native_ui_visible[1] = script_controls
    set_native_ui_visible[2] = anti_aim_state
    set_native_ui_visible[3] = player_records
    set_native_ui_visible[4] = contains_value
    set_native_ui_visible[5] = head_coordinates
    set_native_ui_visible[6] = normalize_yaw
    set_native_ui_visible[7] = yaw_between_points
    set_native_ui_visible[8] = signed_coordinate_delta
    set_native_ui_visible[9] = target_info
    set_native_ui_visible[10] = signed_line_distance
    set_native_ui_visible[11] = target_record_info
    set_native_ui_visible[12] = pose_desync_side
    set_native_ui_visible[13] = update_shot_history
    set_native_ui_visible[14] = angles_to_direction
    set_native_ui_visible[15] = classify_movement
    set_native_ui_visible[16] = vector_yaw
    set_native_ui_visible[17] = scale_factor
    set_native_ui_visible[18] = draw_circle_indicator
    set_native_ui_visible[19] = estimate_damage_at_offsets
    set_native_ui_visible[20] = select_nearest_player
    set_native_ui_visible[21] = is_valid_player
    set_native_ui_visible[22] = value_93_1
    set_native_ui_visible[23] = value_94_1
    set_native_ui_visible[24] = update_target_anti_aim
    set_native_ui_visible[25] = reset_player_state
    set_native_ui_visible[26] = handle_use_key
    set_native_ui_visible[27] = value_98_1
    set_native_ui_visible[28] = update_manual_and_freestanding
    set_native_ui_visible[29] = point_on_circle
    set_native_ui_visible[30] = draw_indicator_triangle
    set_native_ui_visible[31] = reset_clan_tag
    set_native_ui_visible[32] = apply_body_yaw
    set_native_ui_visible[33] = on_bullet_impact
    set_native_ui_visible[34] = on_player_hurt
    set_native_ui_visible[35] = on_player_spawn
    set_native_ui_visible[36] = value_107_1
    set_native_ui_visible[37] = value_108_1
    set_native_ui_visible[38] = value_109_1
    set_native_ui_visible[39] = value_110_1
    set_native_ui_visible[40] = value_111_1
    set_native_ui_visible[41] = clear_clan_tag
    set_native_ui_visible[42] = draw_indicators
    set_native_ui_visible[43] = update_ui_visibility
    set_native_ui_visible[44] = whitelisted
    set_native_ui_visible[45] = panorama_api
    set_native_ui_visible[46] = register_events_if_whitelisted
    set_native_ui_visible[47] = request_whitelist
    set_native_ui_visible[48] = fake_yaw_limit
    set_native_ui_visible[49] = screen_dimensions
    set_native_ui_visible[50] = screen_center
    set_native_ui_visible[51] = draw_branding
    set_native_ui_visible[52] = value_123_1
    set_native_ui_visible[53] = value_124_1
    set_native_ui_visible[54] = value_125_1
    set_native_ui_visible[55] = value_126_1
    set_native_ui_visible[56] = value_127_1
    set_native_ui_visible[57] = value_128_1
    set_native_ui_visible[58] = value_129_1
    set_native_ui_visible[59] = value_130_1
    set_native_ui_visible[60] = value_131_1
    set_native_ui_visible[61] = value_132_1
    set_native_ui_visible[62] = value_133_1
    set_native_ui_visible[63] = value_134_1
    set_native_ui_visible[64] = value_135_1
    native_controls.slow = set_native_ui_visible
    set_native_ui_visible = {
    }
    script_controls, anti_aim_state, player_records, contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = ui_reference(("RAGE"), ("Other"), ("Double tap"))
    set_native_ui_visible[1] = script_controls
    set_native_ui_visible[2] = anti_aim_state
    set_native_ui_visible[3] = player_records
    set_native_ui_visible[4] = contains_value
    set_native_ui_visible[5] = head_coordinates
    set_native_ui_visible[6] = normalize_yaw
    set_native_ui_visible[7] = yaw_between_points
    set_native_ui_visible[8] = signed_coordinate_delta
    set_native_ui_visible[9] = target_info
    set_native_ui_visible[10] = signed_line_distance
    set_native_ui_visible[11] = target_record_info
    set_native_ui_visible[12] = pose_desync_side
    set_native_ui_visible[13] = update_shot_history
    set_native_ui_visible[14] = angles_to_direction
    set_native_ui_visible[15] = classify_movement
    set_native_ui_visible[16] = vector_yaw
    set_native_ui_visible[17] = scale_factor
    set_native_ui_visible[18] = draw_circle_indicator
    set_native_ui_visible[19] = estimate_damage_at_offsets
    set_native_ui_visible[20] = select_nearest_player
    set_native_ui_visible[21] = is_valid_player
    set_native_ui_visible[22] = value_93_1
    set_native_ui_visible[23] = value_94_1
    set_native_ui_visible[24] = update_target_anti_aim
    set_native_ui_visible[25] = reset_player_state
    set_native_ui_visible[26] = handle_use_key
    set_native_ui_visible[27] = value_98_1
    set_native_ui_visible[28] = update_manual_and_freestanding
    set_native_ui_visible[29] = point_on_circle
    set_native_ui_visible[30] = draw_indicator_triangle
    set_native_ui_visible[31] = reset_clan_tag
    set_native_ui_visible[32] = apply_body_yaw
    set_native_ui_visible[33] = on_bullet_impact
    set_native_ui_visible[34] = on_player_hurt
    set_native_ui_visible[35] = on_player_spawn
    set_native_ui_visible[36] = value_107_1
    set_native_ui_visible[37] = value_108_1
    set_native_ui_visible[38] = value_109_1
    set_native_ui_visible[39] = value_110_1
    set_native_ui_visible[40] = value_111_1
    set_native_ui_visible[41] = clear_clan_tag
    set_native_ui_visible[42] = draw_indicators
    set_native_ui_visible[43] = update_ui_visibility
    set_native_ui_visible[44] = whitelisted
    set_native_ui_visible[45] = panorama_api
    set_native_ui_visible[46] = register_events_if_whitelisted
    set_native_ui_visible[47] = request_whitelist
    set_native_ui_visible[48] = fake_yaw_limit
    set_native_ui_visible[49] = screen_dimensions
    set_native_ui_visible[50] = screen_center
    set_native_ui_visible[51] = draw_branding
    set_native_ui_visible[52] = value_123_1
    set_native_ui_visible[53] = value_124_1
    set_native_ui_visible[54] = value_125_1
    set_native_ui_visible[55] = value_126_1
    set_native_ui_visible[56] = value_127_1
    set_native_ui_visible[57] = value_128_1
    set_native_ui_visible[58] = value_129_1
    set_native_ui_visible[59] = value_130_1
    set_native_ui_visible[60] = value_131_1
    set_native_ui_visible[61] = value_132_1
    set_native_ui_visible[62] = value_133_1
    set_native_ui_visible[63] = value_134_1
    set_native_ui_visible[64] = value_135_1
    native_controls.dt = set_native_ui_visible
    set_native_ui_visible = {
    }
    script_controls, anti_aim_state, player_records, contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = ui_reference(("AA"), ("Fake lag"), ("Enabled"))
    set_native_ui_visible[1] = script_controls
    set_native_ui_visible[2] = anti_aim_state
    set_native_ui_visible[3] = player_records
    set_native_ui_visible[4] = contains_value
    set_native_ui_visible[5] = head_coordinates
    set_native_ui_visible[6] = normalize_yaw
    set_native_ui_visible[7] = yaw_between_points
    set_native_ui_visible[8] = signed_coordinate_delta
    set_native_ui_visible[9] = target_info
    set_native_ui_visible[10] = signed_line_distance
    set_native_ui_visible[11] = target_record_info
    set_native_ui_visible[12] = pose_desync_side
    set_native_ui_visible[13] = update_shot_history
    set_native_ui_visible[14] = angles_to_direction
    set_native_ui_visible[15] = classify_movement
    set_native_ui_visible[16] = vector_yaw
    set_native_ui_visible[17] = scale_factor
    set_native_ui_visible[18] = draw_circle_indicator
    set_native_ui_visible[19] = estimate_damage_at_offsets
    set_native_ui_visible[20] = select_nearest_player
    set_native_ui_visible[21] = is_valid_player
    set_native_ui_visible[22] = value_93_1
    set_native_ui_visible[23] = value_94_1
    set_native_ui_visible[24] = update_target_anti_aim
    set_native_ui_visible[25] = reset_player_state
    set_native_ui_visible[26] = handle_use_key
    set_native_ui_visible[27] = value_98_1
    set_native_ui_visible[28] = update_manual_and_freestanding
    set_native_ui_visible[29] = point_on_circle
    set_native_ui_visible[30] = draw_indicator_triangle
    set_native_ui_visible[31] = reset_clan_tag
    set_native_ui_visible[32] = apply_body_yaw
    set_native_ui_visible[33] = on_bullet_impact
    set_native_ui_visible[34] = on_player_hurt
    set_native_ui_visible[35] = on_player_spawn
    set_native_ui_visible[36] = value_107_1
    set_native_ui_visible[37] = value_108_1
    set_native_ui_visible[38] = value_109_1
    set_native_ui_visible[39] = value_110_1
    set_native_ui_visible[40] = value_111_1
    set_native_ui_visible[41] = clear_clan_tag
    set_native_ui_visible[42] = draw_indicators
    set_native_ui_visible[43] = update_ui_visibility
    set_native_ui_visible[44] = whitelisted
    set_native_ui_visible[45] = panorama_api
    set_native_ui_visible[46] = register_events_if_whitelisted
    set_native_ui_visible[47] = request_whitelist
    set_native_ui_visible[48] = fake_yaw_limit
    set_native_ui_visible[49] = screen_dimensions
    set_native_ui_visible[50] = screen_center
    set_native_ui_visible[51] = draw_branding
    set_native_ui_visible[52] = value_123_1
    set_native_ui_visible[53] = value_124_1
    set_native_ui_visible[54] = value_125_1
    set_native_ui_visible[55] = value_126_1
    set_native_ui_visible[56] = value_127_1
    set_native_ui_visible[57] = value_128_1
    set_native_ui_visible[58] = value_129_1
    set_native_ui_visible[59] = value_130_1
    set_native_ui_visible[60] = value_131_1
    set_native_ui_visible[61] = value_132_1
    set_native_ui_visible[62] = value_133_1
    set_native_ui_visible[63] = value_134_1
    set_native_ui_visible[64] = value_135_1
    native_controls.fakelag = set_native_ui_visible
    set_native_ui_visible = function(argument_0_2, ...)
        local value_2_2
        if argument_0_2 == nil then
            argument_0_2 = true
        end
        value_2_2 = native_controls.pitch
        ui_set_visible(value_2_2, argument_0_2)
        value_2_2 = native_controls.yawbase
        ui_set_visible(value_2_2, argument_0_2)
        value_2_2 = (native_controls.yaw)[1]
        ui_set_visible(value_2_2, argument_0_2)
        value_2_2 = (native_controls.yaw)[2]
        ui_set_visible(value_2_2, argument_0_2)
        value_2_2 = (native_controls.yawjitter)[1]
        ui_set_visible(value_2_2, argument_0_2)
        value_2_2 = (native_controls.yawjitter)[2]
        ui_set_visible(value_2_2, argument_0_2)
        value_2_2 = (native_controls.bodyyaw)[1]
        ui_set_visible(value_2_2, argument_0_2)
        value_2_2 = (native_controls.bodyyaw)[2]
        ui_set_visible(value_2_2, argument_0_2)
        value_2_2 = native_controls.fakeyawlimit
        if value_2_2 ~= nil then ui_set_visible(value_2_2, argument_0_2) end
        value_2_2 = native_controls.fsbodyyaw
        ui_set_visible(value_2_2, argument_0_2)
        value_2_2 = native_controls.edgeyaw
        ui_set_visible(value_2_2, argument_0_2)
        value_2_2 = (native_controls.freestand)[1]
        ui_set_visible(value_2_2, argument_0_2)
        value_2_2 = (native_controls.freestand)[2]
        ui_set_visible(value_2_2, argument_0_2)
    end
    set_native_ui_visible(false)
    script_controls = {
    }
    anti_aim_state = {
    }
    anti_aim_state.Standing = "Reversed Freestanding"
    anti_aim_state.Moving = "Reversed Freestanding"
    anti_aim_state["Slow walk"] = "Reversed Freestanding"
    anti_aim_state["In air"] = "Reversed Freestanding"
    anti_aim_state["On E"] = "Freestanding"
    anti_aim_state.Crouched = "Reversed  Freestanding"
    anti_aim_state["Standing 2"] = "Reversed Freestanding"
    script_controls.b = anti_aim_state
    script_controls["Detect missed angle"] = false
    script_controls["Anti-resolver on X shot"] = "-"
    script_controls["Anti-resolver shot amount"] = 0
    script_controls.w = ui_new_label(("AA"), ("Anti-aimbot angles"), ("----------------------------------------------------"))
    script_controls.ww = ui_new_label(("AA"), ("Anti-aimbot angles"), ("+                 LIVE [Dec. 14, 2021]"))
    script_controls.www = ui_new_label(("AA"), ("Anti-aimbot angles"), ("----------------------------------------------------"))
    normalize_yaw = {
    }
    normalize_yaw[1] = ("Manual AA")
    normalize_yaw[2] = ("Custom Legit AA")
    normalize_yaw[3] = ("Jitter when not networked")
    normalize_yaw[4] = ("Freestanding")
    normalize_yaw[5] = ("Edge yaw")
    normalize_yaw[6] = ("Keybind indicator")
    normalize_yaw[7] = ("Name indicator")
    normalize_yaw[8] = ("Status Indicator")
    normalize_yaw[9] = ("Legacy arrows")
    normalize_yaw[10] = ("Legacy OG Circle")
    normalize_yaw[11] = ("Adaptive clantag")
    script_controls.s = ui_new_multiselect(("AA"), ("Anti-aimbot angles"), ("Anti-aim settings"), normalize_yaw)
    script_controls.la = ui_new_hotkey(("AA"), ("Anti-Aimbot angles"), ("Legit AA on key"))
    script_controls.ml = ui_new_hotkey(("AA"), ("Anti-aimbot angles"), ("Manual left\010Manual Prediction"))
    script_controls.mr = ui_new_hotkey(("AA"), ("Anti-aimbot angles"), ("Manual right\010Manual Prediction"))
    script_controls.mf = ui_new_hotkey(("AA"), ("Anti-aimbot angles"), ("Manual forwards\010Manual Prediction"))
    script_controls.fs = ui_new_hotkey(("AA"), ("Anti-aimbot angles"), ("Freestanding\010Manual Prediction"))
    script_controls.ey = ui_new_hotkey(("AA"), ("Anti-aimbot angles"), ("Edye yaw\010Manual Prediction"))
    normalize_yaw = {
    }
    normalize_yaw[1] = ("Double tap")
    normalize_yaw[2] = ("Onshot Anti-Aim")
    normalize_yaw[3] = ("Force body aim")
    normalize_yaw[4] = ("Force safe point")
    normalize_yaw[5] = ("Quick peek")
    normalize_yaw[6] = ("Edge yaw")
    normalize_yaw[7] = ("Freestanding")
    script_controls.k = ui_new_multiselect(("AA"), ("Anti-aimbot angles"), ("Keybinds"), normalize_yaw)
    anti_aim_state = {
    }
    player_records = ui_new_label(("AA"), ("Anti-aimbot angles"), ("Main color"))
    contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = ui_new_color_picker(("AA"), ("Anti-aimbot angles"), ("Main colorpicker"))
    anti_aim_state[1] = player_records
    anti_aim_state[2] = contains_value
    anti_aim_state[3] = head_coordinates
    anti_aim_state[4] = normalize_yaw
    anti_aim_state[5] = yaw_between_points
    anti_aim_state[6] = signed_coordinate_delta
    anti_aim_state[7] = target_info
    anti_aim_state[8] = signed_line_distance
    anti_aim_state[9] = target_record_info
    anti_aim_state[10] = pose_desync_side
    anti_aim_state[11] = update_shot_history
    anti_aim_state[12] = angles_to_direction
    anti_aim_state[13] = classify_movement
    anti_aim_state[14] = vector_yaw
    anti_aim_state[15] = scale_factor
    anti_aim_state[16] = draw_circle_indicator
    anti_aim_state[17] = estimate_damage_at_offsets
    anti_aim_state[18] = select_nearest_player
    anti_aim_state[19] = is_valid_player
    anti_aim_state[20] = value_93_1
    anti_aim_state[21] = value_94_1
    anti_aim_state[22] = update_target_anti_aim
    anti_aim_state[23] = reset_player_state
    anti_aim_state[24] = handle_use_key
    anti_aim_state[25] = value_98_1
    anti_aim_state[26] = update_manual_and_freestanding
    anti_aim_state[27] = point_on_circle
    anti_aim_state[28] = draw_indicator_triangle
    anti_aim_state[29] = reset_clan_tag
    anti_aim_state[30] = apply_body_yaw
    anti_aim_state[31] = on_bullet_impact
    anti_aim_state[32] = on_player_hurt
    anti_aim_state[33] = on_player_spawn
    anti_aim_state[34] = value_107_1
    anti_aim_state[35] = value_108_1
    anti_aim_state[36] = value_109_1
    anti_aim_state[37] = value_110_1
    anti_aim_state[38] = value_111_1
    anti_aim_state[39] = clear_clan_tag
    anti_aim_state[40] = draw_indicators
    anti_aim_state[41] = update_ui_visibility
    anti_aim_state[42] = whitelisted
    anti_aim_state[43] = panorama_api
    anti_aim_state[44] = register_events_if_whitelisted
    anti_aim_state[45] = request_whitelist
    anti_aim_state[46] = fake_yaw_limit
    anti_aim_state[47] = screen_dimensions
    anti_aim_state[48] = screen_center
    anti_aim_state[49] = draw_branding
    anti_aim_state[50] = value_123_1
    anti_aim_state[51] = value_124_1
    anti_aim_state[52] = value_125_1
    anti_aim_state[53] = value_126_1
    anti_aim_state[54] = value_127_1
    anti_aim_state[55] = value_128_1
    anti_aim_state[56] = value_129_1
    anti_aim_state[57] = value_130_1
    anti_aim_state[58] = value_131_1
    anti_aim_state[59] = value_132_1
    anti_aim_state[60] = value_133_1
    anti_aim_state[61] = value_134_1
    anti_aim_state[62] = value_135_1
    script_controls.clr = anti_aim_state
    anti_aim_state = {
    }
    player_records = ui_new_label(("AA"), ("Anti-aimbot angles"), ("Accent color"))
    contains_value, head_coordinates, normalize_yaw, yaw_between_points, signed_coordinate_delta, target_info, signed_line_distance, target_record_info, pose_desync_side, update_shot_history, angles_to_direction, classify_movement, vector_yaw, scale_factor, draw_circle_indicator, estimate_damage_at_offsets, select_nearest_player, is_valid_player, value_93_1, value_94_1, update_target_anti_aim, reset_player_state, handle_use_key, value_98_1, update_manual_and_freestanding, point_on_circle, draw_indicator_triangle, reset_clan_tag, apply_body_yaw, on_bullet_impact, on_player_hurt, on_player_spawn, value_107_1, value_108_1, value_109_1, value_110_1, value_111_1, clear_clan_tag, draw_indicators, update_ui_visibility, whitelisted, panorama_api, register_events_if_whitelisted, request_whitelist, fake_yaw_limit, screen_dimensions, screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = ui_new_color_picker(("AA"), ("Anti-aimbot angles"), ("Accent colorpicker"))
    anti_aim_state[1] = player_records
    anti_aim_state[2] = contains_value
    anti_aim_state[3] = head_coordinates
    anti_aim_state[4] = normalize_yaw
    anti_aim_state[5] = yaw_between_points
    anti_aim_state[6] = signed_coordinate_delta
    anti_aim_state[7] = target_info
    anti_aim_state[8] = signed_line_distance
    anti_aim_state[9] = target_record_info
    anti_aim_state[10] = pose_desync_side
    anti_aim_state[11] = update_shot_history
    anti_aim_state[12] = angles_to_direction
    anti_aim_state[13] = classify_movement
    anti_aim_state[14] = vector_yaw
    anti_aim_state[15] = scale_factor
    anti_aim_state[16] = draw_circle_indicator
    anti_aim_state[17] = estimate_damage_at_offsets
    anti_aim_state[18] = select_nearest_player
    anti_aim_state[19] = is_valid_player
    anti_aim_state[20] = value_93_1
    anti_aim_state[21] = value_94_1
    anti_aim_state[22] = update_target_anti_aim
    anti_aim_state[23] = reset_player_state
    anti_aim_state[24] = handle_use_key
    anti_aim_state[25] = value_98_1
    anti_aim_state[26] = update_manual_and_freestanding
    anti_aim_state[27] = point_on_circle
    anti_aim_state[28] = draw_indicator_triangle
    anti_aim_state[29] = reset_clan_tag
    anti_aim_state[30] = apply_body_yaw
    anti_aim_state[31] = on_bullet_impact
    anti_aim_state[32] = on_player_hurt
    anti_aim_state[33] = on_player_spawn
    anti_aim_state[34] = value_107_1
    anti_aim_state[35] = value_108_1
    anti_aim_state[36] = value_109_1
    anti_aim_state[37] = value_110_1
    anti_aim_state[38] = value_111_1
    anti_aim_state[39] = clear_clan_tag
    anti_aim_state[40] = draw_indicators
    anti_aim_state[41] = update_ui_visibility
    anti_aim_state[42] = whitelisted
    anti_aim_state[43] = panorama_api
    anti_aim_state[44] = register_events_if_whitelisted
    anti_aim_state[45] = request_whitelist
    anti_aim_state[46] = fake_yaw_limit
    anti_aim_state[47] = screen_dimensions
    anti_aim_state[48] = screen_center
    anti_aim_state[49] = draw_branding
    anti_aim_state[50] = value_123_1
    anti_aim_state[51] = value_124_1
    anti_aim_state[52] = value_125_1
    anti_aim_state[53] = value_126_1
    anti_aim_state[54] = value_127_1
    anti_aim_state[55] = value_128_1
    anti_aim_state[56] = value_129_1
    anti_aim_state[57] = value_130_1
    anti_aim_state[58] = value_131_1
    anti_aim_state[59] = value_132_1
    anti_aim_state[60] = value_133_1
    anti_aim_state[61] = value_134_1
    anti_aim_state[62] = value_135_1
    script_controls.clr2 = anti_aim_state
    anti_aim_state = {
    }
    anti_aim_state.aa = 1
    player_records = {
    }
    player_records[1] = ("Standing")
    player_records[2] = ("Moving")
    player_records[3] = ("Slow walk")
    player_records[4] = ("In air")
    player_records[5] = ("On E")
    player_records[6] = ("Crouched")
    player_records[7] = ("Standing 2")
    anti_aim_state.s_i = player_records
    player_records = {
    }
    player_records[1] = 0
    player_records[2] = 0
    player_records[3] = 0
    anti_aim_state.l_s = player_records
    anti_aim_state.rec = {
    }
    anti_aim_state.desync = 0
    anti_aim_state.holding_e = false
    anti_aim_state.target = 0
    player_records = {
    }
    player_records.manual = 0
    player_records.fs = false
    player_records.edge = false
    player_records.time = 0
    anti_aim_state.dir = player_records
    player_records = {
    }
    player_records.manual = 0
    player_records.fs = false
    player_records.edge = false
    player_records.time = 0
    anti_aim_state.stored_dir = player_records
    anti_aim_state.old_dsy = true
    player_records = {
    }
    player_records[1] = ("CWorld")
    player_records[2] = ("CCSPlayer")
    player_records[3] = ("CFuncBrush")
    anti_aim_state.classnames = player_records
    player_records = {
    }
    yaw_between_points = "flashbang"
    signed_coordinate_delta = "decoy"
    target_info = "smokegrenade"
    signed_line_distance = "taser"
    player_records[1] = ("knife")
    player_records[2] = ("hegrenade")
    player_records[3] = ("inferno")
    player_records[4] = ("flashbang")
    player_records[5] = ("decoy")
    player_records[6] = ("smokegrenade")
    player_records[7] = ("taser")
    anti_aim_state.nonweapons = player_records
    player_records = {
    }
    for yaw_between_points = 1, 64, 1 do
        signed_coordinate_delta = {
        }
        signed_coordinate_delta.s = {
        }
        signed_coordinate_delta.h = {
        }
        signed_coordinate_delta.m = 0
        signed_coordinate_delta.r = 0
        signed_coordinate_delta[("d")] = 0
        target_info = "l"
        signed_line_distance = 0
        signed_coordinate_delta[("l")] = 0
        player_records[yaw_between_points] = signed_coordinate_delta
    end
    contains_value = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_5_2, value_6_2
        if argument_0_2 == nil then
            return false
        end
        value_2_2 = type_alias(argument_0_2)
        if value_2_2 == "number" then
            argument_0_2 = ui_get(argument_0_2)
        end
        if type_alias(argument_0_2) ~= 'table' then return argument_0_2 == argument_1_2 end
        value_3_2 = #argument_0_2
        for value_5_2 = 0, value_3_2, 1 do
            value_6_2 = argument_0_2[value_5_2]
            if value_6_2 == argument_1_2 then
                return true
            end
        end
        return false
    end
    head_coordinates = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2, value_4_2, value_5_2, value_6_2
        value_1_2, value_2_2, value_3_2 = hitbox_position(argument_0_2, 0)
        value_4_2, value_5_2, value_6_2 = get_prop(argument_0_2, ("m_vecOrigin"))
        return value_4_2, value_5_2, value_3_2
    end
    normalize_yaw = function(argument_0_2, ...)
        while 180 < argument_0_2 do
            argument_0_2 = argument_0_2 - 360
        end
        while argument_0_2 < -180 do
            argument_0_2 = argument_0_2 + 360
        end
        return argument_0_2
    end
    yaw_between_points = function(argument_0_2, argument_1_2, argument_2_2, argument_3_2, ...)
        local value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2
        value_4_2 = argument_1_2 - argument_3_2
        value_5_2 = argument_0_2 - argument_2_2
        value_7_2 = value_4_2 / value_5_2
        value_6_2 = math_atan(value_7_2)
        value_8_2 = value_6_2 * 180
        value_9_2 = math.pi
        value_8_2 = value_8_2 / value_9_2
        value_7_2 = normalize_yaw(value_8_2)
        value_6_2 = value_7_2
        if 0 <= value_5_2 then
            value_8_2 = value_6_2 + 180
            value_7_2 = normalize_yaw(value_8_2)
        end
        return value_7_2
    end
    signed_coordinate_delta = function(argument_0_2, argument_1_2, argument_2_2, ...)
        local value_3_2, value_4_2, value_5_2, value_6_2
        if argument_2_2 == nil then
            argument_2_2 = false
        end
        if argument_2_2 then
            value_3_2 = {
            }
            value_4_2 = argument_1_2[1]
            value_5_2 = argument_1_2[2]
            value_6_2 = argument_0_2[3]
            value_3_2[1] = value_4_2
            value_3_2[2] = value_5_2
            value_3_2[3] = value_6_2
            argument_1_2 = value_3_2
        end
        value_3_2 = argument_0_2[1]
        value_4_2 = argument_1_2[1]
        value_3_2 = value_3_2 - value_4_2
        value_4_2 = argument_0_2[2]
        value_5_2 = argument_1_2[2]
        value_4_2 = value_4_2 - value_5_2
        value_3_2 = value_3_2 + value_4_2
        value_4_2 = argument_0_2[3]
        value_5_2 = argument_1_2[3]
        value_4_2 = value_4_2 - value_5_2
        value_3_2 = value_3_2 + value_4_2
        if value_3_2 < 0 then
            value_3_2 = value_3_2 * 0.75
        end
        return value_3_2
    end
    target_info = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2
        value_2_2, value_3_2, value_4_2 = head_coordinates(argument_0_2)
        local returned_41_27 = __dec14_pack_results(get_local_player())
        value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2 = unpack(returned_41_27, 1, returned_41_27.n)
        value_5_2, value_6_2, value_7_2 = head_coordinates(unpack(returned_41_27, 1, returned_41_27.n))
        value_8_2 = {
        }
        value_8_2[1] = value_5_2
        value_8_2[2] = value_6_2
        value_8_2[3] = value_7_2
        value_9_2 = {
        }
        value_9_2[1] = value_2_2
        value_9_2[2] = value_3_2
        value_9_2[3] = value_4_2
        value_10_2 = {
        }
        value_11_2 = argument_1_2.x
        value_12_2 = argument_1_2.y
        value_13_2 = argument_1_2.z
        value_10_2[1] = value_11_2
        value_10_2[2] = value_12_2
        value_10_2[3] = value_13_2
        value_11_2 = {
        }
        value_12_2 = value_10_2[1]
        value_13_2 = value_9_2[1]
        value_12_2 = value_12_2 - value_13_2
        value_13_2 = value_10_2[2]
        value_14_2 = value_9_2[2]
        value_13_2 = value_13_2 - value_14_2
        value_14_2 = value_10_2[3]
        value_15_2 = value_9_2[3]
        value_14_2 = value_14_2 - value_15_2
        value_11_2[1] = value_12_2
        value_11_2[2] = value_13_2
        value_11_2[3] = value_14_2
        value_13_2 = (value_11_2[1]) ^ 2
        value_14_2 = (value_11_2[2]) ^ 2
        value_13_2 = value_13_2 + value_14_2
        value_14_2 = (value_11_2[3]) ^ 2
        value_13_2 = value_13_2 + value_14_2
        value_12_2 = math_sqrt(value_13_2)
        value_13_2 = {
        }
        value_14_2 = (value_11_2[1]) / value_12_2
        value_15_2 = (value_11_2[2]) / value_12_2
        value_16_2 = (value_11_2[3]) / value_12_2
        value_13_2[1] = value_14_2
        value_13_2[2] = value_15_2
        value_13_2[3] = value_16_2
        value_14_2 = {
        }
        value_15_2 = value_8_2[1]
        value_16_2 = value_9_2[1]
        value_15_2 = value_15_2 - value_16_2
        value_16_2 = value_8_2[2]
        value_17_2 = value_9_2[2]
        value_16_2 = value_16_2 - value_17_2
        value_17_2 = value_8_2[3]
        value_18_2 = value_9_2[3]
        value_17_2 = value_17_2 - value_18_2
        value_14_2[1] = value_15_2
        value_14_2[2] = value_16_2
        value_14_2[3] = value_17_2
        value_15_2 = value_13_2[1]
        value_16_2 = value_14_2[1]
        value_15_2 = value_15_2 * value_16_2
        value_16_2 = value_13_2[2]
        value_17_2 = value_14_2[2]
        value_16_2 = value_16_2 * value_17_2
        value_15_2 = value_15_2 + value_16_2
        value_16_2 = value_13_2[3]
        value_17_2 = value_14_2[3]
        value_16_2 = value_16_2 * value_17_2
        value_15_2 = value_15_2 + value_16_2
        value_17_2 = {
        }
        value_18_2 = value_9_2[1]
        value_19_2 = value_13_2[1]
        value_19_2 = value_15_2 * value_19_2
        value_18_2 = value_18_2 + value_19_2
        value_19_2 = value_9_2[2]
        value_20_2 = value_13_2[2]
        value_20_2 = value_15_2 * value_20_2
        value_19_2 = value_19_2 + value_20_2
        value_20_2 = value_9_2[3]
        value_21_2 = value_13_2[3]
        value_21_2 = value_15_2 * value_21_2
        value_20_2 = value_20_2 + value_21_2
        value_17_2[1] = value_18_2
        value_17_2[2] = value_19_2
        value_17_2[3] = value_20_2
        anti_aim_state.ls = value_17_2
        value_17_2 = anti_aim_state.ls
        return signed_coordinate_delta(value_17_2, value_8_2, true)
    end
    signed_line_distance = function(argument_0_2, argument_1_2, argument_2_2, ...)
        local value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2
        value_3_2, value_4_2, value_5_2 = head_coordinates(argument_0_2)
        value_6_2, value_7_2, value_8_2 = head_coordinates(argument_1_2)
        value_9_2 = ((argument_2_2.y) - value_4_2) * value_6_2
        value_10_2 = ((argument_2_2.x) - value_3_2) * value_7_2
        value_9_2 = value_9_2 - value_10_2
        value_10_2 = (argument_2_2.x) * value_4_2
        value_9_2 = value_9_2 + value_10_2
        value_10_2 = (argument_2_2.y) * value_3_2
        value_9_2 = value_9_2 - value_10_2
        value_11_2 = ((argument_2_2.y) - value_4_2) ^ 2
        value_12_2 = ((argument_2_2.x) - value_3_2) ^ 2
        value_11_2 = value_11_2 + value_12_2
        value_10_2 = math_sqrt(value_11_2)
        value_9_2 = value_9_2 / value_10_2
        return value_9_2
    end
    target_record_info = function(argument_0_2, argument_1_2, argument_2_2, argument_3_2, argument_4_2, ...)
        local value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2
        value_5_2 = {
        }
        value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2 = head_coordinates(argument_3_2)
        value_5_2[1] = value_6_2
        value_5_2[2] = value_7_2
        value_5_2[3] = value_8_2
        value_5_2[4] = value_9_2
        value_5_2[5] = value_10_2
        value_5_2[6] = value_11_2
        value_5_2[7] = value_12_2
        value_5_2[8] = value_13_2
        value_6_2 = {
        }
        value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2 = get_prop(argument_3_2, ("m_vecOrigin"))
        value_6_2[1] = value_7_2
        value_6_2[2] = value_8_2
        value_6_2[3] = value_9_2
        value_6_2[4] = value_10_2
        value_6_2[5] = value_11_2
        value_6_2[6] = value_12_2
        value_6_2[7] = value_13_2
        value_7_2 = argument_1_2[3]
        value_8_2 = (value_5_2[3]) + 10
        if not (value_7_2 > value_8_2) then
            value_7_2 = argument_1_2[3]
            value_8_2 = value_6_2[3]
            if not (value_7_2 < value_8_2) then
                local returned_43_28 = __dec14_pack_results(signed_line_distance(argument_2_2, argument_3_2, argument_4_2))
                value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2 = unpack(returned_43_28, 1, returned_43_28.n)
                value_7_2 = math_abs(unpack(returned_43_28, 1, returned_43_28.n))
                if 300 < value_7_2 then
                    return false
                else
                    value_7_2 = math_abs(argument_0_2)
                    if value_7_2 < 30 then
                        return true
                    else
                        value_8_2 = get_player_resource()
                        value_7_2 = get_prop(value_8_2, ("m_iPing"), argument_2_2)
                        value_8_2 = tickinterval()
                        value_8_2 = value_7_2 * value_8_2
                        value_8_2 = 14 - value_8_2
                        value_9_2 = #(anti_aim_state.rec)
                        if value_8_2 <= value_9_2 then
                            value_9_2 = (anti_aim_state.rec)[value_8_2]
                            if value_9_2 == nil then
                                return false
                            else
                                value_10_2 = signed_coordinate_delta(value_9_2, value_5_2, true)
                                if argument_0_2 < 0 and argument_0_2 > value_10_2 or argument_0_2 < value_10_2 then
                                    value_11_2 = math_abs(argument_0_2)
                                    value_12_2 = math_abs(value_10_2)
                                    if value_11_2 < value_12_2 then
                                        value_11_2 = true
                                    else
                                        value_11_2 = math_abs(argument_0_2)
                                        value_12_2 = math_abs(value_10_2)
                                        if not (value_11_2 > value_12_2) then
                                            value_11_2 = false
                                        else
                                            value_11_2 = true
                                        end
                                    end
                                else
                                    value_11_2 = math_abs(argument_0_2)
                                    value_12_2 = math_abs(value_10_2)
                                    if not (value_11_2 > value_12_2) then
                                        value_11_2 = false
                                    else
                                        value_11_2 = true
                                    end
                                end
                                return value_11_2
                            end
                        else
                            return false
                        end
                    end
                end
            else
                do
                    return false
                end
            end
        else
            do
                return false
            end
        end
    end
    pose_desync_side = function(argument_0_2, ...)
        local value_1_2, value_2_2
        value_1_2 = anti_aim_state.desync
        if value_1_2 == 0 then
            return 0
        else
            value_1_2 = ((get_prop(argument_0_2, ("m_flPoseParameter"), 11)) * 120) - 60
            if value_1_2 < 0 then
                value_2_2 = anti_aim_state.desync
                if not (value_2_2) then
                    value_2_2 = -(anti_aim_state.desync)
                end
            else
                value_2_2 = -(anti_aim_state.desync)
            end
            return value_2_2
        end
    end
    update_shot_history = function(argument_0_2, ...)
        local value_4_2, value_5_2, value_6_2, value_7_2, value_8_2
        for value_4_2 = 1, 64, 1 do
            value_5_2 = (player_records[value_4_2]).r
            value_6_2 = #((player_records[value_4_2]).s)
            if value_5_2 < value_6_2 then
                value_5_2 = #((player_records[value_4_2]).h)
                if 0 < value_5_2 then
                    value_5_2 = (player_records[value_4_2]).s
                    value_6_2 = #((player_records[value_4_2]).s)
                    value_5_2 = (value_5_2[value_6_2]).t
                    value_6_2 = (player_records[value_4_2]).h
                    value_7_2 = #((player_records[value_4_2]).h)
                    value_6_2 = (value_6_2[value_7_2]).t
                    if value_5_2 == value_6_2 then
                        value_5_2 = true
                    else
                        value_5_2 = false
                    end
                else
                    value_5_2 = false
                end
                if value_5_2 then
                    value_6_2 = (player_records[value_4_2]).h
                    value_7_2 = #((player_records[value_4_2]).h)
                    value_6_2 = (value_6_2[value_7_2]).v
                    if not (value_6_2 ~= argument_0_2) then
                        value_6_2 = player_records[value_4_2]
                        if value_5_2 then
                            value_7_2 = (player_records[value_4_2]).h
                            value_8_2 = #((player_records[value_4_2]).h)
                            value_7_2 = (value_7_2[value_8_2]).h
                            if value_7_2 == 1 then
                                value_7_2 = pose_desync_side(argument_0_2)
                                if not (value_7_2) then
                                    value_7_2 = 0
                                end
                            else
                                value_7_2 = 0
                            end
                        else
                            value_7_2 = 0
                        end
                        value_6_2.l = value_7_2
                        if not value_5_2 then
                            value_6_2 = (player_records[value_4_2]).m
                            value_7_2 = script_controls["Anti-resolver shot amount"]
                            if value_6_2 < value_7_2 then
                                value_6_2 = player_records[value_4_2]
                                value_6_2.m = ((player_records[value_4_2]).m) + 1
                            end
                        else
                            value_6_2 = player_records[value_4_2]
                            value_6_2.m = 0
                        end
                        if value_5_2 then
                            value_6_2 = (player_records[value_4_2]).s
                            value_7_2 = #((player_records[value_4_2]).s)
                            value_6_2 = value_6_2[value_7_2]
                            value_6_2.d = pose_desync_side(argument_0_2)
                        end
                        value_6_2 = player_records[value_4_2]
                        value_7_2 = (player_records[value_4_2]).s
                        value_8_2 = #((player_records[value_4_2]).s)
                        value_6_2.d = (value_7_2[value_8_2]).d
                        anti_aim_state.target = value_4_2
                    end
                else
                    value_6_2 = player_records[value_4_2]
                    if value_5_2 then
                        value_7_2 = (player_records[value_4_2]).h
                        value_8_2 = #((player_records[value_4_2]).h)
                        value_7_2 = (value_7_2[value_8_2]).h
                        if value_7_2 == 1 then
                            value_7_2 = pose_desync_side(argument_0_2)
                            if not (value_7_2) then
                                value_7_2 = 0
                            end
                        else
                            value_7_2 = 0
                        end
                    else
                        value_7_2 = 0
                    end
                    value_6_2.l = value_7_2
                    if not value_5_2 then
                        value_6_2 = (player_records[value_4_2]).m
                        value_7_2 = script_controls["Anti-resolver shot amount"]
                        if value_6_2 < value_7_2 then
                            value_6_2 = player_records[value_4_2]
                            value_6_2.m = ((player_records[value_4_2]).m) + 1
                        end
                    else
                        value_6_2 = player_records[value_4_2]
                        value_6_2.m = 0
                    end
                    if value_5_2 then
                        value_6_2 = (player_records[value_4_2]).s
                        value_7_2 = #((player_records[value_4_2]).s)
                        value_6_2 = value_6_2[value_7_2]
                        value_6_2.d = pose_desync_side(argument_0_2)
                    end
                    value_6_2 = player_records[value_4_2]
                    value_7_2 = (player_records[value_4_2]).s
                    value_8_2 = #((player_records[value_4_2]).s)
                    value_6_2.d = (value_7_2[value_8_2]).d
                    anti_aim_state.target = value_4_2
                end
                value_6_2 = player_records[value_4_2]
                value_7_2 = #((player_records[value_4_2]).s)
                value_6_2.r = value_7_2
            else
                value_5_2 = (player_records[value_4_2]).r
                value_6_2 = #((player_records[value_4_2]).s)
                if value_5_2 > value_6_2 then
                    value_5_2 = player_records[value_4_2]
                    value_6_2 = #((player_records[value_4_2]).s)
                    value_5_2.r = value_6_2
                end
            end
        end
    end
    angles_to_direction = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2
        local returned_46_29 = __dec14_pack_results(math_rad(argument_1_2))
        value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2 = unpack(returned_46_29, 1, returned_46_29.n)
        value_2_2 = math_sin(unpack(returned_46_29, 1, returned_46_29.n))
        local returned_46_30 = __dec14_pack_results(math_rad(argument_1_2))
        value_4_2, value_5_2, value_6_2, value_7_2, value_8_2 = unpack(returned_46_30, 1, returned_46_30.n)
        value_3_2 = math_cos(unpack(returned_46_30, 1, returned_46_30.n))
        local returned_46_31 = __dec14_pack_results(math_rad(argument_0_2))
        value_5_2, value_6_2, value_7_2, value_8_2 = unpack(returned_46_31, 1, returned_46_31.n)
        value_4_2 = math_sin(unpack(returned_46_31, 1, returned_46_31.n))
        local returned_46_32 = __dec14_pack_results(math_rad(argument_0_2))
        value_6_2, value_7_2, value_8_2 = unpack(returned_46_32, 1, returned_46_32.n)
        value_5_2 = math_cos(unpack(returned_46_32, 1, returned_46_32.n))
        value_6_2 = value_5_2 * value_3_2
        value_7_2 = value_5_2 * value_2_2
        value_8_2 = -value_4_2
        return value_6_2, value_7_2, value_8_2
    end
    classify_movement = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2
        value_2_2 = anti_aim_state.holding_e
        if value_2_2 then
            anti_aim_state.aa = 5
            return
        else
            value_3_2 = (native_controls.slow)[1]
            value_2_2 = ui_get(value_3_2)
            if value_2_2 then
                value_3_2 = (native_controls.slow)[2]
                value_2_2 = ui_get(value_3_2)
            end
            if value_2_2 then
                anti_aim_state.aa = 3
                return
            else
                value_4_2 = get_prop(argument_0_2, ("m_fFlags"))
                value_3_2 = bit_band(value_4_2, 1)
                if value_3_2 == 1 then
                    value_3_2 = argument_1_2.in_jump
                    if value_3_2 == 0 then
                        value_3_2 = true
                    else
                        value_3_2 = false
                    end
                else
                    value_3_2 = false
                end
                if not value_3_2 then
                    anti_aim_state.aa = 4
                    return
                else
                    value_4_2 = entity.get_prop
                    value_5_2 = (entity.get_local_player)()
                    value_4_2 = value_4_2(value_5_2, ("m_iTeamNum"))
                    value_5_2 = entity.get_prop
                    value_6_2 = (entity.get_local_player)()
                    value_5_2 = value_5_2(value_6_2, ("m_flDuckAmount"))
                    if not (0.7 < value_5_2) then
                        value_5_2 = false
                    else
                        value_5_2 = true
                    end
                    if value_4_2 == 3 and value_5_2 then
                        anti_aim_state.aa = 6
                        return
                    else
                        value_6_2 = entity.get_player_weapon
                        value_7_2 = entity.get_local_player
                        local returned_47_33 = __dec14_pack_results(value_7_2())
                        value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2 = unpack(returned_47_33, 1, returned_47_33.n)
                        value_6_2 = value_6_2(unpack(returned_47_33, 1, returned_47_33.n))
                        value_8_2 = get_prop(value_6_2, ("m_iItemDefinitionIndex"))
                        value_7_2 = bit_band(value_8_2, 65535)
                        value_8_2, value_9_2, value_10_2 = get_prop(argument_0_2, ("m_vecVelocity"))
                        value_12_2 = value_8_2 ^ 2
                        value_13_2 = value_9_2 ^ 2
                        value_12_2 = value_12_2 + value_13_2
                        value_11_2 = math_sqrt(value_12_2)
                        if 2 < value_11_2 then
                            anti_aim_state.aa = 2
                            return
                        else
                            value_11_2 = (entity.get_players)(true)
                            value_12_2 = nil
                            value_13_2 = client.camera_angles
                            value_13_2, value_14_2, value_15_2 = value_13_2()
                            value_16_2 = Vector3(value_13_2, value_14_2, 0)
                            value_17_2 = 180
                            value_18_2 = Vector3
                            local returned_47_34 = __dec14_pack_results(get_prop(argument_0_2, ("m_vecAbsOrigin")))
                            value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2 = unpack(returned_47_34, 1, returned_47_34.n)
                            value_18_2 = value_18_2(unpack(returned_47_34, 1, returned_47_34.n))
                            value_19_2 = value_18_2.x
                            if value_19_2 ~= nil then
                                value_20_2 = #value_11_2
                                for value_22_2 = 1, value_20_2, 1 do
                                    value_23_2 = value_11_2[value_22_2]
                                    value_25_2 = value_23_2
                                    value_24_2 = is_enemy(value_23_2)
                                    if value_24_2 then
                                        value_25_2 = value_23_2
                                        value_24_2 = is_alive(value_23_2)
                                        if value_24_2 then
                                            value_25_2 = value_23_2
                                            value_24_2 = is_dormant(value_23_2)
                                            if not value_24_2 then
                                                value_24_2 = Vector3
                                                value_25_2 = entity.get_prop
                                                local returned_47_35 = __dec14_pack_results(value_25_2(value_23_2, ("m_vecOrigin")))
                                                value_25_2, value_26_2, value_27_2, value_28_2 = unpack(returned_47_35, 1, returned_47_35.n)
                                                value_24_2 = value_24_2(unpack(returned_47_35, 1, returned_47_35.n))
                                                value_26_2 = value_16_2
                                                value_27_2 = value_18_2
                                                value_28_2 = value_24_2
                                                value_25_2 = get_FOV(value_16_2, value_18_2, value_24_2)
                                                if value_17_2 > value_25_2 then
                                                    value_17_2 = value_25_2
                                                    value_12_2 = value_23_2
                                                end
                                            end
                                        end
                                    end
                                end
                                value_19_2, value_20_2, value_21_2 = get_prop(argument_0_2, ("m_vecOrigin"))
                                value_22_2, value_23_2, value_24_2 = get_prop(value_12_2, ("m_vecOrigin"))
                                if value_24_2 == nil or value_21_2 == nil then
                                    return
                                else
                                    if value_4_2 == 2 then
                                        value_26_2 = value_8_2 ^ 2
                                        value_27_2 = value_9_2 ^ 2
                                        value_26_2 = value_26_2 + value_27_2
                                        value_25_2 = math_sqrt(value_26_2)
                                        if value_25_2 < 2 and (value_7_2 == 40 or value_7_2 == 38 or value_7_2 == 11 or value_7_2 == 9) then
                                            value_25_2 = value_21_2 - value_24_2
                                            if 0 <= value_25_2 then
                                                value_25_2 = (anti_aim_state.dir).manual
                                                if value_25_2 ~= 90 then
                                                    value_25_2 = (anti_aim_state.dir).manual
                                                    if value_25_2 ~= -90 then
                                                        anti_aim_state.aa = 7
                                                        return
                                                    else
                                                        value_20_2 = value_8_2 ^ 2
                                                        value_21_2 = value_9_2 ^ 2
                                                        value_20_2 = value_20_2 + value_21_2
                                                        value_19_2 = math_sqrt(value_20_2)
                                                        if value_19_2 < 2 then
                                                            anti_aim_state.aa = 1
                                                            return
                                                        end
                                                    end
                                                else
                                                    value_20_2 = value_8_2 ^ 2
                                                    value_21_2 = value_9_2 ^ 2
                                                    value_20_2 = value_20_2 + value_21_2
                                                    value_19_2 = math_sqrt(value_20_2)
                                                    if value_19_2 < 2 then
                                                        anti_aim_state.aa = 1
                                                        return
                                                    end
                                                end
                                            else
                                                value_20_2 = value_8_2 ^ 2
                                                value_21_2 = value_9_2 ^ 2
                                                value_20_2 = value_20_2 + value_21_2
                                                value_19_2 = math_sqrt(value_20_2)
                                                if value_19_2 < 2 then
                                                    anti_aim_state.aa = 1
                                                    return
                                                end
                                            end
                                        else
                                            value_20_2 = value_8_2 ^ 2
                                            value_21_2 = value_9_2 ^ 2
                                            value_20_2 = value_20_2 + value_21_2
                                            value_19_2 = math_sqrt(value_20_2)
                                            if value_19_2 < 2 then
                                                anti_aim_state.aa = 1
                                                return
                                            end
                                        end
                                    else
                                        value_20_2 = value_8_2 ^ 2
                                        value_21_2 = value_9_2 ^ 2
                                        value_20_2 = value_20_2 + value_21_2
                                        value_19_2 = math_sqrt(value_20_2)
                                        if value_19_2 < 2 then
                                            anti_aim_state.aa = 1
                                            return
                                        end
                                    end
                                end
                            else
                                value_20_2 = value_8_2 ^ 2
                                value_21_2 = value_9_2 ^ 2
                                value_20_2 = value_20_2 + value_21_2
                                value_19_2 = math_sqrt(value_20_2)
                                if value_19_2 < 2 then
                                    anti_aim_state.aa = 1
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    vector_yaw = function(argument_0_2, argument_1_2, ...)
        local value_3_2, value_4_2, value_5_2
        if argument_0_2 == 0 and argument_1_2 == 0 then
            return 0
        end
        local returned_48_36 = __dec14_pack_results(math_atan2(argument_1_2, argument_0_2))
        value_3_2, value_4_2, value_5_2 = unpack(returned_48_36, 1, returned_48_36.n)
        return math_deg(unpack(returned_48_36, 1, returned_48_36.n))
    end
    scale_factor = function(argument_0_2, ...)
        local value_1_2, value_2_2
        value_1_2 = 155 * argument_0_2
        value_1_2 = 255 - value_1_2
        value_2_2 = 240 * argument_0_2
        return value_1_2, value_2_2, 0
    end
    draw_circle_indicator = function(argument_0_2, argument_1_2, argument_2_2, argument_3_2, argument_4_2, argument_5_2, argument_6_2, ...)
        local value_7_2, value_15_2
        value_7_2 = renderer.circle_outline
        value_7_2(argument_0_2, argument_1_2, 0, 0, 0, 155, 10, 0, 1, 6)
        value_7_2 = renderer.circle_outline
        if 0 < argument_6_2 then
            value_15_2 = 90
            if not 90 then
                value_15_2 = -90
            end
        else
            value_15_2 = -90
        end
        value_7_2(argument_0_2, argument_1_2, argument_2_2, argument_3_2, argument_4_2, argument_5_2, 9, value_15_2, 0.5, 4)
    end
    estimate_damage_at_offsets = function(argument_0_2, argument_1_2, argument_2_2, argument_3_2, argument_4_2, ...)
        local value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2
        value_5_2 = {
        }
        value_6_2 = {
        }
        value_7_2 = {
        }
        value_8_2, value_9_2, value_10_2 = head_coordinates(argument_1_2)
        value_7_2[0] = value_10_2
        value_6_2[0] = value_9_2
        value_5_2[0] = value_8_2
        value_8_2 = (value_5_2[0]) + 40
        value_9_2 = value_6_2[0]
        value_7_2[1] = value_7_2[0]
        value_6_2[1] = value_9_2
        value_5_2[1] = value_8_2
        value_8_2 = value_5_2[0]
        value_9_2 = (value_6_2[0]) + 40
        value_7_2[2] = value_7_2[0]
        value_6_2[2] = value_9_2
        value_5_2[2] = value_8_2
        value_8_2 = (value_5_2[0]) - 40
        value_9_2 = value_6_2[0]
        value_7_2[3] = value_7_2[0]
        value_6_2[3] = value_9_2
        value_5_2[3] = value_8_2
        value_8_2 = value_5_2[0]
        value_9_2 = (value_6_2[0]) - 40
        value_7_2[4] = value_7_2[0]
        value_6_2[4] = value_9_2
        value_5_2[4] = value_8_2
        value_8_2 = value_5_2[0]
        value_9_2 = value_6_2[0]
        value_7_2[5] = (value_7_2[0]) + 40
        value_6_2[5] = value_9_2
        value_5_2[5] = value_8_2
        value_8_2 = 0
        value_9_2 = nil
        for value_13_2 = 0, 5, 1 do
            if value_9_2 == 0 or value_9_2 == nil then
                value_16_2 = value_5_2[value_13_2]
                value_17_2 = value_6_2[value_13_2]
                value_18_2 = value_7_2[value_13_2]
                value_19_2 = argument_2_2
                value_20_2 = argument_3_2
                value_21_2 = argument_4_2
                value_14_2, value_15_2 = trace_bullet(argument_1_2, value_16_2, value_17_2, value_18_2, argument_2_2, argument_3_2, argument_4_2)
                value_9_2 = value_15_2
                value_8_2 = value_14_2
            end
        end
        if value_8_2 == nil then
            value_13_2 = scale_damage(argument_1_2, 2, value_9_2)
            if not (value_13_2) then
                value_13_2 = value_9_2
            end
        else
            value_13_2 = value_9_2
        end
        return scale_damage(argument_1_2, 1, value_13_2)
    end
    select_nearest_player = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_4_2, value_6_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2
        value_2_2 = get_players(true)
        value_3_2 = #value_2_2
        if value_3_2 == 0 then
            return 0
        end
        value_3_2 = 0
        value_4_2 = 180
        value_6_2 = #value_2_2
        for value_8_2 = 1, value_6_2, 1 do
            value_10_2 = value_2_2[value_8_2]
            value_9_2, value_10_2, value_11_2 = get_prop(value_10_2, ("m_vecOrigin"))
            value_15_2 = (argument_0_2[1]) - value_9_2
            value_16_2 = (argument_0_2[2]) - value_10_2
            value_14_2 = vector_yaw(value_15_2, value_16_2)
            value_15_2 = argument_1_2[2]
            value_14_2 = (value_14_2 - value_15_2) + 180
            local returned_52_37 = __dec14_pack_results(normalize_yaw(value_14_2))
            value_13_2, value_14_2, value_15_2, value_16_2 = unpack(returned_52_37, 1, returned_52_37.n)
            value_12_2 = math_abs(unpack(returned_52_37, 1, returned_52_37.n))
            if value_4_2 > value_12_2 then
                value_4_2 = value_12_2
                value_3_2 = value_2_2[value_8_2]
            end
        end
        return value_3_2
    end
    is_valid_player = function(argument_0_2, ...)
        local value_1_2
        if argument_0_2 == 0 then
            return false
        end
        value_1_2 = is_alive(argument_0_2)
        if not value_1_2 then
            return false
        end
        value_1_2 = is_dormant(argument_0_2)
        if value_1_2 then
            return false
        end
        return true
    end
    value_93_1 = false
    value_94_1 = false
    update_target_anti_aim = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2
        value_1_2 = get_local_player()
        value_2_2 = {
        }
        value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2 = head_coordinates(value_1_2)
        value_2_2[1] = value_3_2
        value_2_2[2] = value_4_2
        value_2_2[3] = value_5_2
        value_2_2[4] = value_6_2
        value_2_2[5] = value_7_2
        value_2_2[6] = value_8_2
        value_2_2[7] = value_9_2
        value_2_2[8] = value_10_2
        value_2_2[9] = value_11_2
        value_2_2[10] = value_12_2
        value_2_2[11] = value_13_2
        value_2_2[12] = value_14_2
        value_2_2[13] = value_15_2
        value_2_2[14] = value_16_2
        value_2_2[15] = value_17_2
        value_2_2[16] = value_18_2
        value_2_2[17] = value_19_2
        value_2_2[18] = value_20_2
        value_2_2[19] = value_21_2
        value_2_2[20] = value_22_2
        value_2_2[21] = value_23_2
        value_2_2[22] = value_24_2
        value_2_2[23] = value_25_2
        value_2_2[24] = value_26_2
        value_2_2[25] = value_27_2
        value_2_2[26] = value_28_2
        value_3_2 = {
        }
        value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2 = camera_angles()
        value_3_2[1] = value_4_2
        value_3_2[2] = value_5_2
        value_3_2[3] = value_6_2
        value_3_2[4] = value_7_2
        value_3_2[5] = value_8_2
        value_3_2[6] = value_9_2
        value_3_2[7] = value_10_2
        value_3_2[8] = value_11_2
        value_3_2[9] = value_12_2
        value_3_2[10] = value_13_2
        value_3_2[11] = value_14_2
        value_3_2[12] = value_15_2
        value_3_2[13] = value_16_2
        value_3_2[14] = value_17_2
        value_3_2[15] = value_18_2
        value_3_2[16] = value_19_2
        value_3_2[17] = value_20_2
        value_3_2[18] = value_21_2
        value_3_2[19] = value_22_2
        value_3_2[20] = value_23_2
        value_3_2[21] = value_24_2
        value_3_2[22] = value_25_2
        value_3_2[23] = value_26_2
        value_3_2[24] = value_27_2
        value_3_2[25] = value_28_2
        value_6_2 = anti_aim_state.target
        value_5_2 = is_valid_player(value_6_2)
        if value_5_2 then
            value_5_2 = anti_aim_state.target
            if not (value_5_2) then
                value_5_2 = select_nearest_player(value_2_2, value_3_2)
            end
        else
            value_5_2 = select_nearest_player(value_2_2, value_3_2)
        end
        anti_aim_state.target = value_5_2
        value_4_2 = anti_aim_state.target
        if value_4_2 ~= 0 then
            value_5_2 = anti_aim_state.target
            value_4_2 = (player_records[value_5_2]).d
            if value_4_2 == 0 then
                value_5_2 = anti_aim_state.target
                value_4_2 = (player_records[value_5_2]).l
                if value_4_2 ~= 0 then
                    value_6_2 = anti_aim_state.target
                    value_5_2 = (player_records[value_6_2]).l
                    anti_aim_state.desync = value_5_2
                else
                    value_4_2 = script_controls.b
                    value_5_2 = anti_aim_state.s_i
                    value_6_2 = anti_aim_state.aa
                    value_5_2 = value_5_2[value_6_2]
                    value_4_2 = value_4_2[value_5_2]
                    if value_4_2 == "Off" then
                        anti_aim_state.desync = 0
                    else
                        value_4_2 = script_controls.b
                        value_5_2 = anti_aim_state.s_i
                        value_6_2 = anti_aim_state.aa
                        value_5_2 = value_5_2[value_6_2]
                        value_4_2 = value_4_2[value_5_2]
                        if value_4_2 == "Jitter" then
                            anti_aim_state.desync = 180
                        else
                            value_4_2 = anti_aim_state.desync
                            if value_4_2 ~= 0 then
                                value_4_2 = anti_aim_state.desync
                                if not (value_4_2 ~= 180) then
                                    anti_aim_state.desync = 95
                                end
                            else
                                anti_aim_state.desync = 95
                            end
                            value_4_2 = {
                            }
                            value_6_2 = anti_aim_state.target
                            value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2 = head_coordinates(value_6_2)
                            value_4_2[1] = value_5_2
                            value_4_2[2] = value_6_2
                            value_4_2[3] = value_7_2
                            value_4_2[4] = value_8_2
                            value_4_2[5] = value_9_2
                            value_4_2[6] = value_10_2
                            value_4_2[7] = value_11_2
                            value_4_2[8] = value_12_2
                            value_4_2[9] = value_13_2
                            value_4_2[10] = value_14_2
                            value_4_2[11] = value_15_2
                            value_4_2[12] = value_16_2
                            value_4_2[13] = value_17_2
                            value_4_2[14] = value_18_2
                            value_4_2[15] = value_19_2
                            value_4_2[16] = value_20_2
                            value_4_2[17] = value_21_2
                            value_4_2[18] = value_22_2
                            value_4_2[19] = value_23_2
                            value_4_2[20] = value_24_2
                            value_4_2[21] = value_25_2
                            value_4_2[22] = value_26_2
                            value_4_2[23] = value_27_2
                            value_4_2[24] = value_28_2
                            value_6_2 = value_2_2[1]
                            value_7_2 = value_2_2[2]
                            value_8_2 = value_4_2[1]
                            value_9_2 = value_4_2[2]
                            value_5_2 = yaw_between_points(value_6_2, value_7_2, value_8_2, value_9_2)
                            value_8_2 = value_5_2 - 90
                            value_6_2, value_7_2, value_8_2 = angles_to_direction(0, value_8_2)
                            value_9_2 = value_2_2[1]
                            value_10_2 = value_6_2 * 10
                            value_9_2 = value_9_2 + value_10_2
                            value_10_2 = value_2_2[2]
                            value_11_2 = value_7_2 * 10
                            value_10_2 = value_10_2 + value_11_2
                            value_13_2 = value_5_2 + 90
                            value_11_2, value_12_2, value_13_2 = angles_to_direction(0, value_13_2)
                            value_14_2 = value_2_2[1]
                            value_15_2 = value_11_2 * 10
                            value_14_2 = value_14_2 + value_15_2
                            value_15_2 = value_2_2[2]
                            value_16_2 = value_12_2 * 10
                            value_15_2 = value_15_2 + value_16_2
                            value_16_2 = value_2_2[1]
                            value_17_2 = value_6_2 * 80
                            value_16_2 = value_16_2 + value_17_2
                            value_17_2 = value_2_2[2]
                            value_18_2 = value_7_2 * 80
                            value_17_2 = value_17_2 + value_18_2
                            value_18_2 = value_2_2[1]
                            value_19_2 = value_11_2 * 80
                            value_18_2 = value_18_2 + value_19_2
                            value_19_2 = value_2_2[2]
                            value_20_2 = value_12_2 * 80
                            value_19_2 = value_19_2 + value_20_2
                            value_22_2 = anti_aim_state.target
                            value_25_2 = value_2_2[3]
                            value_20_2 = estimate_damage_at_offsets(value_1_2, value_22_2, value_9_2, value_10_2, value_25_2)
                            value_23_2 = anti_aim_state.target
                            value_26_2 = value_2_2[3]
                            value_21_2 = estimate_damage_at_offsets(value_1_2, value_23_2, value_14_2, value_15_2, value_26_2)
                            value_24_2 = anti_aim_state.target
                            value_27_2 = value_2_2[3]
                            value_22_2 = estimate_damage_at_offsets(value_1_2, value_24_2, value_16_2, value_17_2, value_27_2)
                            value_25_2 = anti_aim_state.target
                            value_28_2 = value_2_2[3]
                            value_23_2 = estimate_damage_at_offsets(value_1_2, value_25_2, value_18_2, value_19_2, value_28_2)
                            if value_22_2 < value_23_2 or value_20_2 < value_21_2 or value_21_2 < value_23_2 then
                                value_25_2 = anti_aim_state.aa
                                if value_25_2 == 1 then
                                    if ("left") == "left" then
                                        value_26_2 = script_controls.b
                                        value_27_2 = anti_aim_state.s_i
                                        value_28_2 = anti_aim_state.aa
                                        value_27_2 = value_27_2[value_28_2]
                                        value_26_2 = value_26_2[value_27_2]
                                        if value_26_2 == "Freestanding" then
                                            value_26_2 = -95
                                            if not (value_26_2) then
                                                value_26_2 = 95
                                            end
                                        else
                                            value_26_2 = 95
                                        end
                                        anti_aim_state.desync = value_26_2
                                    else
                                        if not (("left") ~= "right") then
                                            value_26_2 = script_controls.b
                                            value_27_2 = anti_aim_state.s_i
                                            value_28_2 = anti_aim_state.aa
                                            value_27_2 = value_27_2[value_28_2]
                                            value_26_2 = value_26_2[value_27_2]
                                            if value_26_2 == "Freestanding" then
                                                value_26_2 = 95
                                                if not 95 then
                                                    value_26_2 = -95
                                                end
                                            else
                                                value_26_2 = -95
                                            end
                                            anti_aim_state.desync = value_26_2
                                        end
                                    end
                                else
                                    value_25_2 = anti_aim_state.aa
                                    if value_25_2 == 2 then
                                        if ("left") == "left" then
                                            value_26_2 = script_controls.b
                                            value_27_2 = anti_aim_state.s_i
                                            value_28_2 = anti_aim_state.aa
                                            value_27_2 = value_27_2[value_28_2]
                                            value_26_2 = value_26_2[value_27_2]
                                            if value_26_2 == "Freestanding" then
                                                if value_93_1 then
                                                    value_26_2 = -95
                                                    if not (value_26_2) then
                                                        value_26_2 = 95
                                                    end
                                                else
                                                    value_26_2 = 95
                                                end
                                            else
                                                value_26_2 = 95
                                            end
                                            anti_aim_state.desync = value_26_2
                                        else
                                            if not (("left") ~= "right") then
                                                value_26_2 = script_controls.b
                                                value_27_2 = anti_aim_state.s_i
                                                value_28_2 = anti_aim_state.aa
                                                value_27_2 = value_27_2[value_28_2]
                                                value_26_2 = value_26_2[value_27_2]
                                                if value_26_2 == "Freestanding" then
                                                    if value_93_1 then
                                                        value_26_2 = 95
                                                        if not 95 then
                                                            value_26_2 = -95
                                                        end
                                                    else
                                                        value_26_2 = -95
                                                    end
                                                else
                                                    value_26_2 = -95
                                                end
                                                anti_aim_state.desync = value_26_2
                                            end
                                        end
                                    else
                                        value_25_2 = anti_aim_state.aa
                                        if value_25_2 == 3 then
                                            anti_aim_state.desync = 180
                                        else
                                            value_25_2 = anti_aim_state.aa
                                            if value_25_2 == 4 then
                                                if ("left") == "left" then
                                                    value_26_2 = script_controls.b
                                                    value_27_2 = anti_aim_state.s_i
                                                    value_28_2 = anti_aim_state.aa
                                                    value_27_2 = value_27_2[value_28_2]
                                                    value_26_2 = value_26_2[value_27_2]
                                                    if value_26_2 == "Freestanding" then
                                                        if value_93_1 then
                                                            value_26_2 = -95
                                                            if not (value_26_2) then
                                                                value_26_2 = 95
                                                            end
                                                        else
                                                            value_26_2 = 95
                                                        end
                                                    else
                                                        value_26_2 = 95
                                                    end
                                                    anti_aim_state.desync = value_26_2
                                                else
                                                    if not (("left") ~= "right") then
                                                        value_26_2 = script_controls.b
                                                        value_27_2 = anti_aim_state.s_i
                                                        value_28_2 = anti_aim_state.aa
                                                        value_27_2 = value_27_2[value_28_2]
                                                        value_26_2 = value_26_2[value_27_2]
                                                        if value_26_2 == "Freestanding" then
                                                            if value_93_1 then
                                                                value_26_2 = 95
                                                                if not 95 then
                                                                    value_26_2 = -95
                                                                end
                                                            else
                                                                value_26_2 = -95
                                                            end
                                                        else
                                                            value_26_2 = -95
                                                        end
                                                        anti_aim_state.desync = value_26_2
                                                    end
                                                end
                                            else
                                                value_25_2 = anti_aim_state.aa
                                                if value_25_2 == 5 then
                                                    if ("left") == "left" then
                                                        value_26_2 = script_controls.b
                                                        value_27_2 = anti_aim_state.s_i
                                                        value_28_2 = anti_aim_state.aa
                                                        value_27_2 = value_27_2[value_28_2]
                                                        value_26_2 = value_26_2[value_27_2]
                                                        if value_26_2 == "Freestanding" then
                                                            value_26_2 = -95
                                                            if not (value_26_2) then
                                                                value_26_2 = 95
                                                            end
                                                        else
                                                            value_26_2 = 95
                                                        end
                                                        anti_aim_state.desync = value_26_2
                                                    else
                                                        if not (("left") ~= "right") then
                                                            value_26_2 = script_controls.b
                                                            value_27_2 = anti_aim_state.s_i
                                                            value_28_2 = anti_aim_state.aa
                                                            value_27_2 = value_27_2[value_28_2]
                                                            value_26_2 = value_26_2[value_27_2]
                                                            if value_26_2 == "Freestanding" then
                                                                value_26_2 = 95
                                                                if not 95 then
                                                                    value_26_2 = -95
                                                                end
                                                            else
                                                                value_26_2 = -95
                                                            end
                                                            anti_aim_state.desync = value_26_2
                                                        end
                                                    end
                                                else
                                                    value_25_2 = anti_aim_state.aa
                                                    if value_25_2 == 6 then
                                                        value_26_2 = script_controls.b
                                                        value_27_2 = anti_aim_state.s_i
                                                        value_28_2 = anti_aim_state.aa
                                                        value_27_2 = value_27_2[value_28_2]
                                                        value_26_2 = value_26_2[value_27_2]
                                                        if value_26_2 == "Freestanding" then
                                                            value_26_2 = client.random_int
                                                            value_27_2 = -60
                                                            value_28_2 = -20
                                                            value_26_2 = value_26_2(value_27_2, value_28_2)
                                                            if not (value_26_2) then
                                                                value_26_2 = (client.random_int)(20, 60)
                                                            end
                                                        else
                                                            value_26_2 = (client.random_int)(20, 60)
                                                        end
                                                        anti_aim_state.desync = value_26_2
                                                    else
                                                        value_25_2 = anti_aim_state.aa
                                                        if not (value_25_2 ~= 7) then
                                                            value_26_2 = script_controls.b
                                                            value_27_2 = anti_aim_state.s_i
                                                            value_28_2 = anti_aim_state.aa
                                                            value_27_2 = value_27_2[value_28_2]
                                                            value_26_2 = value_26_2[value_27_2]
                                                            if value_26_2 == "Freestanding" then
                                                                value_26_2 = client.random_int
                                                                value_27_2 = -60
                                                                value_28_2 = -40
                                                                value_26_2 = value_26_2(value_27_2, value_28_2)
                                                                if not (value_26_2) then
                                                                    value_26_2 = (client.random_int)(40, 60)
                                                                end
                                                            else
                                                                value_26_2 = (client.random_int)(40, 60)
                                                            end
                                                            anti_aim_state.desync = value_26_2
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            else
                                if value_22_2 > value_23_2 or value_20_2 > value_21_2 or value_20_2 < value_22_2 then
                                    value_25_2 = anti_aim_state.aa
                                    if value_25_2 == 1 then
                                        if ("right") == "left" then
                                            value_26_2 = script_controls.b
                                            value_27_2 = anti_aim_state.s_i
                                            value_28_2 = anti_aim_state.aa
                                            value_27_2 = value_27_2[value_28_2]
                                            value_26_2 = value_26_2[value_27_2]
                                            if value_26_2 == "Freestanding" then
                                                value_26_2 = -95
                                                if not (value_26_2) then
                                                    value_26_2 = 95
                                                end
                                            else
                                                value_26_2 = 95
                                            end
                                            anti_aim_state.desync = value_26_2
                                        else
                                            if not (("right") ~= "right") then
                                                value_26_2 = script_controls.b
                                                value_27_2 = anti_aim_state.s_i
                                                value_28_2 = anti_aim_state.aa
                                                value_27_2 = value_27_2[value_28_2]
                                                value_26_2 = value_26_2[value_27_2]
                                                if value_26_2 == "Freestanding" then
                                                    value_26_2 = 95
                                                    if not 95 then
                                                        value_26_2 = -95
                                                    end
                                                else
                                                    value_26_2 = -95
                                                end
                                                anti_aim_state.desync = value_26_2
                                            end
                                        end
                                    else
                                        value_25_2 = anti_aim_state.aa
                                        if value_25_2 == 2 then
                                            if ("right") == "left" then
                                                value_26_2 = script_controls.b
                                                value_27_2 = anti_aim_state.s_i
                                                value_28_2 = anti_aim_state.aa
                                                value_27_2 = value_27_2[value_28_2]
                                                value_26_2 = value_26_2[value_27_2]
                                                if value_26_2 == "Freestanding" then
                                                    if value_93_1 then
                                                        value_26_2 = -95
                                                        if not (value_26_2) then
                                                            value_26_2 = 95
                                                        end
                                                    else
                                                        value_26_2 = 95
                                                    end
                                                else
                                                    value_26_2 = 95
                                                end
                                                anti_aim_state.desync = value_26_2
                                            else
                                                if not (("right") ~= "right") then
                                                    value_26_2 = script_controls.b
                                                    value_27_2 = anti_aim_state.s_i
                                                    value_28_2 = anti_aim_state.aa
                                                    value_27_2 = value_27_2[value_28_2]
                                                    value_26_2 = value_26_2[value_27_2]
                                                    if value_26_2 == "Freestanding" then
                                                        if value_93_1 then
                                                            value_26_2 = 95
                                                            if not 95 then
                                                                value_26_2 = -95
                                                            end
                                                        else
                                                            value_26_2 = -95
                                                        end
                                                    else
                                                        value_26_2 = -95
                                                    end
                                                    anti_aim_state.desync = value_26_2
                                                end
                                            end
                                        else
                                            value_25_2 = anti_aim_state.aa
                                            if value_25_2 == 3 then
                                                anti_aim_state.desync = 180
                                            else
                                                value_25_2 = anti_aim_state.aa
                                                if value_25_2 == 4 then
                                                    if ("right") == "left" then
                                                        value_26_2 = script_controls.b
                                                        value_27_2 = anti_aim_state.s_i
                                                        value_28_2 = anti_aim_state.aa
                                                        value_27_2 = value_27_2[value_28_2]
                                                        value_26_2 = value_26_2[value_27_2]
                                                        if value_26_2 == "Freestanding" then
                                                            if value_93_1 then
                                                                value_26_2 = -95
                                                                if not (value_26_2) then
                                                                    value_26_2 = 95
                                                                end
                                                            else
                                                                value_26_2 = 95
                                                            end
                                                        else
                                                            value_26_2 = 95
                                                        end
                                                        anti_aim_state.desync = value_26_2
                                                    else
                                                        if not (("right") ~= "right") then
                                                            value_26_2 = script_controls.b
                                                            value_27_2 = anti_aim_state.s_i
                                                            value_28_2 = anti_aim_state.aa
                                                            value_27_2 = value_27_2[value_28_2]
                                                            value_26_2 = value_26_2[value_27_2]
                                                            if value_26_2 == "Freestanding" then
                                                                if value_93_1 then
                                                                    value_26_2 = 95
                                                                    if not 95 then
                                                                        value_26_2 = -95
                                                                    end
                                                                else
                                                                    value_26_2 = -95
                                                                end
                                                            else
                                                                value_26_2 = -95
                                                            end
                                                            anti_aim_state.desync = value_26_2
                                                        end
                                                    end
                                                else
                                                    value_25_2 = anti_aim_state.aa
                                                    if value_25_2 == 5 then
                                                        if ("right") == "left" then
                                                            value_26_2 = script_controls.b
                                                            value_27_2 = anti_aim_state.s_i
                                                            value_28_2 = anti_aim_state.aa
                                                            value_27_2 = value_27_2[value_28_2]
                                                            value_26_2 = value_26_2[value_27_2]
                                                            if value_26_2 == "Freestanding" then
                                                                value_26_2 = -95
                                                                if not (value_26_2) then
                                                                    value_26_2 = 95
                                                                end
                                                            else
                                                                value_26_2 = 95
                                                            end
                                                            anti_aim_state.desync = value_26_2
                                                        else
                                                            if not (("right") ~= "right") then
                                                                value_26_2 = script_controls.b
                                                                value_27_2 = anti_aim_state.s_i
                                                                value_28_2 = anti_aim_state.aa
                                                                value_27_2 = value_27_2[value_28_2]
                                                                value_26_2 = value_26_2[value_27_2]
                                                                if value_26_2 == "Freestanding" then
                                                                    value_26_2 = 95
                                                                    if not 95 then
                                                                        value_26_2 = -95
                                                                    end
                                                                else
                                                                    value_26_2 = -95
                                                                end
                                                                anti_aim_state.desync = value_26_2
                                                            end
                                                        end
                                                    else
                                                        value_25_2 = anti_aim_state.aa
                                                        if value_25_2 == 6 then
                                                            value_26_2 = script_controls.b
                                                            value_27_2 = anti_aim_state.s_i
                                                            value_28_2 = anti_aim_state.aa
                                                            value_27_2 = value_27_2[value_28_2]
                                                            value_26_2 = value_26_2[value_27_2]
                                                            if value_26_2 == "Freestanding" then
                                                                value_26_2 = client.random_int
                                                                value_27_2 = -60
                                                                value_28_2 = -20
                                                                value_26_2 = value_26_2(value_27_2, value_28_2)
                                                                if not (value_26_2) then
                                                                    value_26_2 = (client.random_int)(20, 60)
                                                                end
                                                            else
                                                                value_26_2 = (client.random_int)(20, 60)
                                                            end
                                                            anti_aim_state.desync = value_26_2
                                                        else
                                                            value_25_2 = anti_aim_state.aa
                                                            if not (value_25_2 ~= 7) then
                                                                value_26_2 = script_controls.b
                                                                value_27_2 = anti_aim_state.s_i
                                                                value_28_2 = anti_aim_state.aa
                                                                value_27_2 = value_27_2[value_28_2]
                                                                value_26_2 = value_26_2[value_27_2]
                                                                if value_26_2 == "Freestanding" then
                                                                    value_26_2 = client.random_int
                                                                    value_27_2 = -60
                                                                    value_28_2 = -40
                                                                    value_26_2 = value_26_2(value_27_2, value_28_2)
                                                                    if not (value_26_2) then
                                                                        value_26_2 = (client.random_int)(40, 60)
                                                                    end
                                                                else
                                                                    value_26_2 = (client.random_int)(40, 60)
                                                                end
                                                                anti_aim_state.desync = value_26_2
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                else
                                    value_25_2 = anti_aim_state.holding_e
                                    if not value_25_2 then
                                        anti_aim_state.desync = 180
                                        return
                                    else
                                        value_25_2 = anti_aim_state.aa
                                        if value_25_2 == 1 then
                                            if ("") == "left" then
                                                value_26_2 = script_controls.b
                                                value_27_2 = anti_aim_state.s_i
                                                value_28_2 = anti_aim_state.aa
                                                value_27_2 = value_27_2[value_28_2]
                                                value_26_2 = value_26_2[value_27_2]
                                                if value_26_2 == "Freestanding" then
                                                    value_26_2 = -95
                                                    if not (value_26_2) then
                                                        value_26_2 = 95
                                                    end
                                                else
                                                    value_26_2 = 95
                                                end
                                                anti_aim_state.desync = value_26_2
                                            else
                                                if not (("") ~= "right") then
                                                    value_26_2 = script_controls.b
                                                    value_27_2 = anti_aim_state.s_i
                                                    value_28_2 = anti_aim_state.aa
                                                    value_27_2 = value_27_2[value_28_2]
                                                    value_26_2 = value_26_2[value_27_2]
                                                    if value_26_2 == "Freestanding" then
                                                        value_26_2 = 95
                                                        if not 95 then
                                                            value_26_2 = -95
                                                        end
                                                    else
                                                        value_26_2 = -95
                                                    end
                                                    anti_aim_state.desync = value_26_2
                                                end
                                            end
                                        else
                                            value_25_2 = anti_aim_state.aa
                                            if value_25_2 == 2 then
                                                if ("") == "left" then
                                                    value_26_2 = script_controls.b
                                                    value_27_2 = anti_aim_state.s_i
                                                    value_28_2 = anti_aim_state.aa
                                                    value_27_2 = value_27_2[value_28_2]
                                                    value_26_2 = value_26_2[value_27_2]
                                                    if value_26_2 == "Freestanding" then
                                                        if value_93_1 then
                                                            value_26_2 = -95
                                                            if not (value_26_2) then
                                                                value_26_2 = 95
                                                            end
                                                        else
                                                            value_26_2 = 95
                                                        end
                                                    else
                                                        value_26_2 = 95
                                                    end
                                                    anti_aim_state.desync = value_26_2
                                                else
                                                    if not (("") ~= "right") then
                                                        value_26_2 = script_controls.b
                                                        value_27_2 = anti_aim_state.s_i
                                                        value_28_2 = anti_aim_state.aa
                                                        value_27_2 = value_27_2[value_28_2]
                                                        value_26_2 = value_26_2[value_27_2]
                                                        if value_26_2 == "Freestanding" then
                                                            if value_93_1 then
                                                                value_26_2 = 95
                                                                if not 95 then
                                                                    value_26_2 = -95
                                                                end
                                                            else
                                                                value_26_2 = -95
                                                            end
                                                        else
                                                            value_26_2 = -95
                                                        end
                                                        anti_aim_state.desync = value_26_2
                                                    end
                                                end
                                            else
                                                value_25_2 = anti_aim_state.aa
                                                if value_25_2 == 3 then
                                                    anti_aim_state.desync = 180
                                                else
                                                    value_25_2 = anti_aim_state.aa
                                                    if value_25_2 == 4 then
                                                        if ("") == "left" then
                                                            value_26_2 = script_controls.b
                                                            value_27_2 = anti_aim_state.s_i
                                                            value_28_2 = anti_aim_state.aa
                                                            value_27_2 = value_27_2[value_28_2]
                                                            value_26_2 = value_26_2[value_27_2]
                                                            if value_26_2 == "Freestanding" then
                                                                if value_93_1 then
                                                                    value_26_2 = -95
                                                                    if not (value_26_2) then
                                                                        value_26_2 = 95
                                                                    end
                                                                else
                                                                    value_26_2 = 95
                                                                end
                                                            else
                                                                value_26_2 = 95
                                                            end
                                                            anti_aim_state.desync = value_26_2
                                                        else
                                                            if not (("") ~= "right") then
                                                                value_26_2 = script_controls.b
                                                                value_27_2 = anti_aim_state.s_i
                                                                value_28_2 = anti_aim_state.aa
                                                                value_27_2 = value_27_2[value_28_2]
                                                                value_26_2 = value_26_2[value_27_2]
                                                                if value_26_2 == "Freestanding" then
                                                                    if value_93_1 then
                                                                        value_26_2 = 95
                                                                        if not 95 then
                                                                            value_26_2 = -95
                                                                        end
                                                                    else
                                                                        value_26_2 = -95
                                                                    end
                                                                else
                                                                    value_26_2 = -95
                                                                end
                                                                anti_aim_state.desync = value_26_2
                                                            end
                                                        end
                                                    else
                                                        value_25_2 = anti_aim_state.aa
                                                        if value_25_2 == 5 then
                                                            if ("") == "left" then
                                                                value_26_2 = script_controls.b
                                                                value_27_2 = anti_aim_state.s_i
                                                                value_28_2 = anti_aim_state.aa
                                                                value_27_2 = value_27_2[value_28_2]
                                                                value_26_2 = value_26_2[value_27_2]
                                                                if value_26_2 == "Freestanding" then
                                                                    value_26_2 = -95
                                                                    if not (value_26_2) then
                                                                        value_26_2 = 95
                                                                    end
                                                                else
                                                                    value_26_2 = 95
                                                                end
                                                                anti_aim_state.desync = value_26_2
                                                            else
                                                                if not (("") ~= "right") then
                                                                    value_26_2 = script_controls.b
                                                                    value_27_2 = anti_aim_state.s_i
                                                                    value_28_2 = anti_aim_state.aa
                                                                    value_27_2 = value_27_2[value_28_2]
                                                                    value_26_2 = value_26_2[value_27_2]
                                                                    if value_26_2 == "Freestanding" then
                                                                        value_26_2 = 95
                                                                        if not 95 then
                                                                            value_26_2 = -95
                                                                        end
                                                                    else
                                                                        value_26_2 = -95
                                                                    end
                                                                    anti_aim_state.desync = value_26_2
                                                                end
                                                            end
                                                        else
                                                            value_25_2 = anti_aim_state.aa
                                                            if value_25_2 == 6 then
                                                                value_26_2 = script_controls.b
                                                                value_27_2 = anti_aim_state.s_i
                                                                value_28_2 = anti_aim_state.aa
                                                                value_27_2 = value_27_2[value_28_2]
                                                                value_26_2 = value_26_2[value_27_2]
                                                                if value_26_2 == "Freestanding" then
                                                                    value_26_2 = client.random_int
                                                                    value_27_2 = -60
                                                                    value_28_2 = -20
                                                                    value_26_2 = value_26_2(value_27_2, value_28_2)
                                                                    if not (value_26_2) then
                                                                        value_26_2 = (client.random_int)(20, 60)
                                                                    end
                                                                else
                                                                    value_26_2 = (client.random_int)(20, 60)
                                                                end
                                                                anti_aim_state.desync = value_26_2
                                                            else
                                                                value_25_2 = anti_aim_state.aa
                                                                if not (value_25_2 ~= 7) then
                                                                    value_26_2 = script_controls.b
                                                                    value_27_2 = anti_aim_state.s_i
                                                                    value_28_2 = anti_aim_state.aa
                                                                    value_27_2 = value_27_2[value_28_2]
                                                                    value_26_2 = value_26_2[value_27_2]
                                                                    if value_26_2 == "Freestanding" then
                                                                        value_26_2 = client.random_int
                                                                        value_27_2 = -60
                                                                        value_28_2 = -40
                                                                        value_26_2 = value_26_2(value_27_2, value_28_2)
                                                                        if not (value_26_2) then
                                                                            value_26_2 = (client.random_int)(40, 60)
                                                                        end
                                                                    else
                                                                        value_26_2 = (client.random_int)(40, 60)
                                                                    end
                                                                    anti_aim_state.desync = value_26_2
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                value_5_2 = anti_aim_state.target
                value_4_2 = (player_records[value_5_2]).m
                value_5_2 = script_controls["Anti-resolver shot amount"]
                if value_4_2 == value_5_2 then
                    value_4_2 = script_controls["Anti-resolver on X shot"]
                    if value_4_2 ~= "-" then
                        value_4_2 = script_controls["Anti-resolver on X shot"]
                        if value_4_2 == "None" then
                            anti_aim_state.desync = 0
                        else
                            value_4_2 = script_controls["Anti-resolver on X shot"]
                            if value_4_2 == "Jitter" then
                                anti_aim_state.desync = 180
                            end
                        end
                    end
                else
                    value_6_2 = anti_aim_state.target
                    value_5_2 = (player_records[value_6_2]).d
                    anti_aim_state.desync = value_5_2
                end
            end
        else
            value_4_2 = script_controls.b
            value_5_2 = anti_aim_state.s_i
            value_6_2 = anti_aim_state.aa
            value_5_2 = value_5_2[value_6_2]
            value_4_2 = value_4_2[value_5_2]
            if value_4_2 == "Off" then
                anti_aim_state.desync = 0
            else
                value_4_2 = script_controls.b
                value_5_2 = anti_aim_state.s_i
                value_6_2 = anti_aim_state.aa
                value_5_2 = value_5_2[value_6_2]
                value_4_2 = value_4_2[value_5_2]
                if value_4_2 == "Jitter" then
                    anti_aim_state.desync = 180
                else
                    value_4_2 = anti_aim_state.holding_e
                    if value_4_2 then
                        value_5_2 = anti_aim_state.desync
                        if value_5_2 ~= 0 then
                            value_5_2 = anti_aim_state.desync
                            if not (value_5_2 ~= 180) then
                                value_5_2 = 90
                            end
                        else
                            value_5_2 = 90
                        end
                        if not value_5_2 then
                            value_5_2 = anti_aim_state.desync
                        end
                        anti_aim_state.desync = value_5_2
                    else
                        anti_aim_state.desync = 180
                    end
                end
            end
        end
    end
    reset_player_state = function(argument_0_2, ...)
        local value_4_2, value_5_2, value_6_2, value_7_2, value_8_2
        if argument_0_2 == nil then
            argument_0_2 = false
        end
        for value_4_2 = 1, 64, 1 do
            value_5_2 = (player_records[value_4_2]).d
            value_6_2 = player_records
            value_7_2 = {
            }
            value_7_2.s = {
            }
            value_8_2 = {
            }
            value_7_2.h = value_8_2
            value_7_2.r = 0
            value_7_2.d = 0
            value_7_2.m = 0
            value_8_2 = value_5_2 or value_8_2
            if not argument_0_2 or not value_5_2 then
                value_8_2 = 0
            end
            value_7_2.l = value_8_2
            player_records[value_4_2] = value_7_2
        end
    end
    handle_use_key = function(argument_0_2, argument_1_2, ...)
        local value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2
        value_3_2 = script_controls.s
        value_2_2 = contains_value(value_3_2, ("Custom Legit AA"))
        if value_2_2 then
            value_2_2 = key_state(69)
            if value_2_2 then
                return
            else
                value_3_2 = script_controls.s
                value_2_2 = contains_value(value_3_2, ("Custom Legit AA"))
                if value_2_2 then
                    value_3_2 = script_controls.la
                    value_2_2 = ui_get(value_3_2)
                    if not (value_2_2) then
                        value_2_2 = key_state(69)
                    end
                else
                    value_2_2 = key_state(69)
                end
                if value_2_2 then
                    value_2_2 = 100
                    value_3_2 = (get_all_entities(("CPlantedC4")))[1]
                    if value_3_2 ~= nil then
                        value_4_2 = {
                        }
                        value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = get_prop(value_3_2, ("m_vecOrigin"))
                        value_4_2[1] = value_5_2
                        value_4_2[2] = value_6_2
                        value_4_2[3] = value_7_2
                        value_4_2[4] = value_8_2
                        value_4_2[5] = value_9_2
                        value_4_2[6] = value_10_2
                        value_4_2[7] = value_11_2
                        value_4_2[8] = value_12_2
                        value_4_2[9] = value_13_2
                        value_4_2[10] = value_14_2
                        value_4_2[11] = value_15_2
                        value_4_2[12] = value_16_2
                        value_4_2[13] = value_17_2
                        value_4_2[14] = value_18_2
                        value_4_2[15] = value_19_2
                        value_4_2[16] = value_20_2
                        value_4_2[17] = value_21_2
                        value_4_2[18] = value_22_2
                        value_4_2[19] = value_23_2
                        value_4_2[20] = value_24_2
                        if value_4_2 ~= nil then
                            value_5_2 = {
                            }
                            value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = get_prop(argument_0_2, ("m_vecOrigin"))
                            value_5_2[1] = value_6_2
                            value_5_2[2] = value_7_2
                            value_5_2[3] = value_8_2
                            value_5_2[4] = value_9_2
                            value_5_2[5] = value_10_2
                            value_5_2[6] = value_11_2
                            value_5_2[7] = value_12_2
                            value_5_2[8] = value_13_2
                            value_5_2[9] = value_14_2
                            value_5_2[10] = value_15_2
                            value_5_2[11] = value_16_2
                            value_5_2[12] = value_17_2
                            value_5_2[13] = value_18_2
                            value_5_2[14] = value_19_2
                            value_5_2[15] = value_20_2
                            value_5_2[16] = value_21_2
                            value_5_2[17] = value_22_2
                            value_5_2[18] = value_23_2
                            value_5_2[19] = value_24_2
                            local returned_56_38 = __dec14_pack_results(signed_coordinate_delta(value_5_2, value_4_2))
                            value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = unpack(returned_56_38, 1, returned_56_38.n)
                            value_2_2 = math_abs(unpack(returned_56_38, 1, returned_56_38.n))
                        end
                    end
                    value_4_2 = get_prop(argument_0_2, ("m_iTeamNum"))
                    if value_4_2 ~= 3 or not (value_2_2 < 62) then
                        value_5_2 = false
                    else
                        value_5_2 = true
                    end
                    value_6_2, value_7_2, value_8_2 = eye_position()
                    value_9_2, value_10_2 = camera_angles()
                    local returned_56_39 = __dec14_pack_results(math_rad(value_9_2))
                    value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = unpack(returned_56_39, 1, returned_56_39.n)
                    value_11_2 = math_sin(unpack(returned_56_39, 1, returned_56_39.n))
                    local returned_56_40 = __dec14_pack_results(math_rad(value_9_2))
                    value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = unpack(returned_56_40, 1, returned_56_40.n)
                    value_12_2 = math_cos(unpack(returned_56_40, 1, returned_56_40.n))
                    local returned_56_41 = __dec14_pack_results(math_rad(value_10_2))
                    value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = unpack(returned_56_41, 1, returned_56_41.n)
                    value_13_2 = math_sin(unpack(returned_56_41, 1, returned_56_41.n))
                    local returned_56_42 = __dec14_pack_results(math_rad(value_10_2))
                    value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = unpack(returned_56_42, 1, returned_56_42.n)
                    value_14_2 = math_cos(unpack(returned_56_42, 1, returned_56_42.n))
                    value_15_2 = {
                    }
                    value_16_2 = value_12_2 * value_14_2
                    value_17_2 = value_12_2 * value_13_2
                    value_18_2 = -value_11_2
                    value_15_2[1] = value_16_2
                    value_15_2[2] = value_17_2
                    value_15_2[3] = value_18_2
                    value_21_2 = (value_15_2[1]) * 8192
                    value_21_2 = value_6_2 + value_21_2
                    value_22_2 = (value_15_2[2]) * 8192
                    value_22_2 = value_7_2 + value_22_2
                    value_23_2 = (value_15_2[3]) * 8192
                    value_23_2 = value_8_2 + value_23_2
                    value_16_2, value_17_2 = trace_line(argument_0_2, value_6_2, value_7_2, value_8_2, value_21_2, value_22_2, value_23_2)
                    value_18_2 = true
                    if value_17_2 ~= nil then
                        value_20_2 = #(anti_aim_state.classnames)
                        for value_22_2 = 0, value_20_2, 1 do
                            value_23_2 = get_classname(value_17_2)
                            value_24_2 = (anti_aim_state.classnames)[value_22_2]
                            if value_23_2 == value_24_2 then
                                value_18_2 = false
                            end
                        end
                    end
                    if not value_18_2 and not value_5_2 then
                        argument_1_2.in_use = 0
                    end
                    return true
                else
                    return false
                end
            end
        else
            value_3_2 = script_controls.s
            value_2_2 = contains_value(value_3_2, ("Custom Legit AA"))
            if value_2_2 then
                value_3_2 = script_controls.la
                value_2_2 = ui_get(value_3_2)
                if not (value_2_2) then
                    value_2_2 = key_state(69)
                end
            else
                value_2_2 = key_state(69)
            end
            if value_2_2 then
                value_2_2 = 100
                value_3_2 = (get_all_entities(("CPlantedC4")))[1]
                if value_3_2 ~= nil then
                    value_4_2 = {
                    }
                    value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = get_prop(value_3_2, ("m_vecOrigin"))
                    value_4_2[1] = value_5_2
                    value_4_2[2] = value_6_2
                    value_4_2[3] = value_7_2
                    value_4_2[4] = value_8_2
                    value_4_2[5] = value_9_2
                    value_4_2[6] = value_10_2
                    value_4_2[7] = value_11_2
                    value_4_2[8] = value_12_2
                    value_4_2[9] = value_13_2
                    value_4_2[10] = value_14_2
                    value_4_2[11] = value_15_2
                    value_4_2[12] = value_16_2
                    value_4_2[13] = value_17_2
                    value_4_2[14] = value_18_2
                    value_4_2[15] = value_19_2
                    value_4_2[16] = value_20_2
                    value_4_2[17] = value_21_2
                    value_4_2[18] = value_22_2
                    value_4_2[19] = value_23_2
                    value_4_2[20] = value_24_2
                    if value_4_2 ~= nil then
                        value_5_2 = {
                        }
                        value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = get_prop(argument_0_2, ("m_vecOrigin"))
                        value_5_2[1] = value_6_2
                        value_5_2[2] = value_7_2
                        value_5_2[3] = value_8_2
                        value_5_2[4] = value_9_2
                        value_5_2[5] = value_10_2
                        value_5_2[6] = value_11_2
                        value_5_2[7] = value_12_2
                        value_5_2[8] = value_13_2
                        value_5_2[9] = value_14_2
                        value_5_2[10] = value_15_2
                        value_5_2[11] = value_16_2
                        value_5_2[12] = value_17_2
                        value_5_2[13] = value_18_2
                        value_5_2[14] = value_19_2
                        value_5_2[15] = value_20_2
                        value_5_2[16] = value_21_2
                        value_5_2[17] = value_22_2
                        value_5_2[18] = value_23_2
                        value_5_2[19] = value_24_2
                        local returned_56_38 = __dec14_pack_results(signed_coordinate_delta(value_5_2, value_4_2))
                        value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = unpack(returned_56_38, 1, returned_56_38.n)
                        value_2_2 = math_abs(unpack(returned_56_38, 1, returned_56_38.n))
                    end
                end
                value_4_2 = get_prop(argument_0_2, ("m_iTeamNum"))
                if value_4_2 ~= 3 or not (value_2_2 < 62) then
                    value_5_2 = false
                else
                    value_5_2 = true
                end
                value_6_2, value_7_2, value_8_2 = eye_position()
                value_9_2, value_10_2 = camera_angles()
                local returned_56_39 = __dec14_pack_results(math_rad(value_9_2))
                value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = unpack(returned_56_39, 1, returned_56_39.n)
                value_11_2 = math_sin(unpack(returned_56_39, 1, returned_56_39.n))
                local returned_56_40 = __dec14_pack_results(math_rad(value_9_2))
                value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = unpack(returned_56_40, 1, returned_56_40.n)
                value_12_2 = math_cos(unpack(returned_56_40, 1, returned_56_40.n))
                local returned_56_41 = __dec14_pack_results(math_rad(value_10_2))
                value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = unpack(returned_56_41, 1, returned_56_41.n)
                value_13_2 = math_sin(unpack(returned_56_41, 1, returned_56_41.n))
                local returned_56_42 = __dec14_pack_results(math_rad(value_10_2))
                value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2 = unpack(returned_56_42, 1, returned_56_42.n)
                value_14_2 = math_cos(unpack(returned_56_42, 1, returned_56_42.n))
                value_15_2 = {
                }
                value_16_2 = value_12_2 * value_14_2
                value_17_2 = value_12_2 * value_13_2
                value_18_2 = -value_11_2
                value_15_2[1] = value_16_2
                value_15_2[2] = value_17_2
                value_15_2[3] = value_18_2
                value_21_2 = (value_15_2[1]) * 8192
                value_21_2 = value_6_2 + value_21_2
                value_22_2 = (value_15_2[2]) * 8192
                value_22_2 = value_7_2 + value_22_2
                value_23_2 = (value_15_2[3]) * 8192
                value_23_2 = value_8_2 + value_23_2
                value_16_2, value_17_2 = trace_line(argument_0_2, value_6_2, value_7_2, value_8_2, value_21_2, value_22_2, value_23_2)
                value_18_2 = true
                if value_17_2 ~= nil then
                    value_20_2 = #(anti_aim_state.classnames)
                    for value_22_2 = 0, value_20_2, 1 do
                        value_23_2 = get_classname(value_17_2)
                        value_24_2 = (anti_aim_state.classnames)[value_22_2]
                        if value_23_2 == value_24_2 then
                            value_18_2 = false
                        end
                    end
                end
                if not value_18_2 and not value_5_2 then
                    argument_1_2.in_use = 0
                end
                return true
            else
                return false
            end
        end
    end
    value_98_1 = 0
    update_manual_and_freestanding = function(argument_0_2, ...)
        local value_2_2, value_3_2, value_6_2, value_7_2, value_8_2
        value_2_2 = (native_controls.yaw)[1]
        value_3_2 = anti_aim_state.holding_e
        if value_3_2 then
            value_3_2 = "Off"
            if not ("Off") then
                value_3_2 = "180"
            end
        else
            value_3_2 = "180"
        end
        ui_set(value_2_2, value_3_2)
        value_2_2 = native_controls.pitch
        value_3_2 = anti_aim_state.holding_e
        if value_3_2 then
            value_3_2 = "Off"
            if not ("Off") then
                value_3_2 = "Default"
            end
        else
            value_3_2 = "Default"
        end
        ui_set(value_2_2, value_3_2)
        value_2_2 = native_controls.yawbase
        ui_set(value_2_2, ("At targets"))
        value_6_2 = anti_aim_state.aa
        if value_6_2 == 1 then
            value_98_1 = 0
        else
            value_6_2 = anti_aim_state.aa
            if value_6_2 == 2 then
                value_98_1 = 0
            else
                value_6_2 = anti_aim_state.aa
                if value_6_2 == 3 then
                    value_98_1 = 0
                else
                    value_6_2 = anti_aim_state.aa
                    if value_6_2 == 4 then
                        value_98_1 = 0
                    else
                        value_6_2 = anti_aim_state.aa
                        if value_6_2 == 6 then
                            value_98_1 = 0
                        end
                    end
                end
            end
        end
        value_7_2 = script_controls.s
        value_6_2 = contains_value(value_7_2, ("Manual AA"))
        if value_6_2 then
            value_7_2 = script_controls.ml
            value_6_2 = ui_get(value_7_2)
            if value_6_2 then
                value_6_2 = ((anti_aim_state.dir).time) + 0.2
                value_7_2 = curtime()
                if value_6_2 < value_7_2 then
                    value_6_2 = anti_aim_state.dir
                    value_7_2 = (anti_aim_state.dir).manual
                    if value_7_2 == -90 then
                        value_7_2 = value_98_1
                        if not value_98_1 then
                            value_7_2 = -90
                        end
                    else
                        value_7_2 = -90
                    end
                    value_6_2.manual = value_7_2
                    value_6_2 = anti_aim_state.dir
                    value_6_2.time = curtime()
                end
            else
                value_7_2 = script_controls.mr
                value_6_2 = ui_get(value_7_2)
                if value_6_2 then
                    value_6_2 = ((anti_aim_state.dir).time) + 0.2
                    value_7_2 = curtime()
                    if value_6_2 < value_7_2 then
                        value_6_2 = anti_aim_state.dir
                        value_7_2 = (anti_aim_state.dir).manual
                        if value_7_2 == 90 then
                            value_7_2 = value_98_1
                            if not value_98_1 then
                                value_7_2 = 90
                            end
                        else
                            value_7_2 = 90
                        end
                        value_6_2.manual = value_7_2
                        value_6_2 = anti_aim_state.dir
                        value_6_2.time = curtime()
                    end
                else
                    value_7_2 = script_controls.mf
                    value_6_2 = ui_get(value_7_2)
                    if value_6_2 then
                        value_6_2 = ((anti_aim_state.dir).time) + 0.2
                        value_7_2 = curtime()
                        if value_6_2 < value_7_2 then
                            value_6_2 = anti_aim_state.dir
                            value_7_2 = (anti_aim_state.dir).manual
                            if value_7_2 == 180 then
                                value_7_2 = value_98_1
                                if not value_98_1 then
                                    value_7_2 = 180
                                end
                            else
                                value_7_2 = 180
                            end
                            value_6_2.manual = value_7_2
                            value_6_2 = anti_aim_state.dir
                            value_6_2.time = curtime()
                        end
                    else
                        value_6_2 = (anti_aim_state.dir).time
                        value_7_2 = curtime()
                        if value_6_2 > value_7_2 then
                            value_6_2 = anti_aim_state.dir
                            value_6_2.time = curtime()
                            value_6_2 = (anti_aim_state.dir).manual
                            if value_6_2 == -90 then
                                value_6_2 = (anti_aim_state.dir).manual
                                if value_6_2 == 90 then
                                    value_6_2 = (anti_aim_state.dir).manual
                                    if not (value_6_2 == 180) then
                                        value_6_2 = anti_aim_state.dir
                                        value_6_2.manual = value_98_1
                                    end
                                else
                                    value_6_2 = anti_aim_state.dir
                                    value_6_2.manual = value_98_1
                                end
                            else
                                value_6_2 = anti_aim_state.dir
                                value_6_2.manual = value_98_1
                            end
                        end
                    end
                end
            end
            value_6_2 = (anti_aim_state.dir).manual
            value_7_2 = (anti_aim_state.stored_dir).manual
            if value_6_2 ~= value_7_2 then
                value_7_2 = (native_controls.yaw)[2]
                value_8_2 = (anti_aim_state.dir).manual
                ui_set(value_7_2, value_8_2)
                value_6_2 = anti_aim_state.stored_dir
                value_6_2.manual = (anti_aim_state.dir).manual
            end
        else
            value_6_2 = anti_aim_state.dir
            value_6_2.manual = value_98_1
        end
        value_7_2 = (native_controls.yaw)[2]
        value_8_2 = (anti_aim_state.dir).manual
        ui_set(value_7_2, value_8_2)
        value_6_2 = anti_aim_state.dir
        value_8_2 = script_controls.s
        value_7_2 = contains_value(value_8_2, ("Edge yaw"))
        if value_7_2 then
            value_8_2 = script_controls.ey
            value_7_2 = ui_get(value_8_2)
            if value_7_2 then
                value_7_2 = not (anti_aim_state.holding_e)
            end
        end
        value_6_2.edge = value_7_2
        value_6_2 = anti_aim_state.dir
        value_8_2 = script_controls.s
        value_7_2 = contains_value(value_8_2, ("Freestanding"))
        if value_7_2 then
            value_8_2 = script_controls.fs
            value_7_2 = ui_get(value_8_2)
            if value_7_2 then
                value_7_2 = not (anti_aim_state.holding_e)
            end
        end
        value_6_2.freestand = value_7_2
        value_6_2 = (anti_aim_state.dir).freestand
        value_7_2 = (anti_aim_state.stored_dir).freestand
        if value_6_2 ~= value_7_2 then
            value_7_2 = (native_controls.freestand)[1]
            value_8_2 = (anti_aim_state.dir).freestand
            if value_8_2 then
                value_8_2 = "Default"
                if not ("Default") then
                    value_8_2 = "-"
                end
            else
                value_8_2 = "-"
            end
            ui_set(value_7_2, value_8_2)
            value_7_2 = (native_controls.freestand)[2]
            ui_set(value_7_2, ("Always on"))
            value_6_2 = anti_aim_state.stored_dir
            value_6_2.freestand = (anti_aim_state.dir).freestand
        end
        value_6_2 = (anti_aim_state.dir).edge
        value_7_2 = (anti_aim_state.stored_dir).edge
        if value_6_2 ~= value_7_2 then
            value_7_2 = native_controls.edgeyaw
            value_8_2 = (anti_aim_state.dir).edge
            ui_set(value_7_2, value_8_2)
            value_6_2 = anti_aim_state.stored_dir
            value_6_2.edge = (anti_aim_state.dir).edge
        end
    end
    point_on_circle = function(argument_0_2, argument_1_2, argument_2_2, argument_3_2, ...)
        local value_4_2, value_5_2, value_6_2, value_7_2
        local returned_58_43 = __dec14_pack_results(math_rad(argument_2_2))
        value_5_2, value_6_2, value_7_2 = unpack(returned_58_43, 1, returned_58_43.n)
        value_4_2 = ((math_cos(unpack(returned_58_43, 1, returned_58_43.n))) * argument_3_2) + argument_0_2
        local returned_58_44 = __dec14_pack_results(math_rad(argument_2_2))
        value_6_2, value_7_2 = unpack(returned_58_44, 1, returned_58_44.n)
        value_5_2 = ((math_sin(unpack(returned_58_44, 1, returned_58_44.n))) * argument_3_2) + argument_1_2
        return value_4_2, value_5_2
    end
    draw_indicator_triangle = function(argument_0_2, argument_1_2, argument_2_2, argument_3_2, argument_4_2, argument_5_2, argument_6_2, argument_7_2, argument_8_2, argument_9_2, argument_10_2, argument_11_2, argument_12_2, ...)
        local value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_30_2, value_31_2, value_32_2, value_33_2
        value_15_2 = argument_1_2 + 4
        value_13_2, value_14_2 = point_on_circle(argument_0_2, value_15_2, argument_10_2, 45)
        value_17_2 = argument_1_2 + 4
        value_18_2 = argument_11_2 / 3
        value_18_2 = argument_10_2 + value_18_2
        value_19_2 = argument_11_2 / 4
        value_19_2 = 45 - value_19_2
        value_15_2, value_16_2 = point_on_circle(argument_0_2, value_17_2, value_18_2, value_19_2)
        value_19_2 = argument_1_2 + 4
        value_21_2 = argument_11_2 / 5
        value_21_2 = 45 - value_21_2
        value_17_2, value_18_2 = point_on_circle(argument_0_2, value_19_2, argument_10_2, value_21_2)
        value_21_2 = argument_1_2 + 4
        value_23_2 = argument_11_2 / 5
        value_23_2 = 45 - value_23_2
        value_19_2, value_20_2 = point_on_circle(argument_0_2, value_21_2, argument_10_2, value_23_2)
        value_23_2 = argument_1_2 + 4
        value_24_2 = argument_11_2 / 3
        value_24_2 = argument_10_2 - value_24_2
        value_25_2 = argument_11_2 / 4
        value_25_2 = 45 - value_25_2
        value_21_2, value_22_2 = point_on_circle(argument_0_2, value_23_2, value_24_2, value_25_2)
        value_30_2 = argument_6_2 or nil
        if not argument_12_2 or not argument_6_2 then
            value_30_2 = argument_2_2
        end
        value_31_2 = argument_7_2 or nil
        if not argument_12_2 or not argument_7_2 then
            value_31_2 = argument_3_2
        end
        value_32_2 = argument_8_2 or nil
        if not argument_12_2 or not argument_8_2 then
            value_32_2 = argument_4_2
        end
        value_33_2 = argument_9_2 or nil
        if not argument_12_2 or not argument_9_2 then
            value_33_2 = argument_5_2
        end
        draw_triangle(value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_30_2, value_31_2, value_32_2, value_33_2)
        value_30_2 = argument_2_2 or value_30_2
        if not argument_12_2 or not argument_2_2 then
            value_30_2 = argument_6_2
        end
        value_31_2 = argument_3_2 or value_31_2
        if not argument_12_2 or not argument_3_2 then
            value_31_2 = argument_7_2
        end
        value_32_2 = argument_4_2 or value_32_2
        if not argument_12_2 or not argument_4_2 then
            value_32_2 = argument_8_2
        end
        value_33_2 = argument_5_2 or value_33_2
        if not argument_12_2 or not argument_5_2 then
            value_33_2 = argument_9_2
        end
        draw_triangle(value_13_2, value_14_2, value_19_2, value_20_2, value_21_2, value_22_2, value_30_2, value_31_2, value_32_2, value_33_2)
        draw_line(value_13_2, value_14_2, value_19_2, value_20_2, 0, 0, 0, 200)
    end
    reset_clan_tag = function(...)
        if value_93_1 then

        else

        end
    end
    apply_body_yaw = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2
        value_1_2 = get_local_player()
        value_2_2 = anti_aim_state.rec
        value_3_2 = (#(anti_aim_state.rec)) + 1
        value_4_2 = {
        }
        value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2 = head_coordinates(value_1_2)
        value_4_2[1] = value_5_2
        value_4_2[2] = value_6_2
        value_4_2[3] = value_7_2
        value_4_2[4] = value_8_2
        value_4_2[5] = value_9_2
        value_4_2[6] = value_10_2
        value_4_2[7] = value_11_2
        value_2_2[value_3_2] = value_4_2
        value_2_2 = #(anti_aim_state.rec)
        if 28 < value_2_2 then
            value_3_2 = anti_aim_state.rec
            table_remove(value_3_2, 1)
        end
        classify_movement(value_1_2, argument_0_2)
        update_target_anti_aim(value_1_2)
        value_3_2 = handle_use_key(value_1_2, argument_0_2)
        anti_aim_state.holding_e = value_3_2
        value_4_2 = anti_aim_state.holding_e
        update_manual_and_freestanding(value_1_2, value_4_2)
        value_3_2 = (native_controls.bodyyaw)[1]
        if fs then
            value_4_2 = "Static"
            if not ("Static") then
                value_4_2 = anti_aim_state.desync
                if value_4_2 == 180 then
                    value_5_2 = script_controls.s
                    value_4_2 = contains_value(value_5_2, ("Jitter when not networked"))
                    if value_4_2 then
                        value_4_2 = "Jitter"
                        if not ("Jitter") then
                            value_4_2 = anti_aim_state.aa
                            if value_4_2 == 3 then
                                value_4_2 = "Jitter"
                                if not ("Jitter") then
                                    value_4_2 = anti_aim_state.aa
                                    if value_4_2 == 2 then
                                        value_4_2 = "Jitter"
                                        if not ("Jitter") then
                                            value_4_2 = anti_aim_state.aa
                                            if value_4_2 == 4 then
                                                value_4_2 = "Jitter"
                                                if not ("Jitter") then
                                                    value_4_2 = "Static"
                                                end
                                            else
                                                value_4_2 = "Static"
                                            end
                                        end
                                    else
                                        value_4_2 = anti_aim_state.aa
                                        if value_4_2 == 4 then
                                            value_4_2 = "Jitter"
                                            if not ("Jitter") then
                                                value_4_2 = "Static"
                                            end
                                        else
                                            value_4_2 = "Static"
                                        end
                                    end
                                end
                            else
                                value_4_2 = anti_aim_state.aa
                                if value_4_2 == 2 then
                                    value_4_2 = "Jitter"
                                    if not ("Jitter") then
                                        value_4_2 = anti_aim_state.aa
                                        if value_4_2 == 4 then
                                            value_4_2 = "Jitter"
                                            if not ("Jitter") then
                                                value_4_2 = "Static"
                                            end
                                        else
                                            value_4_2 = "Static"
                                        end
                                    end
                                else
                                    value_4_2 = anti_aim_state.aa
                                    if value_4_2 == 4 then
                                        value_4_2 = "Jitter"
                                        if not ("Jitter") then
                                            value_4_2 = "Static"
                                        end
                                    else
                                        value_4_2 = "Static"
                                    end
                                end
                            end
                        end
                    else
                        value_4_2 = anti_aim_state.aa
                        if value_4_2 == 3 then
                            value_4_2 = "Jitter"
                            if not ("Jitter") then
                                value_4_2 = anti_aim_state.aa
                                if value_4_2 == 2 then
                                    value_4_2 = "Jitter"
                                    if not ("Jitter") then
                                        value_4_2 = anti_aim_state.aa
                                        if value_4_2 == 4 then
                                            value_4_2 = "Jitter"
                                            if not ("Jitter") then
                                                value_4_2 = "Static"
                                            end
                                        else
                                            value_4_2 = "Static"
                                        end
                                    end
                                else
                                    value_4_2 = anti_aim_state.aa
                                    if value_4_2 == 4 then
                                        value_4_2 = "Jitter"
                                        if not ("Jitter") then
                                            value_4_2 = "Static"
                                        end
                                    else
                                        value_4_2 = "Static"
                                    end
                                end
                            end
                        else
                            value_4_2 = anti_aim_state.aa
                            if value_4_2 == 2 then
                                value_4_2 = "Jitter"
                                if not ("Jitter") then
                                    value_4_2 = anti_aim_state.aa
                                    if value_4_2 == 4 then
                                        value_4_2 = "Jitter"
                                        if not ("Jitter") then
                                            value_4_2 = "Static"
                                        end
                                    else
                                        value_4_2 = "Static"
                                    end
                                end
                            else
                                value_4_2 = anti_aim_state.aa
                                if value_4_2 == 4 then
                                    value_4_2 = "Jitter"
                                    if not ("Jitter") then
                                        value_4_2 = "Static"
                                    end
                                else
                                    value_4_2 = "Static"
                                end
                            end
                        end
                    end
                else
                    value_4_2 = anti_aim_state.aa
                    if value_4_2 == 3 then
                        value_4_2 = "Jitter"
                        if not ("Jitter") then
                            value_4_2 = anti_aim_state.aa
                            if value_4_2 == 2 then
                                value_4_2 = "Jitter"
                                if not ("Jitter") then
                                    value_4_2 = anti_aim_state.aa
                                    if value_4_2 == 4 then
                                        value_4_2 = "Jitter"
                                        if not ("Jitter") then
                                            value_4_2 = "Static"
                                        end
                                    else
                                        value_4_2 = "Static"
                                    end
                                end
                            else
                                value_4_2 = anti_aim_state.aa
                                if value_4_2 == 4 then
                                    value_4_2 = "Jitter"
                                    if not ("Jitter") then
                                        value_4_2 = "Static"
                                    end
                                else
                                    value_4_2 = "Static"
                                end
                            end
                        end
                    else
                        value_4_2 = anti_aim_state.aa
                        if value_4_2 == 2 then
                            value_4_2 = "Jitter"
                            if not ("Jitter") then
                                value_4_2 = anti_aim_state.aa
                                if value_4_2 == 4 then
                                    value_4_2 = "Jitter"
                                    if not ("Jitter") then
                                        value_4_2 = "Static"
                                    end
                                else
                                    value_4_2 = "Static"
                                end
                            end
                        else
                            value_4_2 = anti_aim_state.aa
                            if value_4_2 == 4 then
                                value_4_2 = "Jitter"
                                if not ("Jitter") then
                                    value_4_2 = "Static"
                                end
                            else
                                value_4_2 = "Static"
                            end
                        end
                    end
                end
            end
        else
            value_4_2 = anti_aim_state.desync
            if value_4_2 == 180 then
                value_5_2 = script_controls.s
                value_4_2 = contains_value(value_5_2, ("Jitter when not networked"))
                if value_4_2 then
                    value_4_2 = "Jitter"
                    if not ("Jitter") then
                        value_4_2 = anti_aim_state.aa
                        if value_4_2 == 3 then
                            value_4_2 = "Jitter"
                            if not ("Jitter") then
                                value_4_2 = anti_aim_state.aa
                                if value_4_2 == 2 then
                                    value_4_2 = "Jitter"
                                    if not ("Jitter") then
                                        value_4_2 = anti_aim_state.aa
                                        if value_4_2 == 4 then
                                            value_4_2 = "Jitter"
                                            if not ("Jitter") then
                                                value_4_2 = "Static"
                                            end
                                        else
                                            value_4_2 = "Static"
                                        end
                                    end
                                else
                                    value_4_2 = anti_aim_state.aa
                                    if value_4_2 == 4 then
                                        value_4_2 = "Jitter"
                                        if not ("Jitter") then
                                            value_4_2 = "Static"
                                        end
                                    else
                                        value_4_2 = "Static"
                                    end
                                end
                            end
                        else
                            value_4_2 = anti_aim_state.aa
                            if value_4_2 == 2 then
                                value_4_2 = "Jitter"
                                if not ("Jitter") then
                                    value_4_2 = anti_aim_state.aa
                                    if value_4_2 == 4 then
                                        value_4_2 = "Jitter"
                                        if not ("Jitter") then
                                            value_4_2 = "Static"
                                        end
                                    else
                                        value_4_2 = "Static"
                                    end
                                end
                            else
                                value_4_2 = anti_aim_state.aa
                                if value_4_2 == 4 then
                                    value_4_2 = "Jitter"
                                    if not ("Jitter") then
                                        value_4_2 = "Static"
                                    end
                                else
                                    value_4_2 = "Static"
                                end
                            end
                        end
                    end
                else
                    value_4_2 = anti_aim_state.aa
                    if value_4_2 == 3 then
                        value_4_2 = "Jitter"
                        if not ("Jitter") then
                            value_4_2 = anti_aim_state.aa
                            if value_4_2 == 2 then
                                value_4_2 = "Jitter"
                                if not ("Jitter") then
                                    value_4_2 = anti_aim_state.aa
                                    if value_4_2 == 4 then
                                        value_4_2 = "Jitter"
                                        if not ("Jitter") then
                                            value_4_2 = "Static"
                                        end
                                    else
                                        value_4_2 = "Static"
                                    end
                                end
                            else
                                value_4_2 = anti_aim_state.aa
                                if value_4_2 == 4 then
                                    value_4_2 = "Jitter"
                                    if not ("Jitter") then
                                        value_4_2 = "Static"
                                    end
                                else
                                    value_4_2 = "Static"
                                end
                            end
                        end
                    else
                        value_4_2 = anti_aim_state.aa
                        if value_4_2 == 2 then
                            value_4_2 = "Jitter"
                            if not ("Jitter") then
                                value_4_2 = anti_aim_state.aa
                                if value_4_2 == 4 then
                                    value_4_2 = "Jitter"
                                    if not ("Jitter") then
                                        value_4_2 = "Static"
                                    end
                                else
                                    value_4_2 = "Static"
                                end
                            end
                        else
                            value_4_2 = anti_aim_state.aa
                            if value_4_2 == 4 then
                                value_4_2 = "Jitter"
                                if not ("Jitter") then
                                    value_4_2 = "Static"
                                end
                            else
                                value_4_2 = "Static"
                            end
                        end
                    end
                end
            else
                value_4_2 = anti_aim_state.aa
                if value_4_2 == 3 then
                    value_4_2 = "Jitter"
                    if not ("Jitter") then
                        value_4_2 = anti_aim_state.aa
                        if value_4_2 == 2 then
                            value_4_2 = "Jitter"
                            if not ("Jitter") then
                                value_4_2 = anti_aim_state.aa
                                if value_4_2 == 4 then
                                    value_4_2 = "Jitter"
                                    if not ("Jitter") then
                                        value_4_2 = "Static"
                                    end
                                else
                                    value_4_2 = "Static"
                                end
                            end
                        else
                            value_4_2 = anti_aim_state.aa
                            if value_4_2 == 4 then
                                value_4_2 = "Jitter"
                                if not ("Jitter") then
                                    value_4_2 = "Static"
                                end
                            else
                                value_4_2 = "Static"
                            end
                        end
                    end
                else
                    value_4_2 = anti_aim_state.aa
                    if value_4_2 == 2 then
                        value_4_2 = "Jitter"
                        if not ("Jitter") then
                            value_4_2 = anti_aim_state.aa
                            if value_4_2 == 4 then
                                value_4_2 = "Jitter"
                                if not ("Jitter") then
                                    value_4_2 = "Static"
                                end
                            else
                                value_4_2 = "Static"
                            end
                        end
                    else
                        value_4_2 = anti_aim_state.aa
                        if value_4_2 == 4 then
                            value_4_2 = "Jitter"
                            if not ("Jitter") then
                                value_4_2 = "Static"
                            end
                        else
                            value_4_2 = "Static"
                        end
                    end
                end
            end
        end
        ui_set(value_3_2, value_4_2)
        value_3_2 = (native_controls.bodyyaw)[2]
        value_4_2 = anti_aim_state.desync
        if value_4_2 == 180 then
            value_4_2 = 0
            if not 0 then
                value_4_2 = anti_aim_state.holding_e
                if value_4_2 then
                    value_4_2 = -(anti_aim_state.desync)
                    if not (value_4_2) then
                        value_4_2 = anti_aim_state.desync
                    end
                else
                    value_4_2 = anti_aim_state.desync
                end
            end
        else
            value_4_2 = anti_aim_state.holding_e
            if value_4_2 then
                value_4_2 = -(anti_aim_state.desync)
                if not (value_4_2) then
                    value_4_2 = anti_aim_state.desync
                end
            else
                value_4_2 = anti_aim_state.desync
            end
        end
        ui_set(value_3_2, value_4_2)
        value_2_2 = anti_aim_state.aa
        if value_2_2 == 1 then
            value_3_2 = (native_controls.yawjitter)[1]
            ui_set(value_3_2, ("Random"))
            value_3_2 = (native_controls.yawjitter)[2]
            ui_set(value_3_2, 7)
        else
            value_2_2 = anti_aim_state.aa
            if value_2_2 == 2 then
                value_3_2 = (native_controls.yawjitter)[1]
                ui_set(value_3_2, ("Center"))
                value_3_2 = (native_controls.yawjitter)[2]
                ui_set(value_3_2, 60)
            else
                value_2_2 = anti_aim_state.aa
                if value_2_2 == 3 then
                    value_3_2 = (native_controls.yawjitter)[1]
                    ui_set(value_3_2, ("Offset"))
                    value_3_2 = (native_controls.yawjitter)[2]
                    value_4_2 = client.random_int
                    local returned_61_45 = __dec14_pack_results(value_4_2(0, 60))
                    value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2 = unpack(returned_61_45, 1, returned_61_45.n)
                    ui_set(value_3_2, unpack(returned_61_45, 1, returned_61_45.n))
                else
                    value_2_2 = anti_aim_state.aa
                    if value_2_2 == 4 then
                        value_3_2 = (native_controls.yawjitter)[1]
                        ui_set(value_3_2, ("Center"))
                        value_3_2 = (native_controls.yawjitter)[2]
                        ui_set(value_3_2, 35)
                    else
                        value_2_2 = anti_aim_state.aa
                        if value_2_2 == 5 then
                            value_3_2 = (native_controls.yawjitter)[1]
                            ui_set(value_3_2, ("Off"))
                            value_3_2 = (native_controls.yawjitter)[2]
                            ui_set(value_3_2, 0)
                        else
                            value_2_2 = anti_aim_state.aa
                            if value_2_2 == 6 then
                                value_3_2 = (native_controls.yawjitter)[1]
                                ui_set(value_3_2, ("Off"))
                                value_3_2 = (native_controls.yawjitter)[2]
                                ui_set(value_3_2, 20)
                            else
                                value_2_2 = anti_aim_state.aa
                                if value_2_2 == 7 then
                                    value_3_2 = (native_controls.yawjitter)[1]
                                    ui_set(value_3_2, ("Center"))
                                    value_3_2 = (native_controls.yawjitter)[2]
                                    ui_set(value_3_2, 10)
                                end
                            end
                        end
                    end
                end
            end
        end
        if not value_94_1 then
            value_2_2 = client.delay_call
            value_2_2(0.25, reset_clan_tag)
            value_94_1 = true
        end
        value_7_2 = (client.random_int)(45, 60)
        value_8_2 = (client.random_int)(45, 60)
        value_9_2 = anti_aim_state.aa
        if value_9_2 == 1 then
            value_10_2 = native_controls.fakeyawlimit
            if value_10_2 ~= nil then ui_set(value_10_2, 60) end
        else
            value_9_2 = anti_aim_state.aa
            if value_9_2 == 2 then
                value_10_2 = native_controls.fakeyawlimit
                if value_10_2 ~= nil then ui_set(value_10_2, 60) end
            else
                value_9_2 = anti_aim_state.aa
                if value_9_2 == 3 then
                    value_10_2 = native_controls.fakeyawlimit
                    if value_10_2 ~= nil then ui_set(value_10_2, 60) end
                else
                    value_9_2 = anti_aim_state.aa
                    if value_9_2 == 4 then
                        value_10_2 = native_controls.fakeyawlimit
                        if value_10_2 ~= nil then ui_set(value_10_2, 60) end
                    else
                        value_9_2 = anti_aim_state.aa
                        if value_9_2 == 5 then
                            value_10_2 = native_controls.fakeyawlimit
                            if value_10_2 ~= nil then ui_set(value_10_2, 60) end
                        else
                            value_9_2 = anti_aim_state.aa
                            if value_9_2 == 6 then
                                value_10_2 = native_controls.fakeyawlimit
                                if value_10_2 ~= nil then ui_set(value_10_2, value_7_2) end
                            else
                                value_9_2 = anti_aim_state.aa
                                if value_9_2 == 7 then
                                    value_10_2 = native_controls.fakeyawlimit
                                    if value_10_2 ~= nil then ui_set(value_10_2, value_8_2) end
                                end
                            end
                        end
                    end
                end
            end
        end
        set_native_ui_visible(false)
    end
    on_bullet_impact = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2
        value_1_2 = get_local_player()
        value_3_2 = argument_0_2.userid
        value_2_2 = userid_to_entindex(value_3_2)
        value_3_2 = is_enemy(value_2_2)
        if value_3_2 then
            value_3_2 = is_alive(value_1_2)
            if value_3_2 then
                value_3_2 = is_valid_player(value_2_2)
                if value_3_2 then
                    value_3_2 = target_info(value_2_2, argument_0_2)
                    value_6_2 = anti_aim_state.ls
                    value_4_2 = target_record_info(value_3_2, value_6_2, value_2_2, value_1_2, argument_0_2)
                    if value_4_2 then
                        value_4_2 = #((player_records[value_2_2]).s)
                        if 0 < value_4_2 then
                            value_4_2 = (player_records[value_2_2]).s
                            value_5_2 = #((player_records[value_2_2]).s)
                            value_4_2 = (value_4_2[value_5_2]).t
                            value_5_2 = curtime()
                            if value_4_2 == value_5_2 then
                                value_4_2 = #((player_records[value_2_2]).s)
                                if not (value_4_2) then
                                    value_4_2 = (#((player_records[value_2_2]).s)) + 1
                                end
                            else
                                value_4_2 = (#((player_records[value_2_2]).s)) + 1
                            end
                        else
                            value_4_2 = (#((player_records[value_2_2]).s)) + 1
                        end
                        value_5_2 = anti_aim_state.desync
                        if value_5_2 ~= 0 then
                            value_5_2 = anti_aim_state.desync
                            if value_5_2 ~= 180 then
                                value_5_2 = script_controls["Detect missed angle"]
                            end
                        else
                            value_5_2 = true
                        end
                        value_6_2 = anti_aim_state.desync
                        value_7_2 = anti_aim_state.desync
                        if value_6_2 == value_7_2 then
                            value_6_2 = -(anti_aim_state.desync)
                            if not (value_6_2) then
                                value_6_2 = anti_aim_state.desync
                            end
                        else
                            value_6_2 = anti_aim_state.desync
                        end
                        if value_5_2 then
                            value_7_2 = math_abs(value_3_2)
                            if value_7_2 < 3 then
                                value_7_2 = anti_aim_state.desync
                                if value_7_2 then
                                    value_7_2 = anti_aim_state.desync
                                    value_6_2 = value_7_2 or value_6_2
                                end
                                if not value_7_2 then
                                    value_7_2 = anti_aim_state.desync
                                    value_6_2 = -value_7_2
                                end
                            else
                                if 0 < value_3_2 then
                                    value_7_2 = -(anti_aim_state.desync)
                                    if not (value_7_2) then
                                        value_6_2 = anti_aim_state.desync
                                    end
                                else
                                    value_6_2 = anti_aim_state.desync
                                end
                            end
                        end
                        value_7_2 = (player_records[value_2_2]).s
                        value_8_2 = {
                        }
                        value_8_2.t = tickcount()
                        value_8_2.d = value_6_2
                        value_8_2.dis = value_3_2
                        value_7_2[value_4_2] = value_8_2
                    end
                else
                    do
                        return
                    end
                end
            else
                do
                    return
                end
            end
        else
            do
                return
            end
        end
    end
    on_player_hurt = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2
        value_1_2 = get_local_player()
        value_3_2 = argument_0_2.userid
        value_2_2 = userid_to_entindex(value_3_2)
        value_4_2 = argument_0_2.attacker
        value_3_2 = userid_to_entindex(value_4_2)
        value_4_2 = is_enemy(value_3_2)
        if value_4_2 then
            value_4_2 = is_alive(value_1_2)
            if value_4_2 then
                value_5_2 = #(anti_aim_state.nonweapons)
                for value_7_2 = 1, value_5_2, 1 do
                    value_8_2 = argument_0_2.weapon
                    value_9_2 = (anti_aim_state.nonweapons)[value_7_2]
                    if value_8_2 == value_9_2 then
                        return
                    end
                end
                value_4_2 = #((player_records[value_3_2]).h)
                if 0 < value_4_2 then
                    value_4_2 = #((player_records[value_3_2]).h)
                    if not (value_4_2) then
                        value_4_2 = (#((player_records[value_3_2]).h)) + 1
                    end
                else
                    value_4_2 = (#((player_records[value_3_2]).h)) + 1
                end
                value_5_2 = (player_records[value_3_2]).h
                value_6_2 = {
                }
                value_6_2.t = tickcount()
                value_6_2.d = new_angle
                value_6_2.h = argument_0_2.hitgroup
                value_6_2.v = value_2_2
                value_5_2[value_4_2] = value_6_2
            else
                do
                    return
                end
            end
        else
            do
                return
            end
        end
    end
    on_player_spawn = function(argument_0_2, ...)
        local value_1_2, value_2_2, value_3_2
        value_1_2 = get_local_player()
        value_3_2 = argument_0_2.userid
        value_2_2 = userid_to_entindex(value_3_2)
        if value_2_2 == value_1_2 then
            reset_player_state(true)
        end
    end
    value_107_1 = {
    }
    value_107_1[1] = ("")
    value_107_1[2] = ("p")
    value_107_1[3] = ("pr")
    value_107_1[4] = ("pre")
    value_107_1[5] = ("pred")
    value_107_1[6] = ("predi")
    value_107_1[7] = ("predic")
    value_107_1[8] = ("predict")
    value_107_1[9] = ("predicti")
    value_107_1[10] = ("predictio")
    value_107_1[11] = ("prediction.lua")
    value_107_1[12] = ("")
    value_107_1[13] = ("prediction.lua")
    value_107_1[14] = ("")
    value_107_1[15] = ("prediction.lua")
    value_107_1[16] = ("")
    value_107_1[17] = ("prediction.lua")
    value_107_1[18] = ("")
    value_107_1[19] = ("predictio")
    value_107_1[20] = ("predicti")
    value_107_1[21] = ("predict")
    value_107_1[22] = ("predic")
    value_107_1[23] = ("predi")
    value_107_1[24] = ("pred")
    value_107_1[25] = ("pre")
    value_107_1[26] = ("pr")
    value_107_1[27] = ("p")
    value_107_1[28] = ("")
    value_108_1 = {
    }
    value_108_1[1] = ("nemesis")
    value_108_1[2] = ("n3m3sis")
    value_109_1 = 1
    value_110_1 = 0
    value_111_1 = false
    clear_clan_tag = client.set_event_callback
    update_ui_visibility = function(argument_0_2, ...)
        local value_1_2
        value_1_2 = (globals.tickcount)()
    end
    clear_clan_tag(("player_connect_full"), update_ui_visibility)
    clear_clan_tag = function(...)
        local value_0_2
        value_0_2 = client.set_clan_tag
        value_0_2((""))
    end
    draw_indicators = client.set_event_callback
    whitelisted = function(...)
        local value_0_2
        if value_111_1 then
            value_0_2 = client.delay_call
            value_0_2(0.15, clear_clan_tag)
        end
    end
    draw_indicators(("shutdown"), whitelisted)
    draw_indicators = function(...)
        local value_0_2, value_1_2, value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2
        value_0_2 = get_local_player()
        update_shot_history(value_0_2)
        value_2_2 = script_controls.s
        value_1_2 = contains_value(value_2_2, ("Adaptive clantag"))
        if value_1_2 then
            value_1_2 = ((entity.get_all)(("CCSPlayerResource")))[1]
            value_2_2 = entity.get_prop
            value_5_2 = entity.get_local_player
            local returned_68_46 = __dec14_pack_results(value_5_2())
            value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = unpack(returned_68_46, 1, returned_68_46.n)
            value_2_2 = value_2_2(value_1_2, ("m_iKills"), unpack(returned_68_46, 1, returned_68_46.n))
            value_3_2 = entity.get_prop
            value_6_2 = entity.get_local_player
            local returned_68_47 = __dec14_pack_results(value_6_2())
            value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = unpack(returned_68_47, 1, returned_68_47.n)
            value_3_2 = value_3_2(value_1_2, ("m_iDeaths"), unpack(returned_68_47, 1, returned_68_47.n))
            value_4_2 = value_2_2 / value_3_2
            if value_4_2 < 1.5 or value_2_2 == nil and value_3_2 == nil then
                value_4_2 = ((globals.tickcount)()) - value_110_1
                if 10 < value_4_2 then
                    value_4_2 = math.floor
                    value_5_2 = ((((globals.curtime)()) * 1) % 2) + 1
                    value_109_1 = value_4_2(value_5_2)
                    value_4_2 = client.set_clan_tag
                    value_5_2 = value_108_1[value_109_1]
                    value_4_2(value_5_2)
                    value_110_1 = (globals.tickcount)()
                end
            else
                value_4_2 = ((globals.tickcount)()) - value_110_1
                if 10 < value_4_2 then
                    value_4_2 = math.floor
                    value_5_2 = ((((globals.curtime)()) * 2) % 24) + 1
                    value_109_1 = value_4_2(value_5_2)
                    value_4_2 = client.set_clan_tag
                    value_5_2 = value_107_1[value_109_1]
                    value_4_2(value_5_2)
                    value_110_1 = (globals.tickcount)()
                end
            end
            if not value_111_1 then
                value_111_1 = true
            end
        else
            if value_111_1 then
                value_1_2 = client.delay_call
                value_1_2(0.15, clear_clan_tag)
                value_111_1 = false
            end
        end
        value_1_2 = is_alive(value_0_2)
        if not value_1_2 then
            return
        else
            value_1_2 = {
            }
            value_2_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, value_10_2, value_11_2, value_12_2, value_13_2, value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = screen_size()
            value_1_2[1] = value_2_2
            value_1_2[2] = value_3_2
            value_1_2[3] = value_4_2
            value_1_2[4] = value_5_2
            value_1_2[5] = value_6_2
            value_1_2[6] = value_7_2
            value_1_2[7] = value_8_2
            value_1_2[8] = value_9_2
            value_1_2[9] = value_10_2
            value_1_2[10] = value_11_2
            value_1_2[11] = value_12_2
            value_1_2[12] = value_13_2
            value_1_2[13] = value_14_2
            value_1_2[14] = value_15_2
            value_1_2[15] = value_16_2
            value_1_2[16] = value_17_2
            value_1_2[17] = value_18_2
            value_1_2[18] = value_19_2
            value_1_2[19] = value_20_2
            value_1_2[20] = value_21_2
            value_1_2[21] = value_22_2
            value_1_2[22] = value_23_2
            value_1_2[23] = value_24_2
            value_1_2[24] = value_25_2
            value_1_2[25] = value_26_2
            value_1_2[26] = value_27_2
            value_1_2[27] = value_28_2
            value_1_2[28] = value_29_2
            value_1_2[29] = value_30_2
            value_1_2[30] = value_31_2
            value_1_2[31] = value_32_2
            value_1_2[32] = value_33_2
            value_2_2 = {
            }
            value_3_2 = (value_1_2[1]) / 2
            value_4_2 = (value_1_2[2]) / 2
            value_2_2[1] = value_3_2
            value_2_2[2] = value_4_2
            value_4_2 = (script_controls.clr)[2]
            value_3_2, value_4_2, value_5_2, value_6_2 = ui_get(value_4_2)
            value_8_2 = (script_controls.clr2)[2]
            value_7_2, value_8_2, value_9_2, value_10_2 = ui_get(value_8_2)
            value_11_2 = ((get_prop(value_0_2, ("m_flPoseParameter"), 11)) * 120) - 60
            value_12_2 = anti_aim_state.holding_e
            if value_12_2 then
                value_12_2 = -1
                if not (value_12_2) then
                    value_12_2 = 1
                end
            else
                value_12_2 = 1
            end
            value_11_2 = value_11_2 * value_12_2
            value_12_2 = 20
            value_14_2 = script_controls.s
            value_13_2 = contains_value(value_14_2, ("AA indicator"))
            if value_13_2 then
                value_14_2 = script_controls.s
                value_13_2 = contains_value(value_14_2, ("Legacy arrows"))
                if not value_13_2 then
                    value_13_2 = {
                    }
                    value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = camera_angles()
                    value_13_2[1] = value_14_2
                    value_13_2[2] = value_15_2
                    value_13_2[3] = value_16_2
                    value_13_2[4] = value_17_2
                    value_13_2[5] = value_18_2
                    value_13_2[6] = value_19_2
                    value_13_2[7] = value_20_2
                    value_13_2[8] = value_21_2
                    value_13_2[9] = value_22_2
                    value_13_2[10] = value_23_2
                    value_13_2[11] = value_24_2
                    value_13_2[12] = value_25_2
                    value_13_2[13] = value_26_2
                    value_13_2[14] = value_27_2
                    value_13_2[15] = value_28_2
                    value_13_2[16] = value_29_2
                    value_13_2[17] = value_30_2
                    value_13_2[18] = value_31_2
                    value_13_2[19] = value_32_2
                    value_13_2[20] = value_33_2
                    value_14_2 = {
                    }
                    value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = hitbox_position(value_0_2, ("head_0"))
                    value_14_2[1] = value_15_2
                    value_14_2[2] = value_16_2
                    value_14_2[3] = value_17_2
                    value_14_2[4] = value_18_2
                    value_14_2[5] = value_19_2
                    value_14_2[6] = value_20_2
                    value_14_2[7] = value_21_2
                    value_14_2[8] = value_22_2
                    value_14_2[9] = value_23_2
                    value_14_2[10] = value_24_2
                    value_14_2[11] = value_25_2
                    value_14_2[12] = value_26_2
                    value_14_2[13] = value_27_2
                    value_14_2[14] = value_28_2
                    value_14_2[15] = value_29_2
                    value_14_2[16] = value_30_2
                    value_14_2[17] = value_31_2
                    value_14_2[18] = value_32_2
                    value_14_2[19] = value_33_2
                    value_15_2 = {
                    }
                    value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = hitbox_position(value_0_2, ("pelvis"))
                    value_15_2[1] = value_16_2
                    value_15_2[2] = value_17_2
                    value_15_2[3] = value_18_2
                    value_15_2[4] = value_19_2
                    value_15_2[5] = value_20_2
                    value_15_2[6] = value_21_2
                    value_15_2[7] = value_22_2
                    value_15_2[8] = value_23_2
                    value_15_2[9] = value_24_2
                    value_15_2[10] = value_25_2
                    value_15_2[11] = value_26_2
                    value_15_2[12] = value_27_2
                    value_15_2[13] = value_28_2
                    value_15_2[14] = value_29_2
                    value_15_2[15] = value_30_2
                    value_15_2[16] = value_31_2
                    value_15_2[17] = value_32_2
                    value_15_2[18] = value_33_2
                    value_18_2 = value_15_2[1]
                    value_19_2 = value_15_2[2]
                    value_20_2 = value_14_2[1]
                    value_21_2 = value_14_2[2]
                    value_17_2 = yaw_between_points(value_18_2, value_19_2, value_20_2, value_21_2)
                    value_18_2 = value_11_2 / 2
                    value_17_2 = value_17_2 - value_18_2
                    value_18_2 = value_13_2[2]
                    value_17_2 = (value_17_2 - value_18_2) + 120
                    value_16_2 = normalize_yaw(value_17_2)
                    value_17_2 = draw_indicator_triangle
                    value_18_2 = value_2_2[1]
                    value_19_2 = value_2_2[2]
                    value_20_2 = value_3_2
                    value_21_2 = value_4_2
                    value_22_2 = value_5_2
                    value_23_2 = value_6_2
                    value_24_2 = value_7_2
                    value_25_2 = value_8_2
                    value_26_2 = value_9_2
                    value_27_2 = 255
                    value_28_2 = value_11_2 / 1.5
                    value_28_2 = (value_16_2 + value_28_2) * -1
                    if not (value_11_2 < 0) then
                        value_30_2 = false
                    else
                        value_30_2 = true
                    end
                    draw_indicator_triangle(value_18_2, value_19_2, value_3_2, value_4_2, value_5_2, value_6_2, value_7_2, value_8_2, value_9_2, 255, value_28_2, 60, value_30_2)
                    value_12_2 = 42
                end
            end
            value_14_2 = script_controls.s
            value_13_2 = contains_value(value_14_2, ("Legacy arrows"))
            if value_13_2 then
                value_13_2 = (anti_aim_state.dir).manual
                if value_13_2 == 90 then
                    value_14_2 = (value_2_2[1]) + 60
                    value_15_2 = value_2_2[2]
                    value_22_2 = base64_module.decode
                    local returned_68_48 = __dec14_pack_results(value_22_2(("4oC6")))
                    value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = unpack(returned_68_48, 1, returned_68_48.n)
                    draw_text(value_14_2, value_15_2, value_3_2, value_4_2, value_5_2, value_6_2, ("c+"), 0, unpack(returned_68_48, 1, returned_68_48.n))
                    value_14_2 = (value_2_2[1]) - 60
                    value_15_2 = value_2_2[2]
                    value_16_2 = value_7_2
                    value_17_2 = value_8_2
                    value_18_2 = value_9_2
                    value_19_2 = value_10_2
                    value_20_2 = "c+"
                    value_21_2 = 0
                    value_22_2 = base64_module.decode
                    local returned_68_49 = __dec14_pack_results(value_22_2(("4oC5")))
                    value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = unpack(returned_68_49, 1, returned_68_49.n)
                    draw_text(value_14_2, value_15_2, value_7_2, value_8_2, value_9_2, value_10_2, ("c+"), 0, unpack(returned_68_49, 1, returned_68_49.n))
                else
                    value_13_2 = (anti_aim_state.dir).manual
                    if value_13_2 == -90 then
                        value_14_2 = (value_2_2[1]) - 60
                        value_15_2 = value_2_2[2]
                        value_22_2 = base64_module.decode
                        local returned_68_50 = __dec14_pack_results(value_22_2(("4oC5")))
                        value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = unpack(returned_68_50, 1, returned_68_50.n)
                        draw_text(value_14_2, value_15_2, value_3_2, value_4_2, value_5_2, value_6_2, ("c+"), 0, unpack(returned_68_50, 1, returned_68_50.n))
                        value_14_2 = (value_2_2[1]) + 60
                        value_15_2 = value_2_2[2]
                        value_16_2 = value_7_2
                        value_17_2 = value_8_2
                        value_18_2 = value_9_2
                        value_19_2 = value_10_2
                        value_20_2 = "c+"
                        value_21_2 = 0
                        value_22_2 = base64_module.decode
                        local returned_68_51 = __dec14_pack_results(value_22_2(("4oC6")))
                        value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = unpack(returned_68_51, 1, returned_68_51.n)
                        draw_text(value_14_2, value_15_2, value_7_2, value_8_2, value_9_2, value_10_2, ("c+"), 0, unpack(returned_68_51, 1, returned_68_51.n))
                    else
                        value_14_2 = (value_2_2[1]) - 60
                        value_15_2 = value_2_2[2]
                        value_22_2 = base64_module.decode
                        local returned_68_52 = __dec14_pack_results(value_22_2(("4oC5")))
                        value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = unpack(returned_68_52, 1, returned_68_52.n)
                        draw_text(value_14_2, value_15_2, value_7_2, value_8_2, value_9_2, value_10_2, ("c+"), 0, unpack(returned_68_52, 1, returned_68_52.n))
                        value_14_2 = (value_2_2[1]) + 60
                        value_15_2 = value_2_2[2]
                        value_16_2 = value_7_2
                        value_17_2 = value_8_2
                        value_18_2 = value_9_2
                        value_19_2 = value_10_2
                        value_20_2 = "c+"
                        value_21_2 = 0
                        value_22_2 = base64_module.decode
                        local returned_68_53 = __dec14_pack_results(value_22_2(("4oC6")))
                        value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = unpack(returned_68_53, 1, returned_68_53.n)
                        draw_text(value_14_2, value_15_2, value_7_2, value_8_2, value_9_2, value_10_2, ("c+"), 0, unpack(returned_68_53, 1, returned_68_53.n))
                    end
                end
            end
            value_14_2 = script_controls.s
            value_13_2 = contains_value(value_14_2, ("Name indicator"))
            if value_13_2 then
                value_14_2 = (value_2_2[1]) - 30
                value_15_2 = (value_2_2[2]) + 20
                value_16_2 = value_3_2 or value_16_2
                if not (0 < value_11_2) or not value_3_2 then
                    value_16_2 = value_7_2
                end
                value_17_2 = value_4_2 or value_17_2
                if not (0 < value_11_2) or not value_4_2 then
                    value_17_2 = value_8_2
                end
                value_18_2 = value_5_2 or value_18_2
                if not (0 < value_11_2) or not value_5_2 then
                    value_18_2 = value_9_2
                end
                value_19_2 = value_6_2 or value_19_2
                if not (0 < value_11_2) or not value_6_2 then
                    value_19_2 = 255
                end
                draw_text(value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, ("b"), 0, ("predi"))
                value_14_2 = (value_2_2[1]) - 4
                value_15_2 = (value_2_2[2]) + 20
                value_16_2 = value_3_2 or value_16_2
                if not (value_11_2 < 0) or not value_3_2 then
                    value_16_2 = value_7_2
                end
                value_17_2 = value_4_2 or value_17_2
                if not (value_11_2 < 0) or not value_4_2 then
                    value_17_2 = value_8_2
                end
                value_18_2 = value_5_2 or value_18_2
                if not (value_11_2 < 0) or not value_5_2 then
                    value_18_2 = value_9_2
                end
                value_19_2 = value_6_2 or value_19_2
                if not (value_11_2 < 0) or not value_6_2 then
                    value_19_2 = 255
                end
                value_20_2 = "b"
                value_21_2 = 0
                value_22_2 = "ction.lua"
                draw_text(value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, ("b"), 0, ("ction.lua"))
            end
            value_14_2 = script_controls.s
            value_13_2 = contains_value(value_14_2, ("Status Indicator"))
            if value_13_2 then
                value_13_2 = anti_aim_state.aa
                if value_13_2 == 1 then
                    value_14_2 = (value_2_2[1]) - 8
                    value_15_2 = ((value_2_2[2]) + 15) + value_12_2
                    value_17_2 = value_4_2
                    value_18_2 = value_5_2
                    value_19_2 = value_6_2 * 0.75
                    value_20_2 = "-c"
                    value_21_2 = 0
                    value_22_2 = "+/- ADAPTIVE"
                    draw_text(value_14_2, value_15_2, value_3_2, value_4_2, value_5_2, value_19_2, ("-c"), 0, ("+/- ADAPTIVE"))
                else
                    value_13_2 = anti_aim_state.aa
                    if value_13_2 == 2 then
                        value_14_2 = (value_2_2[1]) - 12
                        value_15_2 = ((value_2_2[2]) + 15) + value_12_2
                        value_17_2 = value_4_2
                        value_18_2 = value_5_2
                        value_19_2 = value_6_2 * 0.75
                        value_20_2 = "-c"
                        value_21_2 = 0
                        value_22_2 = "+/- MOVING"
                        draw_text(value_14_2, value_15_2, value_3_2, value_4_2, value_5_2, value_19_2, ("-c"), 0, ("+/- MOVING"))
                    else
                        value_13_2 = anti_aim_state.aa
                        if value_13_2 == 3 then
                            value_14_2 = (value_2_2[1]) - 4
                            value_15_2 = ((value_2_2[2]) + 15) + value_12_2
                            value_17_2 = 111
                            value_18_2 = 111
                            value_19_2 = value_6_2 * 0.75
                            value_20_2 = "-c"
                            value_21_2 = 0
                            value_22_2 = "+/- DANGEROUS"
                            draw_text(value_14_2, value_15_2, 255, 111, 111, value_19_2, ("-c"), 0, ("+/- DANGEROUS"))
                        else
                            value_13_2 = anti_aim_state.aa
                            if value_13_2 == 4 then
                                value_14_2 = (value_2_2[1]) - 21
                                value_15_2 = ((value_2_2[2]) + 15) + value_12_2
                                value_17_2 = value_4_2
                                value_18_2 = value_5_2
                                value_19_2 = value_6_2 * 0.75
                                value_20_2 = "-c"
                                value_21_2 = 0
                                value_22_2 = "+/- AIR"
                                draw_text(value_14_2, value_15_2, value_3_2, value_4_2, value_5_2, value_19_2, ("-c"), 0, ("+/- AIR"))
                            else
                                value_13_2 = anti_aim_state.aa
                                if value_13_2 == 5 then
                                    value_14_2 = (value_2_2[1]) - 20
                                    value_15_2 = ((value_2_2[2]) + 15) + value_12_2
                                    value_17_2 = value_4_2
                                    value_18_2 = value_5_2
                                    value_19_2 = value_6_2 * 0.75
                                    value_20_2 = "-c"
                                    value_21_2 = 0
                                    value_22_2 = "+/- USE"
                                    draw_text(value_14_2, value_15_2, value_3_2, value_4_2, value_5_2, value_19_2, ("-c"), 0, ("+/- USE"))
                                else
                                    value_13_2 = anti_aim_state.aa
                                    if value_13_2 == 6 then
                                        value_14_2 = (value_2_2[1]) - 9
                                        value_15_2 = ((value_2_2[2]) + 15) + value_12_2
                                        value_17_2 = value_4_2
                                        value_18_2 = value_5_2
                                        value_19_2 = value_6_2 * 0.75
                                        value_20_2 = "-c"
                                        value_21_2 = 0
                                        value_22_2 = "+/- HALFMAX"
                                        draw_text(value_14_2, value_15_2, value_3_2, value_4_2, value_5_2, value_19_2, ("-c"), 0, ("+/- HALFMAX"))
                                    else
                                        value_13_2 = anti_aim_state.aa
                                        if value_13_2 == 7 then
                                            value_14_2 = (value_2_2[1]) - 10
                                            value_15_2 = ((value_2_2[2]) + 15) + value_12_2
                                            value_17_2 = value_4_2
                                            value_18_2 = value_5_2
                                            value_19_2 = value_6_2 * 0.75
                                            value_20_2 = "-c"
                                            value_21_2 = 0
                                            value_22_2 = "+/- ABUSE 0*"
                                            draw_text(value_14_2, value_15_2, value_3_2, value_4_2, value_5_2, value_19_2, ("-c"), 0, ("+/- ABUSE 0*"))
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                value_14_2 = script_controls.s
                value_13_2 = contains_value(value_14_2, ("AA indicator"))
                if value_13_2 then
                    value_14_2 = script_controls.s
                    value_13_2 = contains_value(value_14_2, ("Legacy arrows"))
                    if not value_13_2 then
                        value_12_2 = 45
                    end
                end
            end
            value_14_2 = script_controls.s
            value_13_2 = contains_value(value_14_2, ("Legacy OG Circle"))
            if value_13_2 then
                value_14_2 = client.camera_angles
                local returned_68_54 = __dec14_pack_results(value_14_2())
                value_14_2, value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = unpack(returned_68_54, 1, returned_68_54.n)
                value_13_2 = vector_module(unpack(returned_68_54, 1, returned_68_54.n))
                value_15_2 = entity.hitbox_position
                local returned_68_55 = __dec14_pack_results(value_15_2(value_0_2, ("head_0")))
                value_15_2, value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = unpack(returned_68_55, 1, returned_68_55.n)
                value_14_2 = vector_module(unpack(returned_68_55, 1, returned_68_55.n))
                value_16_2 = entity.hitbox_position
                local returned_68_56 = __dec14_pack_results(value_16_2(value_0_2, ("pelvis")))
                value_16_2, value_17_2, value_18_2, value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, value_25_2, value_26_2, value_27_2, value_28_2, value_29_2, value_30_2, value_31_2, value_32_2, value_33_2 = unpack(returned_68_56, 1, returned_68_56.n)
                value_15_2 = vector_module(unpack(returned_68_56, 1, returned_68_56.n))
                value_18_2 = value_15_2.x
                value_19_2 = value_15_2.y
                value_20_2 = value_14_2.x
                value_21_2 = value_14_2.y
                value_17_2 = yaw_between_points(value_18_2, value_19_2, value_20_2, value_21_2)
                value_18_2 = value_13_2.y
                value_17_2 = (value_17_2 - value_18_2) + 120
                value_16_2 = normalize_yaw(value_17_2)
                value_17_2 = (entity.get_prop)(value_0_2, ("m_flPoseParameter"), 11)
                value_18_2 = value_17_2 * 120
                value_17_2 = value_18_2 - 60
                value_19_2 = value_16_2 + value_17_2
                value_18_2 = normalize_yaw(value_19_2)
                value_19_2 = ((math.abs)(value_17_2)) / 60
                value_20_2, value_21_2, value_22_2 = scale_factor(value_19_2)
                value_24_2 = value_2_2[1]
                value_25_2 = value_2_2[2]
                value_30_2 = value_17_2 / 60
                draw_circle_indicator(value_24_2, value_25_2, value_20_2, value_21_2, value_22_2, 255, value_30_2)
                value_23_2 = renderer.circle_outline
                value_24_2 = value_2_2[1]
                value_25_2 = value_2_2[2]
                value_26_2 = value_20_2
                value_27_2 = value_21_2
                value_31_2 = (value_16_2 * -1) - 15
                value_23_2(value_24_2, value_25_2, value_20_2, value_21_2, value_22_2, 255, 18, value_31_2, 0.2, 4)
            end
            value_14_2 = script_controls.s
            value_13_2 = contains_value(value_14_2, ("Keybind indicator"))
            if value_13_2 then
                value_13_2 = {
                }
                value_15_2 = script_controls.k
                value_14_2 = contains_value(value_15_2, ("Double tap"))
                if value_14_2 then
                    value_14_2 = (#value_13_2) + 1
                    value_15_2 = {
                    }
                    value_15_2.t = "DT"
                    value_17_2 = (native_controls.dt)[1]
                    value_16_2 = ui_get(value_17_2)
                    if value_16_2 then
                        value_17_2 = (native_controls.dt)[2]
                        value_16_2 = ui_get(value_17_2)
                    end
                    value_15_2.e = value_16_2
                    value_13_2[value_14_2] = value_15_2
                end
                value_15_2 = script_controls.k
                value_14_2 = contains_value(value_15_2, ("Onshot Anti-Aim"))
                if value_14_2 then
                    value_14_2 = (#value_13_2) + 1
                    value_15_2 = {
                    }
                    value_15_2.t = "OS"
                    value_17_2 = (native_controls.os)[1]
                    value_16_2 = ui_get(value_17_2)
                    if value_16_2 then
                        value_17_2 = (native_controls.os)[2]
                        value_16_2 = ui_get(value_17_2)
                    end
                    value_15_2.e = value_16_2
                    value_13_2[value_14_2] = value_15_2
                end
                value_15_2 = script_controls.k
                value_14_2 = contains_value(value_15_2, ("Force body aim"))
                if value_14_2 then
                    value_14_2 = (#value_13_2) + 1
                    value_15_2 = {
                    }
                    value_15_2.t = "FB"
                    value_17_2 = native_controls.forcebaim
                    value_15_2.e = ui_get(value_17_2)
                    value_13_2[value_14_2] = value_15_2
                end
                value_15_2 = script_controls.k
                value_14_2 = contains_value(value_15_2, ("Force safe point"))
                if value_14_2 then
                    value_14_2 = (#value_13_2) + 1
                    value_15_2 = {
                    }
                    value_15_2.t = "SP"
                    value_17_2 = native_controls.safepoint
                    value_15_2.e = ui_get(value_17_2)
                    value_13_2[value_14_2] = value_15_2
                end
                value_15_2 = script_controls.k
                value_14_2 = contains_value(value_15_2, ("Edge yaw"))
                if value_14_2 then
                    value_14_2 = (#value_13_2) + 1
                    value_15_2 = {
                    }
                    value_15_2.t = "EY"
                    value_17_2 = native_controls.edgeyaw
                    value_15_2.e = ui_get(value_17_2)
                    value_13_2[value_14_2] = value_15_2
                end
                value_15_2 = script_controls.k
                value_14_2 = contains_value(value_15_2, ("Freestanding"))
                if value_14_2 then
                    value_14_2 = (#value_13_2) + 1
                    value_15_2 = {
                    }
                    value_15_2.t = "FS"
                    value_17_2 = (native_controls.freestand)[1]
                    value_18_2 = "Default"
                    local freestanding_state = ui_get(value_17_2)
                    if type_alias(freestanding_state) == 'boolean' then
                        value_16_2 = freestanding_state
                    else
                        value_16_2 = contains_value(freestanding_state, 'Default')
                    end
                    if value_16_2 then
                        value_17_2 = (native_controls.freestand)[2]
                        value_16_2 = ui_get(value_17_2)
                    end
                    value_15_2.e = value_16_2
                    value_13_2[value_14_2] = value_15_2
                end
                value_15_2 = script_controls.k
                value_14_2 = contains_value(value_15_2, ("Quick peek"))
                if value_14_2 then
                    value_14_2 = (#value_13_2) + 1
                    value_15_2 = {
                    }
                    value_15_2.t = "QP"
                    value_17_2 = (native_controls.quickpeek)[1]
                    value_16_2 = ui_get(value_17_2)
                    if value_16_2 then
                        value_17_2 = (native_controls.quickpeek)[2]
                        value_16_2 = ui_get(value_17_2)
                    end
                    value_15_2.e = value_16_2
                    value_13_2[value_14_2] = value_15_2
                end
                value_15_2 = script_controls.s
                value_14_2 = contains_value(value_15_2, ("Status Indicator"))
                if value_14_2 then
                    value_15_2 = #value_13_2
                    for value_17_2 = 1, value_15_2, 1 do
                        value_18_2 = draw_text
                        value_19_2 = (value_2_2[1]) - 30
                        value_20_2 = ((value_2_2[2]) + value_12_2) + 10
                        value_21_2 = value_17_2 * 8
                        value_20_2 = value_20_2 + value_21_2
                        value_21_2 = (value_13_2[value_17_2]).e
                        value_21_2 = value_3_2 or value_21_2
                        if not value_21_2 or not value_3_2 then
                            value_21_2 = value_7_2
                        end
                        value_22_2 = (value_13_2[value_17_2]).e
                        value_22_2 = value_4_2 or value_22_2
                        if not value_22_2 or not value_4_2 then
                            value_22_2 = value_8_2
                        end
                        value_23_2 = (value_13_2[value_17_2]).e
                        value_23_2 = value_5_2 or value_23_2
                        if not value_23_2 or not value_5_2 then
                            value_23_2 = value_9_2
                        end
                        value_24_2 = (value_13_2[value_17_2]).e
                        value_24_2 = value_6_2 or value_24_2
                        if not value_24_2 or not value_6_2 then
                            value_24_2 = value_10_2 * 0.75
                        end
                        value_25_2 = "-"
                        value_26_2 = 0
                        value_27_2 = (value_13_2[value_17_2]).t
                        draw_text(value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, ("-"), 0, value_27_2)
                    end
                else
                    value_15_2 = #value_13_2
                    for value_17_2 = 1, value_15_2, 1 do
                        value_18_2 = draw_text
                        value_19_2 = (value_2_2[1]) - 1
                        value_20_2 = ((value_2_2[2]) + value_12_2) + 7
                        value_21_2 = value_17_2 * 8
                        value_20_2 = value_20_2 + value_21_2
                        value_21_2 = (value_13_2[value_17_2]).e
                        value_21_2 = value_3_2 or value_21_2
                        if not value_21_2 or not value_3_2 then
                            value_21_2 = value_7_2
                        end
                        value_22_2 = (value_13_2[value_17_2]).e
                        value_22_2 = value_4_2 or value_22_2
                        if not value_22_2 or not value_4_2 then
                            value_22_2 = value_8_2
                        end
                        value_23_2 = (value_13_2[value_17_2]).e
                        value_23_2 = value_5_2 or value_23_2
                        if not value_23_2 or not value_5_2 then
                            value_23_2 = value_9_2
                        end
                        value_24_2 = (value_13_2[value_17_2]).e
                        value_24_2 = value_6_2 or value_24_2
                        if not value_24_2 or not value_6_2 then
                            value_24_2 = value_10_2 * 0.75
                        end
                        value_25_2 = "c-"
                        value_26_2 = 0
                        value_27_2 = (value_13_2[value_17_2]).t
                        draw_text(value_19_2, value_20_2, value_21_2, value_22_2, value_23_2, value_24_2, ("c-"), 0, value_27_2)
                    end
                end
            end
        end
    end
    update_ui_visibility = function(...)
        local value_1_2, value_2_2, value_3_2, value_4_2
        value_1_2 = script_controls.la
        value_3_2 = script_controls.s
        local returned_69_57 = __dec14_pack_results(contains_value(value_3_2, ("Custom Legit AA")))
        value_2_2, value_3_2, value_4_2 = unpack(returned_69_57, 1, returned_69_57.n)
        ui_set_visible(value_1_2, unpack(returned_69_57, 1, returned_69_57.n))
        value_1_2 = script_controls.ml
        value_3_2 = script_controls.s
        local returned_69_58 = __dec14_pack_results(contains_value(value_3_2, ("Manual AA")))
        value_2_2, value_3_2, value_4_2 = unpack(returned_69_58, 1, returned_69_58.n)
        ui_set_visible(value_1_2, unpack(returned_69_58, 1, returned_69_58.n))
        value_1_2 = script_controls.mr
        value_3_2 = script_controls.s
        local returned_69_59 = __dec14_pack_results(contains_value(value_3_2, ("Manual AA")))
        value_2_2, value_3_2, value_4_2 = unpack(returned_69_59, 1, returned_69_59.n)
        ui_set_visible(value_1_2, unpack(returned_69_59, 1, returned_69_59.n))
        value_1_2 = script_controls.mf
        value_3_2 = script_controls.s
        local returned_69_60 = __dec14_pack_results(contains_value(value_3_2, ("Manual AA")))
        value_2_2, value_3_2, value_4_2 = unpack(returned_69_60, 1, returned_69_60.n)
        ui_set_visible(value_1_2, unpack(returned_69_60, 1, returned_69_60.n))
        value_1_2 = script_controls.fs
        value_3_2 = script_controls.s
        local returned_69_61 = __dec14_pack_results(contains_value(value_3_2, ("Freestanding")))
        value_2_2, value_3_2, value_4_2 = unpack(returned_69_61, 1, returned_69_61.n)
        ui_set_visible(value_1_2, unpack(returned_69_61, 1, returned_69_61.n))
        value_1_2 = script_controls.ey
        value_3_2 = script_controls.s
        local returned_69_62 = __dec14_pack_results(contains_value(value_3_2, ("Edge yaw")))
        value_2_2, value_3_2, value_4_2 = unpack(returned_69_62, 1, returned_69_62.n)
        ui_set_visible(value_1_2, unpack(returned_69_62, 1, returned_69_62.n))
        value_1_2 = script_controls.k
        value_3_2 = script_controls.s
        local returned_69_63 = __dec14_pack_results(contains_value(value_3_2, ("Keybind indicator")))
        value_2_2, value_3_2, value_4_2 = unpack(returned_69_63, 1, returned_69_63.n)
        ui_set_visible(value_1_2, unpack(returned_69_63, 1, returned_69_63.n))
        value_1_2 = (script_controls.clr)[1]
        value_3_2 = script_controls.s
        value_2_2 = contains_value(value_3_2, ("AA indicator"))
        if not value_2_2 then
            value_3_2 = script_controls.s
            value_2_2 = contains_value(value_3_2, ("Keybind indicator"))
            if not value_2_2 then
                value_3_2 = script_controls.s
                value_2_2 = contains_value(value_3_2, ("Name indicator"))
            end
        end
        ui_set_visible(value_1_2, value_2_2)
        value_1_2 = (script_controls.clr)[2]
        value_3_2 = script_controls.s
        value_2_2 = contains_value(value_3_2, ("AA indicator"))
        if not value_2_2 then
            value_3_2 = script_controls.s
            value_2_2 = contains_value(value_3_2, ("Keybind indicator"))
            if not value_2_2 then
                value_3_2 = script_controls.s
                value_2_2 = contains_value(value_3_2, ("Name indicator"))
            end
        end
        ui_set_visible(value_1_2, value_2_2)
        value_1_2 = (script_controls.clr2)[1]
        value_3_2 = script_controls.s
        value_2_2 = contains_value(value_3_2, ("AA indicator"))
        if not value_2_2 then
            value_3_2 = script_controls.s
            value_2_2 = contains_value(value_3_2, ("Keybind indicator"))
            if not value_2_2 then
                value_3_2 = script_controls.s
                value_2_2 = contains_value(value_3_2, ("Name indicator"))
            end
        end
        ui_set_visible(value_1_2, value_2_2)
        value_1_2 = (script_controls.clr2)[2]
        value_3_2 = script_controls.s
        value_2_2 = contains_value(value_3_2, ("AA indicator"))
        if not value_2_2 then
            value_3_2 = script_controls.s
            value_2_2 = contains_value(value_3_2, ("Keybind indicator"))
            if not value_2_2 then
                value_3_2 = script_controls.s
                value_2_2 = contains_value(value_3_2, ("Name indicator"))
            end
        end
        ui_set_visible(value_1_2, value_2_2)
        set_native_ui_visible(false)
    end
    whitelisted = false
    panorama_api = (panorama[("open")])()
    register_events_if_whitelisted = function(...)
        local value_0_2, value_1_2, value_2_2
        if not whitelisted then
            value_0_2 = client.set_event_callback
            value_2_2 = function(...)
                local value_0_3
                value_0_3 = renderer.indicator
                value_0_3(255, 0, 0, 255, ("[amgis corporations] prediction not whitelisted on this account - check console"))
            end
            value_0_2(("paint_ui"), value_2_2)
            steam = ((panorama_api.MyPersonaAPI).GetXuid)()
            value_0_2 = client.log
            value_1_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..steam
            value_0_2(value_1_2)
            value_0_2 = client.log
            value_1_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..steam
            value_0_2(value_1_2)
            value_0_2 = client.log
            value_1_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..steam
            value_0_2(value_1_2)
            value_0_2 = client.log
            value_1_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..steam
            value_0_2(value_1_2)
            value_0_2 = client.log
            value_1_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..steam
            value_0_2(value_1_2)
            value_0_2 = client.log
            value_1_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..steam
            value_0_2(value_1_2)
            value_0_2 = client.log
            value_1_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..steam
            value_0_2(value_1_2)
            value_0_2 = client.log
            value_1_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..steam
            value_0_2(value_1_2)
            return
        end
        value_0_2 = client.log
        value_0_2(("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!"))
        value_0_2 = client.log
        value_0_2(("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!"))
        value_0_2 = client.log
        value_0_2(("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!"))
        value_0_2 = client.log
        value_0_2(("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!"))
        update_ui_visibility()
        value_1_2 = script_controls.s
        ui_set_callback(value_1_2, update_ui_visibility)
        set_event_callback(("shutdown"), set_native_ui_visible)
        set_event_callback(("paint"), draw_indicators)
        set_event_callback(("bullet_impact"), on_bullet_impact)
        set_event_callback(("player_hurt"), on_player_hurt)
        set_event_callback(("setup_command"), apply_body_yaw)
        set_event_callback(("player_spawn"), on_player_spawn)
        set_event_callback(("client_disconnect"), reset_player_state)
        set_event_callback(("cs_game_disconnected"), reset_player_state)
        set_event_callback(("game_newmap"), reset_player_state)
    end
    request_whitelist = function(...)
        local value_0_2, value_1_2, value_2_2, value_3_2, value_4_2
        value_0_2 = http_module.get
        value_1_2 = string.format
        value_3_2 = (database.read)(("prediction_auth"))
        if not value_3_2 then
            value_3_2 = ""
        end
        value_4_2 = ((panorama_api.MyPersonaAPI).GetXuid)()
        value_1_2 = value_1_2(("https://gs.shav.it/check?auth=%s&id=%s"), value_3_2, value_4_2)
        value_2_2 = function(argument_0_3, argument_1_3, ...)
            local value_2_3, value_4_3
            if not argument_0_3 then
                return
            else
                value_2_3 = argument_1_3.status
                if value_2_3 ~= 200 then
                    value_2_3 = argument_1_3.status
                    if not (value_2_3 ~= 201) then
                        whitelisted = true
                    end
                else
                    whitelisted = true
                end
                value_2_3 = argument_1_3.status
                if value_2_3 == 201 then
                    value_2_3 = database.write
                    value_4_3 = argument_1_3.body
                    value_2_3(("prediction_auth"), value_4_3)
                end
                register_events_if_whitelisted()
            end
        end
        value_0_2(value_1_2, value_2_2)
        return false
    end
    request_whitelist()
    screen_dimensions = {
    }
    screen_center = client.screen_size
    screen_center, draw_branding, value_123_1, value_124_1, value_125_1, value_126_1, value_127_1, value_128_1, value_129_1, value_130_1, value_131_1, value_132_1, value_133_1, value_134_1, value_135_1 = screen_center()
    screen_dimensions[1] = screen_center
    screen_dimensions[2] = draw_branding
    screen_dimensions[3] = value_123_1
    screen_dimensions[4] = value_124_1
    screen_dimensions[5] = value_125_1
    screen_dimensions[6] = value_126_1
    screen_dimensions[7] = value_127_1
    screen_dimensions[8] = value_128_1
    screen_dimensions[9] = value_129_1
    screen_dimensions[10] = value_130_1
    screen_dimensions[11] = value_131_1
    screen_dimensions[12] = value_132_1
    screen_dimensions[13] = value_133_1
    screen_dimensions[14] = value_134_1
    screen_dimensions[15] = value_135_1
    screen_center = {
    }
    draw_branding = (screen_dimensions[1]) / 2
    value_123_1 = (screen_dimensions[2]) / 2
    screen_center[1] = draw_branding
    screen_center[2] = value_123_1
    draw_branding = function(...)
        local value_0_2, value_1_2
        value_0_2 = renderer.text
        value_1_2 = (screen_dimensions[1]) - 92
        value_0_2(value_1_2, 0, 255, 255, 255, 255, nil, 0, ("shoppy.gg/"))
        value_0_2 = renderer.text
        value_1_2 = (screen_dimensions[1]) - 40
        value_0_2(value_1_2, 0, 50, 255, 50, 255, nil, 0, ("@amgis"))
    end
    value_123_1 = client.set_event_callback
    value_123_1(("paint"), draw_branding)
end
return main(...)
