-- Sauron resolver for GameSense / CS:GO.
-- Recovered from the supplied PSU-protected file. Names and comments are inferred.
-- Menu: RAGE / Other. Dependencies: gamesense/csgo_weapons, vector.

local function main(...)
    -- Cache the same API functions as the original script.
    local color_log = client.color_log
    local eye_position = client.eye_position
    local random_int = client.random_int
    local register_esp_flag = client.register_esp_flag
    local screen_size = client.screen_size
    local set_event_callback = client.set_event_callback
    local unset_event_callback = client.unset_event_callback
    local trace_bullet = client.trace_bullet
    local update_player_list = client.update_player_list
    local userid_to_entindex = client.userid_to_entindex
    local get_local_player = entity.get_local_player
    local get_player_weapon = entity.get_player_weapon
    local get_players = entity.get_players
    local get_prop = entity.get_prop
    local hitbox_position = entity.hitbox_position
    local frametime = globals.frametime
    local atan, cos, floor = math.atan, math.cos, math.floor
    local max, min, rad = math.max, math.min, math.rad
    local sin, sqrt = math.sin, math.sqrt
    local plist_get, plist_set = plist.get, plist.set
    local draw_line = renderer.line
    local measure_text = renderer.measure_text
    local draw_rectangle = renderer.rectangle
    local draw_text = renderer.text
    local world_to_screen = renderer.world_to_screen
    local table_remove, to_number = table.remove, tonumber
    local require_module, pairs_iter = require, pairs
    local ui_get, ui_name = ui.get, ui.name
    local print_message = print
    local ui_set_callback, ui_set_visible = ui.set_callback, ui.set_visible

    -- Notifications retain the original lifetime, fade and callback timing.
    if not _G.sauron_notify_cache then
        _G.sauron_notify_cache = {}
    end
    local notifications = {callback_registered = false, maximum_count = 7}

    function notifications:register_callback(...)
        if self.callback_registered then return end
        set_event_callback("paint_ui", function(...)
            local width, height = screen_size()
            local cache = _G.sauron_notify_cache
            local vertical_offset = 5
            for index = #cache, 1, -1 do
                local entry = _G.sauron_notify_cache[index]
                entry.time = entry.time - frametime()
                local alpha, fade = 255, 0
                entry = cache[index]
                if entry.time < 0 then
                    table_remove(_G.sauron_notify_cache, index)
                else
                    local elapsed = entry.def_time - entry.time
                    local fade_in = elapsed > 1 and 1 or elapsed
                    if entry.time < 0.5 or fade_in < 0.5 then
                        local fade_time = fade_in < 1 and fade_in or entry.time
                        fade = fade_time / 0.5
                        alpha = fade * 255
                        if fade < 0.2 then
                            vertical_offset = vertical_offset + 15 * (1 - fade / 0.2)
                        end
                    end
                    local box_width = floor(measure_text(nil, "[sauron] " .. entry.draw) * 1.1)
                    local brand_width = measure_text(nil, "[sauron]")
                    local message_width = measure_text(nil, entry.draw)
                    local x = width / 2 - box_width / 2 + 3
                    local y = height - (height / 100) * 17.4 + vertical_offset
                    local background_alpha = alpha > 155 and 155 or alpha
                    draw_rectangle(x, y - 20, box_width, 40, 0, 0, 0, background_alpha)
                    draw_line(x, y - 19, x + box_width, y - 19, 255, 0, 0, background_alpha)
                    draw_text(x + box_width / 2 - message_width / 2, y,
                        255, 0, 0, alpha, "c", nil, "[sauron] ")
                    draw_text(x + box_width / 2 + brand_width / 2, y,
                        255, 255, 255, alpha, "c", nil, entry.draw)
                    vertical_offset = vertical_offset - 50
                end
            end
            self.callback_registered = true
        end)
    end

    function notifications:paint(duration, message, ...)
        local lifetime = to_number(duration) + 1
        for index = self.maximum_count, 2, -1 do
            _G.sauron_notify_cache[index] = _G.sauron_notify_cache[index - 1]
        end
        _G.sauron_notify_cache[1] = {time = lifetime, def_time = lifetime, draw = message}
        self:register_callback()
    end

    local weapon_data = require_module("gamesense/csgo_weapons")
    local vector_constructor = require_module("vector")
    local menu = {location = {"Rage", "Other"}, name = "[sauron beta] ", id = 100, debug = true}
    local yaw_presets = {
        default = {44, -44, 0},
        stand = {44, -17, 15},
        slow = {44, -17, 15},
    }
    local stage_defaults = {default = 0, stand = 0, slow = 15}
    local player_state, player_history = {}, {}

    local function remember_ui_references(references, ...)
        if not _G.sauron_reference then _G.sauron_reference = {} end
        for key, handle in pairs_iter(references) do
            if not key then break end
            local name, extra = ui_name(handle)
            _G.sauron_reference[menu.id] = {menu.location[1], menu.location[2], name, extra}
            menu.id = menu.id + 1
        end
    end

    local function log_message(message, ...)
        color_log(255, 0, 21, "[sauron]\000")
        color_log(245, 245, 245, " ", message)
    end

    function menu:create(constructor, name, ...)
        if constructor == nil then return end
        return constructor(self.location[1], self.location[2], self.name .. name, ...)
    end
    local controls = {}
    controls.enabled = menu:create(ui.new_checkbox, "Enhanced resolver")
    controls.weapons = menu:create(ui.new_checkbox, "Adaptive weapons")
    controls.weapons_list = menu:create(ui.new_multiselect, "Active Weapons",
        "Scout", "Auto", "Revolver", "Deagle", "Pistols", "SMG", "Rifles")
    remember_ui_references(controls)

    -- Transient state resets each round; learned sides survive until reconnect.
    local function reset_player_state(reset_history, ...)
        for player = 1, 64 do
            player_state[player] = {
                active = false, stage = "default", delta = 0, shots = 0,
                slow = false, last_vel = 0, tick_to = 0,
            }
        end
        if reset_history then
            for player = 1, 64 do
                local history = {side = {}, res_side = {}, resolved = {}, best_sides = {}}
                player_history[player] = history
                for stage, value in pairs_iter(stage_defaults) do
                    if not stage then break end
                    history.side[stage] = value
                end
                for stage, value in pairs_iter(stage_defaults) do
                    if not stage then break end
                    history.res_side[stage] = value
                end
                for stage in pairs_iter(stage_defaults) do
                    if not stage then break end
                    history.resolved[stage] = false
                end
                for stage in pairs_iter(stage_defaults) do
                    if not stage then break end
                    history.best_sides[stage] = {}
                end
            end
        end
    end
    reset_player_state(true)

    local function on_player_death(event, ...)
        if userid_to_entindex(event.userid) ~= get_local_player() then return end
        reset_player_state()
        notifications:paint(5, "Reseted data due to death")
    end
    local function on_round_start(...)
        reset_player_state()
        notifications:paint(5, "Reseted data due to round start")
    end
    local function on_player_connect(event, ...)
        if userid_to_entindex(event.userid) == get_local_player() then
            reset_player_state(true)
            notifications:paint(5, "Reseted data due to connect")
        end
    end

    local function round_number(value, precision, ...)
        local scale = 10 ^ (precision or 0)
        return floor(value * scale + 0.5) / scale
    end

    local function weapon_is_selected(...)
        if not ui_get(controls.weapons) then return true end
        local weapon = get_player_weapon(get_local_player())
        if weapon == nil then return end
        local info = weapon_data(weapon)
        if info == nil then return end
        local selected = ui_get(controls.weapons_list)
        local matches
        for index = 1, #selected do
            local weapon_names = {[40] = "Scout", [11] = "Auto", [38] = "Auto", [64] = "Revolver", [1] = "Deagle"}
            local category_names = {pistol = "Pistols", smg = "SMG", rifle = "Rifles"}
            matches = weapon_names[info.idx] == selected[index]
                or category_names[info.type] == selected[index]
            if matches then break end
        end
        return matches
    end

    local function contains(values, wanted, ...)
        if values == nil then return false end
        for index = 1, #values do
            if values[index] == wanted then return true end
        end
        return false
    end

    local function select_preset_yaw(delta, player, alternate, ...)
        local index
        if delta >= 0 and delta < 16 then index = alternate and 1 or 3
        elseif delta > 0 then index = alternate and 2 or 1
        elseif delta < 0 then index = alternate and 3 or 2
        else index = false end
        return yaw_presets[player_state[player].stage][index]
    end

    local function normalize_yaw(yaw, ...)
        yaw = ((yaw % 360) + 360) % 360
        if yaw > 180 then return yaw - 360 end
        return yaw
    end
    local function yaw_between_points(from_x, from_y, to_x, to_y, ...)
        local delta_y, delta_x = from_y - to_y, from_x - to_x
        local yaw = normalize_yaw(atan(delta_y / delta_x) * 180 / math.pi)
        if delta_x >= 0 then yaw = normalize_yaw(yaw + 180) end
        return yaw
    end

    -- Probe the head centre and six axial offsets; retain the first positive damage.
    local function trace_hitbox_offsets(shooter, target, start_x, start_y, start_z, ...)
        local x, y, z = hitbox_position(target, 0)
        local points = {
            {x, y, z}, {x + 40, y, z}, {x, y + 40, z},
            {x - 40, y, z}, {x, y - 40, z}, {x, y, z + 40}, {x, y, z - 40},
        }
        for index = 1, 7 do
            local point = points[index]
            local hit_entity, damage = trace_bullet(shooter, start_x, start_y, start_z,
                point[1], point[2], point[3], true)
            if damage > 0 then return damage end
        end
        return 0
    end
    local function angles_to_direction(pitch, yaw, ...)
        pitch, yaw = rad(pitch), rad(yaw)
        local pitch_sine, pitch_cosine = sin(pitch), cos(pitch)
        local yaw_sine, yaw_cosine = sin(yaw), cos(yaw)
        return pitch_cosine * yaw_cosine, pitch_cosine * yaw_sine, -pitch_sine
    end

    local function classify_movement(player, ...)
        local velocity_x, velocity_y = entity.get_prop(player, "m_vecVelocity")
        local speed = math.floor(math.min(10000, math.sqrt(velocity_x ^ 2 + velocity_y ^ 2) + 0.5))
        local flags = entity.get_prop(player, "m_fFlags")
        local duck_amount = entity.get_prop(player, "m_flDuckAmount")
        local slow = speed > 3 and speed < 85 and duck_amount == 0 and bit.band(flags, 1) == 1
        local state = player_state[player]
        if not slow then
            state.stage = speed < 5 and "stand" or "default"
            return
        end
        if state.tick_to > globals.tickcount() then
            for tolerance = -3, 3 do
                if state.last_vel + tolerance == speed then return end
                if tolerance == 3 then state.tick_to = 0 end
            end
        end
        if state.tick_to == globals.tickcount() then state.stage = "slow" end
        state.tick_to = globals.tickcount() + 16
        state.last_vel = speed
    end

    local function same_side_of_threshold(first, second, threshold, ...)
        if first > threshold and second > threshold and first then return first end
        if first < threshold and second < threshold then return first end
        return false
    end

    local function on_setup_command(...)
        local enemies = get_players(true)
        for index = 1, #enemies do
            local player = enemies[index]
            if not weapon_is_selected() then
                player_state[player].active = false
                plist_set(player, "Force body yaw", false)
                return
            end
            local local_player = get_local_player()
            local eye = vector_constructor(eye_position())
            local head = vector_constructor(hitbox_position(player, 0))
            local facing = vector_constructor(0, yaw_between_points(eye.x, eye.y, head.x, head.y), 0)
            local left_direction = vector_constructor(angles_to_direction(facing.x, facing.y + 90))
            local left = vector_constructor(eye.x + left_direction.x * 100, eye.y + left_direction.y * 100)
            local right_direction = vector_constructor(angles_to_direction(facing.x, facing.y - 90))
            local right = vector_constructor(eye.x + right_direction.x * 100, eye.y + right_direction.y * 100)
            local left_damage = trace_hitbox_offsets(local_player, player, left.x, left.y, eye.z)
            local right_damage = trace_hitbox_offsets(local_player, player, right.x, right.y, eye.z)
            local state, history = player_state[player], player_history[player]
            state.active = state.shots > 0 or left_damage > 0 or right_damage > 0
            local pose = get_prop(player, "m_flPoseParameter", 11) or 0
            state.delta = max(-60, min(60, round_number(pose * 120 - 60 + 0.5, 1)))
            classify_movement(player)
            local stage = state.stage
            if state.shots == 0 then
                if stage == "slow" then
                    history.side[stage] = history.resolved[stage] and history.res_side[stage] or history.side[stage]
                else
                    history.side[stage] = history.resolved[stage] and history.res_side[stage]
                        or select_preset_yaw(state.delta, player)
                end
            end
            plist_set(player, "Force body yaw", state.active)
            plist_set(player, "Force body yaw value", history.side[stage])
            client.update_player_list()
        end
    end

    local function on_aim_hit(event, ...)
        local state, history = player_state[event.target], player_history[event.target]
        if state.active then
            local stage = state.stage
            history.resolved[stage] = event.hitgroup == 1
            if history.resolved[stage] then history.res_side[stage] = history.side[stage] end
            print_message("Hit in ", state.delta, ", delta ", history.side[stage],
                " side, stage: ", state.stage, ", misses: ", state.shots)
        else
            print_message("Hit in ", state.delta, " with skeet resolver")
        end
    end
    local function on_aim_miss(event, ...)
        if event.reason == "?" then
            local state, history = player_state[event.target], player_history[event.target]
            if state.active then
                local stage = state.stage
                state.shots = state.shots + 1
                history.side[stage] = select_preset_yaw(history.side[stage], event.target, true)
                if menu.debug then
                    print_message(string.format("Missed in %s delta, side: %s, stage: %s, was resolved: %s",
                        state.delta, history.side[stage], state.stage, history.resolved[stage]))
                    print_message("Shots count: ", state.shots)
                end
                history.resolved[stage] = false
            else
                print_message("Missed in ", state.delta, " with skeet resolver")
            end
        end
    end

    local function update_callbacks(...)
        local enabled = ui_get(controls.enabled)
        local weapon_filter_visible = ui_get(controls.enabled)
        if weapon_filter_visible then weapon_filter_visible = ui_get(controls.weapons) end
        local bind = enabled and set_event_callback or unset_event_callback
        ui_set_visible(controls.weapons, enabled)
        ui_set_visible(controls.weapons_list, weapon_filter_visible)
        bind("setup_command", on_setup_command)
        bind("aim_miss", on_aim_miss)
        bind("aim_hit", on_aim_hit)
        bind("round_start", on_round_start)
        bind("player_death", on_player_death)
        bind("player_connect_full", on_player_connect)
    end
    update_callbacks()
    ui_set_callback(controls.enabled, update_callbacks)
    ui_set_callback(controls.weapons, update_callbacks)

    register_esp_flag("RESOLVING", 255, 205, 41, function(player, ...)
        return player_state[player].active and not player_history[player].resolved[player_state[player].stage]
    end)
    register_esp_flag("RESOLVED", 0, 255, 115, function(player, ...)
        local state = player_state[player]
        local resolved = player_history[player].resolved[state.stage]
        local text = state.active
        if text then text = string.format("RESOLVED %s", string.upper(state.stage)) end
        return resolved, text
    end)
    register_esp_flag("SLOW", 20, 255, 243, function(player, ...)
        return player_state[player].active and player_state[player].stage == "slow"
    end)
    register_esp_flag("0", 255, 255, 255, function(player, ...)
        local velocity_x, velocity_y = get_prop(player, "m_vecVelocity")
        local speed = floor(min(10000, sqrt(velocity_x ^ 2 + velocity_y ^ 2) + 0.5))
        local pose = get_prop(player, "m_flPoseParameter", 11) or 0
        local delta = max(-60, min(60, round_number(pose * 120 - 60 + 0.5, 1)))
        return true, string.format("%s (%s) [%s]", delta,
            player_history[player].side[player_state[player].stage], speed)
    end)
end
return main(...)
