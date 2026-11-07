-- Reconstructed complete Lua; names are inferred. See README_FULL_RU.txt.
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
    local indicator_dimensions, choked_commands, is_mouse_in_rectangle, drag_origin_x, drag_origin_y, indicator_alpha, indicator_scale, indicator_dragging, unused_callback, crouching_ct_fake_yaw, value_118, value_119
    local value_120
    return_varargs = function(...)
        return ...
    end
    -- Original padding: builds unused text and advances the random generator.
    -- Kept separate from the real GameSense API bindings below.
    do
        local padding_words = new_table(45)
        padding_words[1] = "DefaultChatSystemChatEvents"
        padding_words[2] = "secrun"
        padding_words[3] = "is_beta"
        padding_words[4] = "secure_call"
        padding_words[5] = "cache_replace"
        padding_words[6] = "get_thread_identity"
        padding_words[7] = "request"
        padding_words[8] = "protect_gui"
        padding_words[9] = "run_secure_lua"
        padding_words[10] = "cache_invalidate"
        padding_words[11] = "queue_on_teleport"
        padding_words[12] = "is_cached"
        padding_words[13] = "set_thread_identity"
        padding_words[14] = "write_clipboard"
        padding_words[15] = "run_secure_function"
        padding_words[16] = "crypto"
        padding_words[17] = "websocket"
        padding_words[18] = "unprotect_gui"
        padding_words[19] = "create_secure_function"
        padding_words[20] = "crypt"
        padding_words[21] = "syn"
        padding_words[22] = "request"
        padding_words[23] = "SayMessageRequest"
        padding_words[24] = "FireServer"
        padding_words[25] = "InvokeServer"
        padding_words[26] = "tick"
        padding_words[27] = "pcall"
        padding_words[28] = "spawn"
        padding_words[29] = "print"
        padding_words[30] = "warn"
        padding_words[31] = "game"
        padding_words[32] = "GetService"
        padding_words[33] = "getgc"
        padding_words[34] = "getreg"
        padding_words[35] = "getrenv"
        padding_words[36] = "getgenv"
        padding_words[37] = "debug"
        padding_words[38] = "require"
        padding_words[39] = "ModuleScript"
        padding_words[40] = "LocalScript"
        padding_words[41] = "GetChildren"
        padding_words[42] = "GetDescendants"
        padding_words[43] = "function"
        padding_words[44] = "settings"
        padding_words[45] = "GameSettings"
        padding_words[46] = "RenderSettings"
        padding_words[47] = "string"
        padding_words[48] = "sub"
        padding_words[49] = "service"
        padding_words[50] = "IsA"
        padding_words[51] = "Parent"
        padding_words[52] = "Name"
        padding_words[53] = "RunService"
        padding_words[54] = "Stepped"
        padding_words[55] = "wait"
        padding_words[56] = "Changed"
        padding_words[57] = "FindFirstChild"
        padding_words[58] = "Terrain"
        padding_words[59] = "Lighting"
        padding_words[60] = "Enabled"
        padding_words[61] = "getconnections"
        padding_words[62] = "firesignal"
        padding_words[63] = "workspace"
        padding_words[64] = "true"
        padding_words[65] = "false"
        padding_words[66] = "tostring"
        padding_words[67] = "table"
        padding_words[68] = "math"
        padding_words[69] = "random"
        padding_words[70] = "floor"
        padding_words[71] = "Humanoid"
        padding_words[72] = "Character"
        padding_words[73] = "FederalWasHereAttribute"
        padding_words[74] = "LocalPlayer"
        padding_words[75] = "plr"
        padding_words[76] = "Players"
        padding_words[77] = "Player"
        padding_words[78] = "WalkSpeed"
        padding_words[79] = "Enum"
        padding_words[80] = "KeyCode"
        padding_words[81] = "_G"
        padding_words[82] = "BreakJoints"
        padding_words[83] = "Health"
        padding_words[84] = "Chatted"
        padding_words[85] = "RemoteEvent"
        padding_words[86] = "RemoteFunction"
        padding_words[87] = "getrawmetatable"
        padding_words[88] = "make_writable"
        padding_words[89] = "setreadonly"
        padding_words[90] = "PointsService"
        padding_words[91] = "JointsService"
        padding_words[92] = "VRService"
        padding_words[93] = "Ragdoll"
        padding_words[94] = "SimulationRadiusLocaleId"
        padding_words[95] = "gethiddenproperty"
        padding_words[96] = "sethiddenproperty"
        padding_words[97] = "syn"
        padding_words[98] = "Zombies"
        padding_words[99] = "GameId"
        padding_words[100] = "JobId"
        padding_words[101] = "Tool"
        padding_words[102] = "Accessory"
        padding_words[103] = "RightGrip"
        padding_words[104] = "Weld"
        padding_words[105] = "HumanoidRootPart"
        padding_words[106] = "GuiService"
        padding_words[107] = "CoreGui"
        padding_words[108] = "BindableEvent"
        padding_words[109] = "fire"
        padding_words[110] = "BodyForce"
        padding_words[111] = "Chat"
        padding_words[112] = "PlayerGui"
        padding_words[113] = "NetworkMarker"
        padding_words[114] = "Geometry"
        padding_words[115] = "TextService"
        padding_words[116] = "LogService"
        padding_words[117] = "error"
        padding_words[118] = "LuaSettings"
        padding_words[119] = "UserInputService"
        padding_words[120] = "fireclickdetector"
        padding_words[121] = "Trail"
        padding_words[122] = "Camera"
        padding_words[123] = "CurrentCamera"
        padding_words[124] = "FOV"
        padding_words[125] = "Path"
        padding_words[126] = "InputObject"
        padding_words[127] = "Frame"
        padding_words[128] = "TextBox"
        padding_words[129] = "ScreenGui"
        padding_words[130] = "hookfunction"
        padding_words[131] = "Debris"
        padding_words[132] = "ReplicatedStorage"
        padding_words[133] = "ReplicatedFirst"
        padding_words[134] = "decompile"
        padding_words[135] = "saveinstance"
        padding_words[136] = "TweenService"
        padding_words[137] = "SoundService"
        padding_words[138] = "Teams"
        padding_words[139] = "Tween"
        padding_words[140] = "BasePart"
        padding_words[141] = "Seat"
        padding_words[142] = "Decal"
        padding_words[143] = "Instance"
        padding_words[144] = "new"
        padding_words[145] = "Ray"
        padding_words[146] = "TweenInfo"
        padding_words[147] = "Color3"
        padding_words[148] = "CFrame"
        padding_words[149] = "Vector3"
        padding_words[150] = "Vector2"
        padding_words[151] = "UDim"
        padding_words[152] = "UDim2"
        padding_words[153] = "NumberRange"
        padding_words[154] = "NumberSequence"
        padding_words[155] = "Handle"
        padding_words[156] = "Gravity"
        padding_words[157] = "HopperBin"
        padding_words[158] = "Shirt"
        padding_words[159] = "Pants"
        padding_words[160] = "Mouse"
        padding_words[161] = "IntValue"
        padding_words[162] = "StringValue"
        padding_words[163] = "Value"
        padding_words[164] = "VirtualUser"
        padding_words[165] = "MouseButton1Click"
        padding_words[166] = "Activated"
        padding_words[167] = "FileMesh"
        padding_words[168] = "TeleportService"
        padding_words[169] = "Teleport"
        padding_words[170] = "userdata"
        padding_words[171] = "string"
        padding_words[172] = "int"
        padding_words[173] = "number"
        padding_words[174] = "bool"
        padding_words[175] = "BodyGyro"
        padding_words[176] = "Backpack"
        padding_words[177] = "SkateboardPlatform"
        padding_words[178] = "FilteringEnabled"
        padding_words[179] = "Shoot"
        padding_words[180] = "Shell"
        padding_words[181] = "Asset"
        padding_words[182] = "checkifgay"
        padding_words[183] = "create"
        padding_words[184] = "god"
        padding_words[185] = "BrianSucksVexu"
        padding_words[186] = "checkifalive"
        padding_words[187] = "getteams"
        padding_words[188] = "getnearest"
        padding_words[189] = "getcross"
        padding_words[190] = "autoshoot"
        padding_words[191] = "chatspam"
        padding_words[192] = "changeupvalues"
        padding_words[193] = "modifyguns"
        padding_words[194] = "infammo"
        padding_words[195] = "godmode"
        padding_words[196] = "aimbot"
        padding_words[197] = "esp"
        padding_words[198] = "crashserver"
        padding_words[199] = "antiaim"
        padding_words[200] = "usertype"
        padding_words[201] = "type"
        local padding_lines = new_table(256)
        for padding_index = 1, 2000 do
            local append_line = environment.table.insert
            local to_string = environment.tostring
            local random_index = environment.math.random(1, #padding_words)
            local word = to_string(padding_words[random_index])
            append_line(padding_lines, "aMdoSpbPT = '" .. word .. "'")
        end
        environment.table.concat(padding_lines, "\010")
    end
    bit_band = environment.bit
    bit_band = bit_band.band
    camera_angles = environment.client
    camera_angles = camera_angles.camera_angles
    eye_position = environment.client
    eye_position = eye_position.eye_position
    key_state = environment.client
    key_state = key_state.key_state
    scale_damage = environment.client
    scale_damage = scale_damage.scale_damage
    screen_size = environment.client
    screen_size = screen_size.screen_size
    set_event_callback = environment.client
    set_event_callback = set_event_callback.set_event_callback
    trace_bullet = environment.client
    trace_bullet = trace_bullet.trace_bullet
    trace_line = environment.client
    trace_line = trace_line.trace_line
    userid_to_entindex = environment.client
    userid_to_entindex = userid_to_entindex.userid_to_entindex
    get_all_entities = environment.entity
    get_all_entities = get_all_entities.get_all
    get_classname = environment.entity
    get_classname = get_classname.get_classname
    get_local_player = environment.entity
    get_local_player = get_local_player.get_local_player
    get_player_resource = environment.entity
    get_player_resource = get_player_resource.get_player_resource
    get_players = environment.entity
    get_players = get_players.get_players
    get_prop = environment.entity
    get_prop = get_prop.get_prop
    hitbox_position = environment.entity
    hitbox_position = hitbox_position.hitbox_position
    is_alive = environment.entity
    is_alive = is_alive.is_alive
    is_dormant = environment.entity
    is_dormant = is_dormant.is_dormant
    is_enemy = environment.entity
    is_enemy = is_enemy.is_enemy
    curtime = environment.globals
    curtime = curtime.curtime
    tickcount = environment.globals
    tickcount = tickcount.tickcount
    tickinterval = environment.globals
    tickinterval = tickinterval.tickinterval
    math_abs = environment.math
    math_abs = math_abs.abs
    math_atan = environment.math
    math_atan = math_atan.atan
    math_atan2 = environment.math
    math_atan2 = math_atan2.atan2
    math_cos = environment.math
    math_cos = math_cos.cos
    math_deg = environment.math
    math_deg = math_deg.deg
    math_rad = environment.math
    math_rad = math_rad.rad
    math_sin = environment.math
    math_sin = math_sin.sin
    math_sqrt = environment.math
    math_sqrt = math_sqrt.sqrt
    draw_gradient = (environment.renderer).gradient
    draw_line = environment.renderer
    draw_line = draw_line.line
    draw_text = environment.renderer
    draw_text = draw_text.text
    draw_triangle = environment.renderer
    draw_triangle = draw_triangle.triangle
    table_remove = environment.table
    table_remove = table_remove.remove
    ui_get = environment.ui
    ui_get = ui_get.get
    ui_new_color_picker = (environment.ui).new_color_picker
    ui_new_hotkey = (environment.ui).new_hotkey
    ui_new_label = (environment.ui).new_label
    ui_new_multiselect = (environment.ui).new_multiselect
    ui_reference = (environment.ui).reference
    ui_set = environment.ui
    ui_set = ui_set.set
    ui_set_callback = environment.ui
    ui_set_callback = ui_set_callback.set_callback
    ui_set_visible = environment.ui
    ui_set_visible = ui_set_visible.set_visible
    get_value_type = environment.type
    native_controls = new_table(256)
    set_native_ui_visible = "enabled"
    script_controls = ui_reference
    script_controls = script_controls(("AA"), ("Anti-aimbot angles"), ("Enabled"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "pitch"
    script_controls = ui_reference
    script_controls = script_controls(("AA"), ("Anti-aimbot angles"), ("pitch"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "yawbase"
    script_controls = ui_reference
    script_controls = script_controls(("AA"), ("Anti-aimbot angles"), ("Yaw base"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "fakeyawlimit"
    script_controls = ui_reference
    script_controls = script_controls(("AA"), ("anti-aimbot angles"), ("Fake yaw limit"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "fsbodyyaw"
    script_controls = ui_reference
    script_controls = script_controls(("AA"), ("anti-aimbot angles"), ("Freestanding body yaw"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "edgeyaw"
    script_controls = ui_reference
    script_controls = script_controls(("AA"), ("Anti-aimbot angles"), ("Edge yaw"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "maxprocticks"
    script_controls = ui_reference
    script_controls = script_controls(("MISC"), ("Settings"), ("sv_maxusrcmdprocessticks"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "fakeduck"
    script_controls = ui_reference
    script_controls = script_controls(("RAGE"), ("Other"), ("Duck peek assist"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "safepoint"
    script_controls = ui_reference
    script_controls = script_controls(("RAGE"), ("Aimbot"), ("Force safe point"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "forcebaim"
    script_controls = ui_reference
    script_controls = script_controls(("RAGE"), ("Other"), ("Force body aim"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "player_list"
    script_controls = ui_reference
    script_controls = script_controls(("PLAYERS"), ("Players"), ("Player list"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "reset_all"
    script_controls = ui_reference
    script_controls = script_controls(("PLAYERS"), ("Players"), ("Reset all"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "apply_all"
    script_controls = ui_reference
    script_controls = script_controls(("PLAYERS"), ("Adjustments"), ("Apply to all"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "load_cfg"
    script_controls = ui_reference
    script_controls = script_controls(("Config"), ("Presets"), ("Load"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "fl_limit"
    script_controls = ui_reference
    script_controls = script_controls(("AA"), ("Fake lag"), ("Limit"))
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "yaw"
    script_controls = new_table(256)
    anti_aim_state = ui_reference
    player_records = "AA"
    contains_value = "Anti-aimbot angles"
    head_coordinates = "Yaw"
    local returned_439 = pack_results(anti_aim_state(("AA"), ("Anti-aimbot angles"), ("Yaw")))
    for index = 1, returned_439.n do
        script_controls[0 + index] = returned_439[index]
    end
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "quickpeek"
    script_controls = new_table(256)
    anti_aim_state = ui_reference
    player_records = "RAGE"
    contains_value = "Other"
    head_coordinates = "Quick peek assist"
    local returned_448 = pack_results(anti_aim_state(("RAGE"), ("Other"), ("Quick peek assist")))
    for index = 1, returned_448.n do
        script_controls[0 + index] = returned_448[index]
    end
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "yawjitter"
    script_controls = new_table(256)
    anti_aim_state = ui_reference
    player_records = "AA"
    contains_value = "Anti-aimbot angles"
    head_coordinates = "Yaw jitter"
    local returned_457 = pack_results(anti_aim_state(("AA"), ("Anti-aimbot angles"), ("Yaw jitter")))
    for index = 1, returned_457.n do
        script_controls[0 + index] = returned_457[index]
    end
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "bodyyaw"
    script_controls = new_table(256)
    anti_aim_state = ui_reference
    player_records = "AA"
    contains_value = "Anti-aimbot angles"
    head_coordinates = "Body yaw"
    local returned_466 = pack_results(anti_aim_state(("AA"), ("Anti-aimbot angles"), ("Body yaw")))
    for index = 1, returned_466.n do
        script_controls[0 + index] = returned_466[index]
    end
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "freestand"
    script_controls = new_table(256)
    anti_aim_state = ui_reference
    player_records = "AA"
    contains_value = "Anti-aimbot angles"
    head_coordinates = "Freestanding"
    local returned_475 = pack_results(anti_aim_state(("AA"), ("Anti-aimbot angles"), ("Freestanding")))
    for index = 1, returned_475.n do
        script_controls[0 + index] = returned_475[index]
    end
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "os"
    script_controls = new_table(256)
    anti_aim_state = ui_reference
    player_records = "AA"
    contains_value = "Other"
    head_coordinates = "On shot anti-aim"
    local returned_484 = pack_results(anti_aim_state(("AA"), ("Other"), ("On shot anti-aim")))
    for index = 1, returned_484.n do
        script_controls[0 + index] = returned_484[index]
    end
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "slow"
    script_controls = new_table(256)
    anti_aim_state = ui_reference
    player_records = "AA"
    contains_value = "Other"
    head_coordinates = "Slow motion"
    local returned_493 = pack_results(anti_aim_state(("AA"), ("Other"), ("Slow motion")))
    for index = 1, returned_493.n do
        script_controls[0 + index] = returned_493[index]
    end
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "dt"
    script_controls = new_table(256)
    anti_aim_state = ui_reference
    player_records = "RAGE"
    contains_value = "Other"
    head_coordinates = "Double tap"
    local returned_502 = pack_results(anti_aim_state(("RAGE"), ("Other"), ("Double tap")))
    for index = 1, returned_502.n do
        script_controls[0 + index] = returned_502[index]
    end
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "ps"
    script_controls = new_table(256)
    anti_aim_state = ui_reference
    player_records = "RAGE"
    contains_value = "Other"
    head_coordinates = "Double tap"
    local returned_511 = pack_results(anti_aim_state(("RAGE"), ("Other"), ("Double tap")))
    for index = 1, returned_511.n do
        script_controls[0 + index] = returned_511[index]
    end
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = "fakelag"
    script_controls = new_table(256)
    anti_aim_state = ui_reference
    player_records = "AA"
    contains_value = "Fake lag"
    head_coordinates = "Enabled"
    local returned_520 = pack_results(anti_aim_state(("AA"), ("Fake lag"), ("Enabled")))
    for index = 1, returned_520.n do
        script_controls[0 + index] = returned_520[index]
    end
    native_controls[set_native_ui_visible] = script_controls
    set_native_ui_visible = function(visible)
        local value_1, value_2, value_3
        if not (visible ~= nil) then
            visible = true
        end
        value_1 = ui_set_visible
        value_2 = (native_controls).pitch
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = (native_controls).yawbase
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = ((native_controls).yaw)[1]
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = ((native_controls).yaw)[2]
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = ((native_controls).yawjitter)[1]
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = ((native_controls).yawjitter)[2]
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = ((native_controls).bodyyaw)[1]
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = ((native_controls).bodyyaw)[2]
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = (native_controls).fakeyawlimit
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = (native_controls).fsbodyyaw
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = (native_controls).edgeyaw
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = ((native_controls).freestand)[1]
        value_3 = visible
        value_1(value_2, value_3)
        value_1 = ui_set_visible
        value_2 = ((native_controls).freestand)[2]
        value_3 = visible
        value_1(value_2, value_3)
        return 
    end
    script_controls = set_native_ui_visible
    script_controls((false))
    script_controls = new_table(256)
    anti_aim_state = "b"
    player_records = new_table(256)
    contains_value = "Standing"
    player_records[contains_value] = ("Reversed Freestanding")
    contains_value = "Moving"
    player_records[contains_value] = ("Reversed Freestanding")
    contains_value = "Slow walk"
    player_records[contains_value] = ("Reversed Freestanding")
    contains_value = "In air"
    player_records[contains_value] = ("Freestanding")
    contains_value = "On E"
    player_records[contains_value] = ("Freestanding")
    script_controls[anti_aim_state] = player_records
    anti_aim_state = "r"
    player_records = new_table(256)
    contains_value = "Standing"
    player_records[contains_value] = (60)
    contains_value = "Moving"
    player_records[contains_value] = (60)
    contains_value = "Slow walk"
    player_records[contains_value] = (60)
    contains_value = "In air"
    player_records[contains_value] = (60)
    contains_value = "On E"
    player_records[contains_value] = (60)
    script_controls[anti_aim_state] = player_records
    anti_aim_state = "Detect missed angle"
    script_controls[anti_aim_state] = (false)
    anti_aim_state = "Anti-resolver on X shot"
    script_controls[anti_aim_state] = ("-")
    anti_aim_state = "Anti-resolver shot amount"
    script_controls[anti_aim_state] = (0)
    anti_aim_state = "s"
    player_records = ui_new_multiselect
    contains_value = "AA"
    head_coordinates = "Anti-aimbot angles"
    normalize_yaw = "Anti-aim settings"
    yaw_between_points = new_table(6)
    signed_coordinate_delta = "Manual AA"
    target_info = "Jitter when not networked"
    signed_line_distance = "Freestanding"
    target_record_info = "Edge yaw"
    pose_desync_side = "Keybind indicator"
    update_shot_history = "AA indicator"
    yaw_between_points[1] = signed_coordinate_delta
    yaw_between_points[2] = target_info
    yaw_between_points[3] = signed_line_distance
    yaw_between_points[4] = target_record_info
    yaw_between_points[5] = pose_desync_side
    yaw_between_points[6] = update_shot_history
    player_records = player_records(contains_value, head_coordinates, normalize_yaw, yaw_between_points)
    script_controls[anti_aim_state] = player_records
    anti_aim_state = "ml"
    player_records = ui_new_hotkey
    player_records = player_records(("AA"), ("Anti-aimbot angles"), ("Manual left\010Manual Prediction"))
    script_controls[anti_aim_state] = player_records
    anti_aim_state = "mr"
    player_records = ui_new_hotkey
    player_records = player_records(("AA"), ("Anti-aimbot angles"), ("Manual right\010Manual Prediction"))
    script_controls[anti_aim_state] = player_records
    anti_aim_state = "mf"
    player_records = ui_new_hotkey
    player_records = player_records(("AA"), ("Anti-aimbot angles"), ("Manual forwards\010Manual Prediction"))
    script_controls[anti_aim_state] = player_records
    anti_aim_state = "fs"
    player_records = ui_new_hotkey
    player_records = player_records(("AA"), ("Anti-aimbot angles"), ("Freestanding\010Manual Prediction"))
    script_controls[anti_aim_state] = player_records
    anti_aim_state = "ey"
    player_records = ui_new_hotkey
    player_records = player_records(("AA"), ("Anti-aimbot angles"), ("Edye yaw\010Manual Prediction"))
    script_controls[anti_aim_state] = player_records
    anti_aim_state = "k"
    player_records = ui_new_multiselect
    contains_value = "AA"
    head_coordinates = "Anti-aimbot angles"
    normalize_yaw = "Keybinds"
    yaw_between_points = new_table(7)
    signed_coordinate_delta = "Double tap"
    target_info = "Onshot Anti-Aim"
    signed_line_distance = "Force body aim"
    target_record_info = "Force safe point"
    pose_desync_side = "Quick peek"
    update_shot_history = "Edge yaw"
    angles_to_direction = "Freestanding"
    yaw_between_points[1] = signed_coordinate_delta
    yaw_between_points[2] = target_info
    yaw_between_points[3] = signed_line_distance
    yaw_between_points[4] = target_record_info
    yaw_between_points[5] = pose_desync_side
    yaw_between_points[6] = update_shot_history
    yaw_between_points[7] = angles_to_direction
    player_records = player_records(contains_value, head_coordinates, normalize_yaw, yaw_between_points)
    script_controls[anti_aim_state] = player_records
    anti_aim_state = "clr"
    player_records = {
    }
    contains_value = ui_new_label
    contains_value = contains_value(("AA"), ("Anti-aimbot angles"), ("Main color"))
    head_coordinates = ui_new_color_picker
    normalize_yaw = "AA"
    yaw_between_points = "Anti-aimbot angles"
    signed_coordinate_delta = "Main colorpicker"
    local returned_650 = pack_results(head_coordinates(("AA"), ("Anti-aimbot angles"), ("Main colorpicker")))
    player_records[1] = contains_value
    for index = 1, returned_650.n do
        player_records[1 + index] = returned_650[index]
    end
    script_controls[anti_aim_state] = player_records
    anti_aim_state = "clr2"
    player_records = {
    }
    contains_value = ui_new_label
    contains_value = contains_value(("AA"), ("Anti-aimbot angles"), ("Accent color"))
    head_coordinates = ui_new_color_picker
    normalize_yaw = "AA"
    yaw_between_points = "Anti-aimbot angles"
    signed_coordinate_delta = "Accent colorpicker"
    local returned_664 = pack_results(head_coordinates(("AA"), ("Anti-aimbot angles"), ("Accent colorpicker")))
    player_records[1] = contains_value
    for index = 1, returned_664.n do
        player_records[1 + index] = returned_664[index]
    end
    script_controls[anti_aim_state] = player_records
    anti_aim_state = new_table(256)
    player_records = "aa"
    anti_aim_state[player_records] = (1)
    player_records = "s_i"
    contains_value = new_table(5)
    head_coordinates = "Standing"
    normalize_yaw = "Moving"
    yaw_between_points = "Slow walk"
    signed_coordinate_delta = "In air"
    target_info = "On E"
    contains_value[1] = head_coordinates
    contains_value[2] = normalize_yaw
    contains_value[3] = yaw_between_points
    contains_value[4] = signed_coordinate_delta
    contains_value[5] = target_info
    anti_aim_state[player_records] = contains_value
    player_records = "l_s"
    contains_value = new_table(3)
    head_coordinates = 0
    normalize_yaw = 0
    yaw_between_points = 0
    contains_value[1] = head_coordinates
    contains_value[2] = normalize_yaw
    contains_value[3] = yaw_between_points
    anti_aim_state[player_records] = contains_value
    player_records = "rec"
    contains_value = new_table(256)
    anti_aim_state[player_records] = contains_value
    player_records = "desync"
    anti_aim_state[player_records] = (0)
    player_records = "holding_e"
    anti_aim_state[player_records] = (false)
    player_records = "target"
    anti_aim_state[player_records] = (0)
    player_records = "dir"
    contains_value = new_table(256)
    head_coordinates = "manual"
    contains_value[head_coordinates] = (0)
    head_coordinates = "fs"
    contains_value[head_coordinates] = (false)
    head_coordinates = "edge"
    contains_value[head_coordinates] = (false)
    head_coordinates = "time"
    contains_value[head_coordinates] = (0)
    anti_aim_state[player_records] = contains_value
    player_records = "stored_dir"
    contains_value = new_table(256)
    head_coordinates = "manual"
    contains_value[head_coordinates] = (0)
    head_coordinates = "fs"
    contains_value[head_coordinates] = (false)
    head_coordinates = "edge"
    contains_value[head_coordinates] = (false)
    head_coordinates = "time"
    contains_value[head_coordinates] = (0)
    anti_aim_state[player_records] = contains_value
    player_records = "old_dsy"
    anti_aim_state[player_records] = (true)
    player_records = "classnames"
    contains_value = new_table(3)
    head_coordinates = "CWorld"
    normalize_yaw = "CCSPlayer"
    yaw_between_points = "CFuncBrush"
    contains_value[1] = head_coordinates
    contains_value[2] = normalize_yaw
    contains_value[3] = yaw_between_points
    anti_aim_state[player_records] = contains_value
    player_records = "nonweapons"
    contains_value = new_table(7)
    head_coordinates = "knife"
    normalize_yaw = "hegrenade"
    yaw_between_points = "inferno"
    signed_coordinate_delta = "flashbang"
    target_info = "decoy"
    signed_line_distance = "smokegrenade"
    target_record_info = "taser"
    contains_value[1] = head_coordinates
    contains_value[2] = normalize_yaw
    contains_value[3] = yaw_between_points
    contains_value[4] = signed_coordinate_delta
    contains_value[5] = target_info
    contains_value[6] = signed_line_distance
    contains_value[7] = target_record_info
    anti_aim_state[player_records] = contains_value
    player_records = new_table(256)
    do
        local loop_has_value_754 = true
        contains_value = 0 + (1)
        head_coordinates = 0 + (64)
        normalize_yaw = 0 + (1)
        if (normalize_yaw > 0 and contains_value > head_coordinates) or (normalize_yaw <= 0 and contains_value < head_coordinates) then
            contains_value = contains_value + normalize_yaw
            loop_has_value_754 = (normalize_yaw > 0 and contains_value <= head_coordinates) or (normalize_yaw <= 0 and contains_value >= head_coordinates)
            if loop_has_value_754 then
                yaw_between_points = contains_value
            end
        else
            yaw_between_points = contains_value
        end
        while loop_has_value_754 do
            signed_coordinate_delta = new_table(256)
            target_info = "s"
            signed_line_distance = new_table(256)
            signed_coordinate_delta[target_info] = signed_line_distance
            target_info = "h"
            signed_line_distance = new_table(256)
            signed_coordinate_delta[target_info] = signed_line_distance
            target_info = "m"
            signed_coordinate_delta[target_info] = (0)
            target_info = "r"
            signed_coordinate_delta[target_info] = (0)
            target_info = "d"
            signed_coordinate_delta[target_info] = (0)
            target_info = "l"
            signed_coordinate_delta[target_info] = (0)
            player_records[yaw_between_points] = signed_coordinate_delta
            contains_value = contains_value + normalize_yaw
            loop_has_value_754 = (normalize_yaw > 0 and contains_value <= head_coordinates) or (normalize_yaw <= 0 and contains_value >= head_coordinates)
            if loop_has_value_754 then
                yaw_between_points = contains_value
            end
        end
    end
    contains_value = function(values, wanted)
        local value_2, value_3, value_4, value_5, value_6
        if values ~= nil then
            value_2 = get_value_type
            value_3 = values
            value_2 = value_2(value_3)
            if not (value_2 ~= "number") then
                value_2 = ui_get
                value_3 = values
                value_2 = value_2(value_3)
                values = value_2
            end
            value_3 = #values
            do
                local loop_has_value_15 = true
                value_2 = 0 + (0)
                value_3 = 0 + value_3
                value_4 = 0 + (1)
                if (value_4 > 0 and value_2 > value_3) or (value_4 <= 0 and value_2 < value_3) then
                    value_2 = value_2 + value_4
                    loop_has_value_15 = (value_4 > 0 and value_2 <= value_3) or (value_4 <= 0 and value_2 >= value_3)
                    if loop_has_value_15 then
                        value_5 = value_2
                    end
                else
                    value_5 = value_2
                end
                while loop_has_value_15 do
                    value_6 = values[value_5]
                    if not (value_6 ~= wanted) then
                        return (true)
                    end
                    value_2 = value_2 + value_4
                    loop_has_value_15 = (value_4 > 0 and value_2 <= value_3) or (value_4 <= 0 and value_2 >= value_3)
                    if loop_has_value_15 then
                        value_5 = value_2
                    end
                end
            end
            return (false)
        else
            return (false)
        end
    end
    head_coordinates = function(player)
        local value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9
        value_1 = hitbox_position
        value_2 = player
        value_1, value_2, value_3 = value_1(value_2, (0))
        value_4 = get_prop
        value_5 = player
        value_4, value_5, value_6 = value_4(value_5, ("m_vecOrigin"))
        value_7 = value_4
        value_8 = value_5
        value_9 = value_3
        return value_7, value_8, value_9
    end
    normalize_yaw = function(yaw)
        while not (180 >= yaw) do
            yaw = yaw - 360
        end
        while not (yaw >= -180) do
            yaw = yaw + 360
        end
        return yaw
    end
    yaw_between_points = function(from_x, from_y, to_x, to_y)
        local value_4, value_5, value_6, value_7, value_8, value_9
        value_4 = from_y - to_y
        value_5 = from_x - to_x
        value_6 = math_atan
        value_7 = value_4 / value_5
        value_6 = value_6(value_7)
        value_7 = normalize_yaw
        value_8 = value_6 * 180
        value_9 = (environment.math).pi
        value_8 = value_8 / value_9
        value_7 = value_7(value_8)
        value_6 = value_7
        if not (0 > value_5) then
            value_7 = normalize_yaw
            value_8 = value_6 + 180
            value_7 = value_7(value_8)
            value_6 = value_7
        end
        return value_6
    end
    signed_coordinate_delta = function(position, target_position, flatten_height)
        local value_3, value_4, value_5, value_6
        if not (flatten_height ~= nil) then
            flatten_height = false
        end
        if not (not flatten_height) then
            value_3 = new_table(3)
            value_4 = target_position[1]
            value_5 = target_position[2]
            value_6 = position[3]
            value_3[1] = value_4
            value_3[2] = value_5
            value_3[3] = value_6
            target_position = value_3
        end
        value_3 = position[1]
        value_4 = target_position[1]
        value_3 = value_3 - value_4
        value_4 = position[2]
        value_5 = target_position[2]
        value_4 = value_4 - value_5
        value_3 = value_3 + value_4
        value_4 = position[3]
        value_5 = target_position[3]
        value_4 = value_4 - value_5
        value_3 = value_3 + value_4
        if not (value_3 >= 0) then
            value_3 = value_3 * 0.75
        end
        return value_3
    end
    target_info = function(player, other_player)
        local value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13
        local value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21
        value_2 = head_coordinates
        value_3 = player
        value_2, value_3, value_4 = value_2(value_3)
        value_5 = head_coordinates
        value_6 = get_local_player
        local returned_6 = pack_results(value_6())
        value_5, value_6, value_7 = value_5(unpack_results(returned_6, 1, returned_6.n))
        value_8 = new_table(3)
        value_9 = value_5
        value_10 = value_6
        value_11 = value_7
        value_8[1] = value_9
        value_8[2] = value_10
        value_8[3] = value_11
        value_9 = new_table(3)
        value_10 = value_2
        value_11 = value_3
        value_12 = value_4
        value_9[1] = value_10
        value_9[2] = value_11
        value_9[3] = value_12
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
        value_12 = math_sqrt
        value_13 = (value_11[1]) ^ 2
        value_14 = (value_11[2]) ^ 2
        value_13 = value_13 + value_14
        value_14 = (value_11[3]) ^ 2
        value_13 = value_13 + value_14
        value_12 = value_12(value_13)
        value_13 = new_table(3)
        value_14 = (value_11[1]) / value_12
        value_15 = (value_11[2]) / value_12
        value_16 = (value_11[3]) / value_12
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
        value_16 = anti_aim_state
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
        value_16.ls = value_17
        value_16 = signed_coordinate_delta
        value_17 = (anti_aim_state).ls
        value_18 = value_8
        return value_16(value_17, value_18, (true))
    end
    signed_line_distance = function(line_start, line_end, point)
        local value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12
        value_3 = head_coordinates
        value_4 = line_start
        value_3, value_4, value_5 = value_3(value_4)
        value_6 = head_coordinates
        value_7 = line_end
        value_6, value_7, value_8 = value_6(value_7)
        value_9 = ((point.y) - value_4) * value_6
        value_10 = ((point.x) - value_3) * value_7
        value_9 = value_9 - value_10
        value_10 = (point.x) * value_4
        value_9 = value_9 + value_10
        value_10 = (point.y) * value_3
        value_9 = value_9 - value_10
        value_10 = math_sqrt
        value_11 = ((point.y) - value_4) ^ 2
        value_12 = ((point.x) - value_3) ^ 2
        value_11 = value_11 + value_12
        value_10 = value_10(value_11)
        value_9 = value_9 / value_10
        return value_9
    end
    target_record_info = function(argument_1, argument_2, argument_3, argument_4, argument_5)
        local value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13
        value_5 = new_table(256)
        value_6 = head_coordinates
        value_7 = argument_4
        local returned_4 = pack_results(value_6(value_7))
        for index = 1, returned_4.n do
            value_5[0 + index] = returned_4[index]
        end
        value_6 = new_table(256)
        value_7 = get_prop
        value_8 = argument_4
        value_9 = "m_vecOrigin"
        local returned_10 = pack_results(value_7(value_8, ("m_vecOrigin")))
        for index = 1, returned_10.n do
            value_6[0 + index] = returned_10[index]
        end
        value_7 = argument_2[3]
        value_8 = (value_5[3]) + 10
        if value_8 < value_7 then
            return (false)
        else
            value_7 = argument_2[3]
            value_8 = value_6[3]
            if value_7 >= value_8 then
                value_7 = math_abs
                value_8 = signed_line_distance
                value_9 = argument_3
                value_10 = argument_4
                value_11 = argument_5
                local returned_26 = pack_results(value_8(value_9, value_10, value_11))
                value_7 = value_7(unpack_results(returned_26, 1, returned_26.n))
                if 300 >= value_7 then
                    value_7 = math_abs
                    value_8 = argument_1
                    value_7 = value_7(value_8)
                    if value_7 >= 30 then
                        value_7 = get_prop
                        value_8 = (get_player_resource)()
                        value_10 = argument_3
                        value_7 = value_7(value_8, ("m_iPing"), value_10)
                        value_8 = (tickinterval)()
                        value_8 = value_7 * value_8
                        value_8 = 14 - value_8
                        value_9 = #((anti_aim_state).rec)
                        if value_8 > value_9 then
                            return (false)
                        else
                            value_9 = ((anti_aim_state).rec)[value_8]
                            if value_9 ~= nil then
                                value_10 = signed_coordinate_delta
                                value_11 = value_9
                                value_12 = value_5
                                value_10 = value_10(value_11, value_12, (true))
                                if argument_1 >= 0 then
                                    if argument_1 >= value_10 then
                                        value_11 = math_abs
                                        value_12 = argument_1
                                        value_11 = value_11(value_12)
                                        value_12 = math_abs
                                        value_13 = value_10
                                        value_12 = value_12(value_13)
                                        if value_12 < value_11 then
                                            value_11 = true
                                        else
                                            value_11 = false
                                        end
                                    else
                                        value_11 = math_abs
                                        value_12 = argument_1
                                        value_11 = value_11(value_12)
                                        value_12 = math_abs
                                        value_13 = value_10
                                        value_12 = value_12(value_13)
                                        if value_11 < value_12 then
                                            value_11 = true
                                        else
                                            value_11 = math_abs
                                            value_12 = argument_1
                                            value_11 = value_11(value_12)
                                            value_12 = math_abs
                                            value_13 = value_10
                                            value_12 = value_12(value_13)
                                            if value_12 < value_11 then
                                                value_11 = true
                                            else
                                                value_11 = false
                                            end
                                        end
                                    end
                                else
                                    if value_10 < argument_1 then
                                        value_11 = math_abs
                                        value_12 = argument_1
                                        value_11 = value_11(value_12)
                                        value_12 = math_abs
                                        value_13 = value_10
                                        value_12 = value_12(value_13)
                                        if value_11 < value_12 then
                                            value_11 = true
                                        else
                                            value_11 = math_abs
                                            value_12 = argument_1
                                            value_11 = value_11(value_12)
                                            value_12 = math_abs
                                            value_13 = value_10
                                            value_12 = value_12(value_13)
                                            if value_12 < value_11 then
                                                value_11 = true
                                            else
                                                value_11 = false
                                            end
                                        end
                                    else
                                        if argument_1 >= value_10 then
                                            value_11 = math_abs
                                            value_12 = argument_1
                                            value_11 = value_11(value_12)
                                            value_12 = math_abs
                                            value_13 = value_10
                                            value_12 = value_12(value_13)
                                            if value_12 < value_11 then
                                                value_11 = true
                                            else
                                                value_11 = false
                                            end
                                        else
                                            value_11 = math_abs
                                            value_12 = argument_1
                                            value_11 = value_11(value_12)
                                            value_12 = math_abs
                                            value_13 = value_10
                                            value_12 = value_12(value_13)
                                            if value_11 < value_12 then
                                                value_11 = true
                                            else
                                                value_11 = math_abs
                                                value_12 = argument_1
                                                value_11 = value_11(value_12)
                                                value_12 = math_abs
                                                value_13 = value_10
                                                value_12 = value_12(value_13)
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
                                return (false)
                            end
                        end
                    else
                        return (true)
                    end
                else
                    return (false)
                end
            else
                return (false)
            end
        end
    end
    pose_desync_side = function(player)
        local value_1, value_2
        value_1 = (anti_aim_state).desync
        if value_1 ~= 0 then
            value_1 = get_prop
            value_2 = player
            value_1 = ((value_1(value_2, ("m_flPoseParameter"), (11))) * 120) - 60
            if value_1 >= 0 then
                value_2 = -90
            else
                value_2 = 90
                if not (90) then
                    value_2 = -90
                end
            end
            return value_2
        else
            return (0)
        end
    end
    update_shot_history = function(event)
        local value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8
        do
            local loop_has_value_4 = true
            value_1 = 0 + (1)
            value_2 = 0 + (64)
            value_3 = 0 + (1)
            if (value_3 > 0 and value_1 > value_2) or (value_3 <= 0 and value_1 < value_2) then
                value_1 = value_1 + value_3
                loop_has_value_4 = (value_3 > 0 and value_1 <= value_2) or (value_3 <= 0 and value_1 >= value_2)
                if loop_has_value_4 then
                    value_4 = value_1
                end
            else
                value_4 = value_1
            end
            while loop_has_value_4 do
                value_5 = ((player_records)[value_4]).r
                value_6 = #(((player_records)[value_4]).s)
                if value_5 >= value_6 then
                    value_5 = ((player_records)[value_4]).r
                    value_6 = #(((player_records)[value_4]).s)
                    if not (value_6 >= value_5) then
                        value_5 = (player_records)[value_4]
                        value_6 = #(((player_records)[value_4]).s)
                        value_5.r = value_6
                    end
                else
                    value_5 = #(((player_records)[value_4]).h)
                    if 0 >= value_5 then
                        value_5 = false
                    else
                        value_5 = ((player_records)[value_4]).s
                        value_6 = #(((player_records)[value_4]).s)
                        value_5 = (value_5[value_6]).t
                        value_6 = ((player_records)[value_4]).h
                        value_7 = #(((player_records)[value_4]).h)
                        value_6 = (value_6[value_7]).t
                        if value_5 == value_6 then
                            value_5 = true
                        else
                            value_5 = false
                        end
                    end
                    if not value_5 then
                        value_6 = (player_records)[value_4]
                        if not value_5 then
                            value_7 = 0
                        else
                            value_7 = ((player_records)[value_4]).h
                            value_8 = #(((player_records)[value_4]).h)
                            value_7 = (value_7[value_8]).h
                            if value_7 ~= 1 then
                                value_7 = 0
                            else
                                value_7 = pose_desync_side
                                value_8 = event
                                value_7 = value_7(value_8)
                                if not (value_7) then
                                    value_7 = 0
                                end
                            end
                        end
                        value_6.l = value_7
                        if value_5 then
                            value_6 = (player_records)[value_4]
                            value_6.m = 0
                        else
                            value_6 = ((player_records)[value_4]).m
                            value_7 = (script_controls)["Anti-resolver shot amount"]
                            if value_6 >= value_7 then
                                value_6 = (player_records)[value_4]
                                value_6.m = 0
                            else
                                value_6 = (player_records)[value_4]
                                value_7 = (((player_records)[value_4]).m) + 1
                                value_6.m = value_7
                            end
                        end
                        if not (not value_5) then
                            value_6 = ((player_records)[value_4]).s
                            value_7 = #(((player_records)[value_4]).s)
                            value_6 = value_6[value_7]
                            value_7 = pose_desync_side
                            value_8 = event
                            value_7 = value_7(value_8)
                            value_6.d = value_7
                        end
                        value_6 = (player_records)[value_4]
                        value_7 = ((player_records)[value_4]).s
                        value_8 = #(((player_records)[value_4]).s)
                        value_7 = (value_7[value_8]).d
                        value_6.d = value_7
                        value_6 = anti_aim_state
                        value_6.target = value_4
                    else
                        value_6 = ((player_records)[value_4]).h
                        value_7 = #(((player_records)[value_4]).h)
                        value_6 = (value_6[value_7]).v
                        if not (value_6 ~= event) then
                            value_6 = (player_records)[value_4]
                            if not value_5 then
                                value_7 = 0
                            else
                                value_7 = ((player_records)[value_4]).h
                                value_8 = #(((player_records)[value_4]).h)
                                value_7 = (value_7[value_8]).h
                                if value_7 ~= 1 then
                                    value_7 = 0
                                else
                                    value_7 = pose_desync_side
                                    value_8 = event
                                    value_7 = value_7(value_8)
                                    if not (value_7) then
                                        value_7 = 0
                                    end
                                end
                            end
                            value_6.l = value_7
                            if value_5 then
                                value_6 = (player_records)[value_4]
                                value_6.m = 0
                            else
                                value_6 = ((player_records)[value_4]).m
                                value_7 = (script_controls)["Anti-resolver shot amount"]
                                if value_6 >= value_7 then
                                    value_6 = (player_records)[value_4]
                                    value_6.m = 0
                                else
                                    value_6 = (player_records)[value_4]
                                    value_7 = (((player_records)[value_4]).m) + 1
                                    value_6.m = value_7
                                end
                            end
                            if not (not value_5) then
                                value_6 = ((player_records)[value_4]).s
                                value_7 = #(((player_records)[value_4]).s)
                                value_6 = value_6[value_7]
                                value_7 = pose_desync_side
                                value_8 = event
                                value_7 = value_7(value_8)
                                value_6.d = value_7
                            end
                            value_6 = (player_records)[value_4]
                            value_7 = ((player_records)[value_4]).s
                            value_8 = #(((player_records)[value_4]).s)
                            value_7 = (value_7[value_8]).d
                            value_6.d = value_7
                            value_6 = anti_aim_state
                            value_6.target = value_4
                        end
                    end
                    value_6 = (player_records)[value_4]
                    value_7 = #(((player_records)[value_4]).s)
                    value_6.r = value_7
                end
                value_1 = value_1 + value_3
                loop_has_value_4 = (value_3 > 0 and value_1 <= value_2) or (value_3 <= 0 and value_1 >= value_2)
                if loop_has_value_4 then
                    value_4 = value_1
                end
            end
        end
        return 
    end
    angles_to_direction = function(pitch, yaw)
        local value_2, value_3, value_4, value_5, value_6, value_7, value_8
        value_2 = math_sin
        value_3 = math_rad
        value_4 = yaw
        local returned_4 = pack_results(value_3(value_4))
        value_2 = value_2(unpack_results(returned_4, 1, returned_4.n))
        value_3 = math_cos
        value_4 = math_rad
        value_5 = yaw
        local returned_9 = pack_results(value_4(value_5))
        value_3 = value_3(unpack_results(returned_9, 1, returned_9.n))
        value_4 = math_sin
        value_5 = math_rad
        value_6 = pitch
        local returned_14 = pack_results(value_5(value_6))
        value_4 = value_4(unpack_results(returned_14, 1, returned_14.n))
        value_5 = math_cos
        value_6 = math_rad
        value_7 = pitch
        local returned_19 = pack_results(value_6(value_7))
        value_5 = value_5(unpack_results(returned_19, 1, returned_19.n))
        value_6 = value_5 * value_3
        value_7 = value_5 * value_2
        value_8 = -(value_4)
        return value_6, value_7, value_8
    end
    classify_movement = function(player, command)
        local value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10
        value_2 = (anti_aim_state).holding_e
        if not value_2 then
            value_2 = ui_get
            value_3 = ((native_controls).slow)[1]
            value_2 = value_2(value_3)
            if not (not value_2) then
                value_2 = ui_get
                value_3 = ((native_controls).slow)[2]
                value_2 = value_2(value_3)
            end
            if not value_2 then
                value_3 = bit_band
                value_4 = get_prop
                value_5 = player
                value_4 = value_4(value_5, ("m_fFlags"))
                value_3 = value_3(value_4, (1))
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
                    value_4 = get_prop
                    value_5 = player
                    value_4, value_5, value_6 = value_4(value_5, ("m_vecVelocity"))
                    value_7 = anti_aim_state
                    value_8 = math_sqrt
                    value_9 = value_4 ^ 2
                    value_10 = value_5 ^ 2
                    value_9 = value_9 + value_10
                    value_8 = value_8(value_9)
                    if value_8 >= 2 then
                        value_8 = 2
                    else
                        value_8 = 1
                        if not (1) then
                            value_8 = 2
                        end
                    end
                    value_7.aa = value_8
                    return 
                else
                    value_4 = anti_aim_state
                    value_4.aa = 4
                    return 
                end
            else
                value_3 = anti_aim_state
                value_3.aa = 3
                return 
            end
        else
            value_2 = anti_aim_state
            value_2.aa = 5
            return 
        end
    end
    vector_yaw = function(x, y)
        local value_2, value_3, value_4, value_5
        if x ~= 0 then
            value_2 = math_deg
            value_3 = math_atan2
            value_4 = y
            value_5 = x
            local returned_9 = pack_results(value_3(value_4, value_5))
            return value_2(unpack_results(returned_9, 1, returned_9.n))
        else
            if y ~= 0 then
                value_2 = math_deg
                value_3 = math_atan2
                value_4 = y
                value_5 = x
                local returned_9 = pack_results(value_3(value_4, value_5))
                return value_2(unpack_results(returned_9, 1, returned_9.n))
            else
                return (0)
            end
        end
    end
    estimate_damage_at_offsets = function(argument_1, argument_2, argument_3, argument_4, argument_5)
        local value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13, value_14, value_15, value_16
        local value_17, value_18, value_19, value_20, value_21
        value_5 = new_table(256)
        value_6 = new_table(256)
        value_7 = new_table(256)
        value_8 = head_coordinates
        value_9 = argument_2
        value_8, value_9, value_10 = value_8(value_9)
        value_7[0] = value_10
        value_6[0] = value_9
        value_5[0] = value_8
        value_8 = (value_5[0]) + 40
        value_9 = value_6[0]
        value_10 = value_7[0]
        value_7[1] = value_10
        value_6[1] = value_9
        value_5[1] = value_8
        value_8 = value_5[0]
        value_9 = (value_6[0]) + 40
        value_10 = value_7[0]
        value_7[2] = value_10
        value_6[2] = value_9
        value_5[2] = value_8
        value_8 = (value_5[0]) - 40
        value_9 = value_6[0]
        value_10 = value_7[0]
        value_7[3] = value_10
        value_6[3] = value_9
        value_5[3] = value_8
        value_8 = value_5[0]
        value_9 = (value_6[0]) - 40
        value_10 = value_7[0]
        value_7[4] = value_10
        value_6[4] = value_9
        value_5[4] = value_8
        value_8 = value_5[0]
        value_9 = value_6[0]
        value_10 = (value_7[0]) + 40
        value_7[5] = value_10
        value_6[5] = value_9
        value_5[5] = value_8
        value_8 = 0
        value_9 = nil
        do
            local loop_has_value_50 = true
            value_10 = 0 + (0)
            value_11 = 0 + (5)
            value_12 = 0 + (1)
            if (value_12 > 0 and value_10 > value_11) or (value_12 <= 0 and value_10 < value_11) then
                value_10 = value_10 + value_12
                loop_has_value_50 = (value_12 > 0 and value_10 <= value_11) or (value_12 <= 0 and value_10 >= value_11)
                if loop_has_value_50 then
                    value_13 = value_10
                end
            else
                value_13 = value_10
            end
            while loop_has_value_50 do
                if value_9 == 0 then
                    value_14 = trace_bullet
                    value_15 = argument_2
                    value_16 = value_5[value_13]
                    value_17 = value_6[value_13]
                    value_18 = value_7[value_13]
                    value_19 = argument_3
                    value_20 = argument_4
                    value_21 = argument_5
                    value_14, value_15 = value_14(value_15, value_16, value_17, value_18, value_19, value_20, value_21)
                    value_9 = value_15
                    value_8 = value_14
                else
                    if not (value_9 ~= nil) then
                        value_14 = trace_bullet
                        value_15 = argument_2
                        value_16 = value_5[value_13]
                        value_17 = value_6[value_13]
                        value_18 = value_7[value_13]
                        value_19 = argument_3
                        value_20 = argument_4
                        value_21 = argument_5
                        value_14, value_15 = value_14(value_15, value_16, value_17, value_18, value_19, value_20, value_21)
                        value_9 = value_15
                        value_8 = value_14
                    end
                end
                value_10 = value_10 + value_12
                loop_has_value_50 = (value_12 > 0 and value_10 <= value_11) or (value_12 <= 0 and value_10 >= value_11)
                if loop_has_value_50 then
                    value_13 = value_10
                end
            end
        end
        value_10 = scale_damage
        value_11 = argument_2
        if value_8 ~= nil then
            value_13 = value_9
        else
            value_13 = scale_damage
            value_14 = argument_2
            value_16 = value_9
            value_13 = value_13(value_14, (2), value_16)
            if not (value_13) then
                value_13 = value_9
            end
        end
        return value_10(value_11, (1), value_13)
    end
    select_nearest_player = function(origin, other)
        local value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13
        local value_14, value_15, value_16
        value_2 = (get_players)((true))
        value_3 = #value_2
        if value_3 ~= 0 then
            value_3 = 0
            value_4 = 180
            value_6 = #value_2
            do
                local loop_has_value_13 = true
                value_5 = 0 + (1)
                value_6 = 0 + value_6
                value_7 = 0 + (1)
                if (value_7 > 0 and value_5 > value_6) or (value_7 <= 0 and value_5 < value_6) then
                    value_5 = value_5 + value_7
                    loop_has_value_13 = (value_7 > 0 and value_5 <= value_6) or (value_7 <= 0 and value_5 >= value_6)
                    if loop_has_value_13 then
                        value_8 = value_5
                    end
                else
                    value_8 = value_5
                end
                while loop_has_value_13 do
                    value_9 = get_prop
                    value_10 = value_2[value_8]
                    value_9, value_10, value_11 = value_9(value_10, ("m_vecOrigin"))
                    value_12 = math_abs
                    value_13 = normalize_yaw
                    value_14 = vector_yaw
                    value_15 = (origin[1]) - value_9
                    value_16 = (origin[2]) - value_10
                    value_14 = value_14(value_15, value_16)
                    value_15 = other[2]
                    value_14 = (value_14 - value_15) + 180
                    local returned_29 = pack_results(value_13(value_14))
                    value_12 = value_12(unpack_results(returned_29, 1, returned_29.n))
                    if not (value_12 >= value_4) then
                        value_4 = value_12
                        value_3 = value_2[value_8]
                    end
                    value_5 = value_5 + value_7
                    loop_has_value_13 = (value_7 > 0 and value_5 <= value_6) or (value_7 <= 0 and value_5 >= value_6)
                    if loop_has_value_13 then
                        value_8 = value_5
                    end
                end
            end
            return value_3
        else
            return (0)
        end
    end
    is_valid_player = function(player)
        local value_1, value_2
        if player ~= 0 then
            value_1 = is_alive
            value_2 = player
            value_1 = value_1(value_2)
            if value_1 then
                value_1 = is_dormant
                value_2 = player
                value_1 = value_1(value_2)
                if not value_1 then
                    return (true)
                else
                    return (false)
                end
            else
                return (false)
            end
        else
            return (false)
        end
    end
    update_target_anti_aim = function(command)
        local value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12
        local value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23, value_24
        local value_25, value_26, value_27, value_28
        value_1 = (get_local_player)()
        value_2 = new_table(256)
        value_3 = head_coordinates
        value_4 = value_1
        local returned_6 = pack_results(value_3(value_4))
        for index = 1, returned_6.n do
            value_2[0 + index] = returned_6[index]
        end
        value_3 = new_table(256)
        value_4 = camera_angles
        local returned_10 = pack_results(value_4())
        for index = 1, returned_10.n do
            value_3[0 + index] = returned_10[index]
        end
        value_4 = anti_aim_state
        value_5 = is_valid_player
        value_6 = (anti_aim_state).target
        value_5 = value_5(value_6)
        if not value_5 then
            value_5 = select_nearest_player
            value_6 = value_2
            value_7 = value_3
            value_5 = value_5(value_6, value_7)
        else
            value_5 = (anti_aim_state).target
            if not (value_5) then
                value_5 = select_nearest_player
                value_6 = value_2
                value_7 = value_3
                value_5 = value_5(value_6, value_7)
            end
        end
        value_4.target = value_5
        value_4 = (anti_aim_state).target
        if value_4 == 0 then
            value_4 = (script_controls).b
            value_5 = (anti_aim_state).s_i
            value_6 = (anti_aim_state).aa
            value_5 = value_5[value_6]
            value_4 = value_4[value_5]
            if value_4 ~= "Off" then
                value_4 = (script_controls).b
                value_5 = (anti_aim_state).s_i
                value_6 = (anti_aim_state).aa
                value_5 = value_5[value_6]
                value_4 = value_4[value_5]
                if value_4 ~= "Jitter" then
                    value_4 = (anti_aim_state).holding_e
                    if not value_4 then
                        value_4 = anti_aim_state
                        value_4.desync = 180
                    else
                        value_4 = anti_aim_state
                        value_5 = (anti_aim_state).desync
                        if value_5 == 0 then
                            value_5 = 90
                            if not (90) then
                                value_5 = (anti_aim_state).desync
                            end
                        else
                            value_5 = (anti_aim_state).desync
                            if value_5 ~= 180 then
                                value_5 = (anti_aim_state).desync
                            else
                                value_5 = 90
                                if not (90) then
                                    value_5 = (anti_aim_state).desync
                                end
                            end
                        end
                        value_4.desync = value_5
                    end
                else
                    value_4 = anti_aim_state
                    value_4.desync = 180
                end
            else
                value_4 = anti_aim_state
                value_4.desync = 0
            end
            return 
        else
            value_4 = player_records
            value_5 = (anti_aim_state).target
            value_4 = (value_4[value_5]).d
            if value_4 ~= 0 then
                value_4 = player_records
                value_5 = (anti_aim_state).target
                value_4 = (value_4[value_5]).m
                value_5 = (script_controls)["Anti-resolver shot amount"]
                if value_4 ~= value_5 then
                    value_4 = anti_aim_state
                    value_5 = player_records
                    value_6 = (anti_aim_state).target
                    value_5 = (value_5[value_6]).d
                    value_4.desync = value_5
                else
                    value_4 = (script_controls)["Anti-resolver on X shot"]
                    if value_4 == "-" then
                        value_4 = anti_aim_state
                        value_5 = player_records
                        value_6 = (anti_aim_state).target
                        value_5 = (value_5[value_6]).d
                        value_4.desync = value_5
                    else
                        value_4 = (script_controls)["Anti-resolver on X shot"]
                        if value_4 ~= "None" then
                            value_4 = (script_controls)["Anti-resolver on X shot"]
                            if not (value_4 ~= "Jitter") then
                                value_4 = anti_aim_state
                                value_4.desync = 180
                            end
                        else
                            value_4 = anti_aim_state
                            value_4.desync = 0
                        end
                    end
                end
                return 
            else
                value_4 = player_records
                value_5 = (anti_aim_state).target
                value_4 = (value_4[value_5]).l
                if value_4 == 0 then
                    value_4 = (script_controls).b
                    value_5 = (anti_aim_state).s_i
                    value_6 = (anti_aim_state).aa
                    value_5 = value_5[value_6]
                    value_4 = value_4[value_5]
                    if value_4 ~= "Off" then
                        value_4 = (script_controls).b
                        value_5 = (anti_aim_state).s_i
                        value_6 = (anti_aim_state).aa
                        value_5 = value_5[value_6]
                        value_4 = value_4[value_5]
                        if value_4 ~= "Jitter" then
                            value_4 = (anti_aim_state).desync
                            if value_4 == 0 then
                                value_4 = anti_aim_state
                                value_4.desync = 90
                            else
                                value_4 = (anti_aim_state).desync
                                if not (value_4 ~= 180) then
                                    value_4 = anti_aim_state
                                    value_4.desync = 90
                                end
                            end
                            value_4 = new_table(256)
                            value_5 = head_coordinates
                            value_6 = (anti_aim_state).target
                            local returned_85 = pack_results(value_5(value_6))
                            for index = 1, returned_85.n do
                                value_4[0 + index] = returned_85[index]
                            end
                            value_5 = yaw_between_points
                            value_6 = value_2[1]
                            value_7 = value_2[2]
                            value_8 = value_4[1]
                            value_9 = value_4[2]
                            value_5 = value_5(value_6, value_7, value_8, value_9)
                            value_6 = angles_to_direction
                            value_8 = value_5 - 90
                            value_6, value_7, value_8 = value_6((0), value_8)
                            value_9 = value_2[1]
                            value_10 = value_6 * 10
                            value_9 = value_9 + value_10
                            value_10 = value_2[2]
                            value_11 = value_7 * 10
                            value_10 = value_10 + value_11
                            value_11 = angles_to_direction
                            value_13 = value_5 + 90
                            value_11, value_12, value_13 = value_11((0), value_13)
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
                            value_20 = estimate_damage_at_offsets
                            value_21 = value_1
                            value_22 = (anti_aim_state).target
                            value_23 = value_9
                            value_24 = value_10
                            value_25 = value_2[3]
                            value_20 = value_20(value_21, value_22, value_23, value_24, value_25)
                            value_21 = estimate_damage_at_offsets
                            value_22 = value_1
                            value_23 = (anti_aim_state).target
                            value_24 = value_14
                            value_25 = value_15
                            value_26 = value_2[3]
                            value_21 = value_21(value_22, value_23, value_24, value_25, value_26)
                            value_22 = estimate_damage_at_offsets
                            value_23 = value_1
                            value_24 = (anti_aim_state).target
                            value_25 = value_16
                            value_26 = value_17
                            value_27 = value_2[3]
                            value_22 = value_22(value_23, value_24, value_25, value_26, value_27)
                            value_23 = estimate_damage_at_offsets
                            value_24 = value_1
                            value_25 = (anti_aim_state).target
                            value_26 = value_18
                            value_27 = value_19
                            value_28 = value_2[3]
                            value_23 = value_23(value_24, value_25, value_26, value_27, value_28)
                            value_24 = ""
                            if value_20 >= value_21 then
                                if value_21 >= value_20 then
                                    if value_22 >= value_23 then
                                        if value_23 >= value_22 then
                                            value_25 = (anti_aim_state).holding_e
                                            if value_25 then
                                                if value_24 ~= "left" then
                                                    if not (value_24 ~= "right") then
                                                        value_25 = anti_aim_state
                                                        value_26 = (script_controls).b
                                                        value_27 = (anti_aim_state).s_i
                                                        value_28 = (anti_aim_state).aa
                                                        value_27 = value_27[value_28]
                                                        value_26 = value_26[value_27]
                                                        if value_26 ~= "Freestanding" then
                                                            value_26 = -90
                                                        else
                                                            value_26 = 90
                                                            if not (90) then
                                                                value_26 = -90
                                                            end
                                                        end
                                                        value_25.desync = value_26
                                                    end
                                                else
                                                    value_25 = anti_aim_state
                                                    value_26 = (script_controls).b
                                                    value_27 = (anti_aim_state).s_i
                                                    value_28 = (anti_aim_state).aa
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
                                                    value_25.desync = value_26
                                                end
                                                return 
                                            else
                                                value_25 = anti_aim_state
                                                value_25.desync = 180
                                                return 
                                            end
                                        else
                                            value_24 = "right"
                                            if value_24 ~= "left" then
                                                if not (value_24 ~= "right") then
                                                    value_25 = anti_aim_state
                                                    value_26 = (script_controls).b
                                                    value_27 = (anti_aim_state).s_i
                                                    value_28 = (anti_aim_state).aa
                                                    value_27 = value_27[value_28]
                                                    value_26 = value_26[value_27]
                                                    if value_26 ~= "Freestanding" then
                                                        value_26 = -90
                                                    else
                                                        value_26 = 90
                                                        if not (90) then
                                                            value_26 = -90
                                                        end
                                                    end
                                                    value_25.desync = value_26
                                                end
                                            else
                                                value_25 = anti_aim_state
                                                value_26 = (script_controls).b
                                                value_27 = (anti_aim_state).s_i
                                                value_28 = (anti_aim_state).aa
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
                                                value_25.desync = value_26
                                            end
                                            return 
                                        end
                                    else
                                        value_24 = "left"
                                        if value_24 ~= "left" then
                                            if not (value_24 ~= "right") then
                                                value_25 = anti_aim_state
                                                value_26 = (script_controls).b
                                                value_27 = (anti_aim_state).s_i
                                                value_28 = (anti_aim_state).aa
                                                value_27 = value_27[value_28]
                                                value_26 = value_26[value_27]
                                                if value_26 ~= "Freestanding" then
                                                    value_26 = -90
                                                else
                                                    value_26 = 90
                                                    if not (90) then
                                                        value_26 = -90
                                                    end
                                                end
                                                value_25.desync = value_26
                                            end
                                        else
                                            value_25 = anti_aim_state
                                            value_26 = (script_controls).b
                                            value_27 = (anti_aim_state).s_i
                                            value_28 = (anti_aim_state).aa
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
                                            value_25.desync = value_26
                                        end
                                        return 
                                    end
                                else
                                    value_24 = "right"
                                    if value_24 ~= "left" then
                                        if not (value_24 ~= "right") then
                                            value_25 = anti_aim_state
                                            value_26 = (script_controls).b
                                            value_27 = (anti_aim_state).s_i
                                            value_28 = (anti_aim_state).aa
                                            value_27 = value_27[value_28]
                                            value_26 = value_26[value_27]
                                            if value_26 ~= "Freestanding" then
                                                value_26 = -90
                                            else
                                                value_26 = 90
                                                if not (90) then
                                                    value_26 = -90
                                                end
                                            end
                                            value_25.desync = value_26
                                        end
                                    else
                                        value_25 = anti_aim_state
                                        value_26 = (script_controls).b
                                        value_27 = (anti_aim_state).s_i
                                        value_28 = (anti_aim_state).aa
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
                                        value_25.desync = value_26
                                    end
                                    return 
                                end
                            else
                                value_24 = "left"
                                if value_24 ~= "left" then
                                    if not (value_24 ~= "right") then
                                        value_25 = anti_aim_state
                                        value_26 = (script_controls).b
                                        value_27 = (anti_aim_state).s_i
                                        value_28 = (anti_aim_state).aa
                                        value_27 = value_27[value_28]
                                        value_26 = value_26[value_27]
                                        if value_26 ~= "Freestanding" then
                                            value_26 = -90
                                        else
                                            value_26 = 90
                                            if not (90) then
                                                value_26 = -90
                                            end
                                        end
                                        value_25.desync = value_26
                                    end
                                else
                                    value_25 = anti_aim_state
                                    value_26 = (script_controls).b
                                    value_27 = (anti_aim_state).s_i
                                    value_28 = (anti_aim_state).aa
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
                                    value_25.desync = value_26
                                end
                                return 
                            end
                        else
                            value_4 = anti_aim_state
                            value_4.desync = 180
                            return 
                        end
                    else
                        value_4 = anti_aim_state
                        value_4.desync = 0
                        return 
                    end
                else
                    value_4 = anti_aim_state
                    value_5 = player_records
                    value_6 = (anti_aim_state).target
                    value_5 = (value_5[value_6]).l
                    value_4.desync = value_5
                    return 
                end
            end
        end
    end
    reset_player_state = function(event)
        local value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8
        if not (event ~= nil) then
            event = false
        end
        do
            local loop_has_value_6 = true
            value_1 = 0 + (1)
            value_2 = 0 + (64)
            value_3 = 0 + (1)
            if (value_3 > 0 and value_1 > value_2) or (value_3 <= 0 and value_1 < value_2) then
                value_1 = value_1 + value_3
                loop_has_value_6 = (value_3 > 0 and value_1 <= value_2) or (value_3 <= 0 and value_1 >= value_2)
                if loop_has_value_6 then
                    value_4 = value_1
                end
            else
                value_4 = value_1
            end
            while loop_has_value_6 do
                value_5 = ((player_records)[value_4]).d
                value_6 = player_records
                value_7 = new_table(256)
                value_8 = new_table(256)
                value_7.s = value_8
                value_8 = new_table(256)
                value_7.h = value_8
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
                value_6[value_4] = value_7
                value_1 = value_1 + value_3
                loop_has_value_6 = (value_3 > 0 and value_1 <= value_2) or (value_3 <= 0 and value_1 >= value_2)
                if loop_has_value_6 then
                    value_4 = value_1
                end
            end
        end
        return 
    end
    handle_use_key = function(command, other)
        local value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11, value_12, value_13
        local value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23, value_24
        value_2 = (key_state)((69))
        if not value_2 then
            return (false)
        else
            value_2 = 100
            value_3 = ((get_all_entities)(("CPlantedC4")))[1]
            if not (value_3 == nil) then
                value_4 = new_table(256)
                value_5 = get_prop
                value_6 = value_3
                value_7 = "m_vecOrigin"
                local returned_15 = pack_results(value_5(value_6, ("m_vecOrigin")))
                for index = 1, returned_15.n do
                    value_4[0 + index] = returned_15[index]
                end
                if not (value_4 == nil) then
                    value_5 = new_table(256)
                    value_6 = get_prop
                    value_7 = command
                    value_8 = "m_vecOrigin"
                    local returned_22 = pack_results(value_6(value_7, ("m_vecOrigin")))
                    for index = 1, returned_22.n do
                        value_5[0 + index] = returned_22[index]
                    end
                    value_6 = math_abs
                    value_7 = signed_coordinate_delta
                    value_8 = value_5
                    value_9 = value_4
                    local returned_28 = pack_results(value_7(value_8, value_9))
                    value_6 = value_6(unpack_results(returned_28, 1, returned_28.n))
                    value_2 = value_6
                end
            end
            value_4 = get_prop
            value_5 = command
            value_4 = value_4(value_5, ("m_iTeamNum"))
            if value_4 ~= 3 then
                value_5 = false
            else
                if value_2 < 62 then
                    value_5 = true
                else
                    value_5 = false
                end
            end
            value_6 = eye_position
            value_6, value_7, value_8 = value_6()
            value_9 = camera_angles
            value_9, value_10 = value_9()
            value_11 = math_sin
            value_12 = math_rad
            value_13 = value_9
            local returned_46 = pack_results(value_12(value_13))
            value_11 = value_11(unpack_results(returned_46, 1, returned_46.n))
            value_12 = math_cos
            value_13 = math_rad
            value_14 = value_9
            local returned_51 = pack_results(value_13(value_14))
            value_12 = value_12(unpack_results(returned_51, 1, returned_51.n))
            value_13 = math_sin
            value_14 = math_rad
            value_15 = value_10
            local returned_56 = pack_results(value_14(value_15))
            value_13 = value_13(unpack_results(returned_56, 1, returned_56.n))
            value_14 = math_cos
            value_15 = math_rad
            value_16 = value_10
            local returned_61 = pack_results(value_15(value_16))
            value_14 = value_14(unpack_results(returned_61, 1, returned_61.n))
            value_15 = new_table(3)
            value_16 = value_12 * value_14
            value_17 = value_12 * value_13
            value_18 = -(value_11)
            value_15[1] = value_16
            value_15[2] = value_17
            value_15[3] = value_18
            value_16 = trace_line
            value_17 = command
            value_18 = value_6
            value_19 = value_7
            value_20 = value_8
            value_21 = (value_15[1]) * 8192
            value_21 = value_6 + value_21
            value_22 = (value_15[2]) * 8192
            value_22 = value_7 + value_22
            value_23 = (value_15[3]) * 8192
            value_23 = value_8 + value_23
            value_16, value_17 = value_16(value_17, value_18, value_19, value_20, value_21, value_22, value_23)
            value_18 = true
            if not (value_17 == nil) then
                value_20 = #((anti_aim_state).classnames)
                do
                    local loop_has_value_90 = true
                    value_19 = 0 + (0)
                    value_20 = 0 + value_20
                    value_21 = 0 + (1)
                    if (value_21 > 0 and value_19 > value_20) or (value_21 <= 0 and value_19 < value_20) then
                        value_19 = value_19 + value_21
                        loop_has_value_90 = (value_21 > 0 and value_19 <= value_20) or (value_21 <= 0 and value_19 >= value_20)
                        if loop_has_value_90 then
                            value_22 = value_19
                        end
                    else
                        value_22 = value_19
                    end
                    while loop_has_value_90 do
                        value_23 = get_classname
                        value_24 = value_17
                        value_23 = value_23(value_24)
                        value_24 = ((anti_aim_state).classnames)[value_22]
                        if not (value_23 ~= value_24) then
                            value_18 = false
                        end
                        value_19 = value_19 + value_21
                        loop_has_value_90 = (value_21 > 0 and value_19 <= value_20) or (value_21 <= 0 and value_19 >= value_20)
                        if loop_has_value_90 then
                            value_22 = value_19
                        end
                    end
                end
            end
            if not (value_18) then
                if not (value_5) then
                    other.in_use = 0
                end
            end
            return (true)
        end
    end
    update_manual_and_freestanding = function(command)
        local value_1, value_2, value_3
        value_1 = ui_set
        value_2 = ((native_controls).yaw)[1]
        value_3 = (anti_aim_state).holding_e
        if not value_3 then
            value_3 = "180"
        else
            value_3 = "Off"
            if not ("Off") then
                value_3 = "180"
            end
        end
        value_1(value_2, value_3)
        value_1 = ui_set
        value_2 = (native_controls).pitch
        value_3 = (anti_aim_state).holding_e
        if not value_3 then
            value_3 = "Default"
        else
            value_3 = "Off"
            if not ("Off") then
                value_3 = "Default"
            end
        end
        value_1(value_2, value_3)
        value_1 = contains_value
        value_2 = (script_controls).s
        value_1 = value_1(value_2, ("Manual AA"))
        if not (not value_1) then
            value_1 = ui_get
            value_2 = (script_controls).ml
            value_1 = value_1(value_2)
            if not value_1 then
                value_1 = ui_get
                value_2 = (script_controls).mr
                value_1 = value_1(value_2)
                if not value_1 then
                    value_1 = ui_get
                    value_2 = (script_controls).mf
                    value_1 = value_1(value_2)
                    if not value_1 then
                        value_1 = ((anti_aim_state).dir).time
                        value_2 = (curtime)()
                        if not (value_2 >= value_1) then
                            value_1 = (anti_aim_state).dir
                            value_2 = (curtime)()
                            value_1.time = value_2
                        end
                    else
                        value_1 = (((anti_aim_state).dir).time) + 0.2
                        value_2 = (curtime)()
                        if value_1 >= value_2 then
                            value_1 = ((anti_aim_state).dir).time
                            value_2 = (curtime)()
                            if not (value_2 >= value_1) then
                                value_1 = (anti_aim_state).dir
                                value_2 = (curtime)()
                                value_1.time = value_2
                            end
                        else
                            value_1 = (anti_aim_state).dir
                            value_2 = ((anti_aim_state).dir).manual
                            if value_2 ~= 180 then
                                value_2 = 180
                            else
                                value_2 = 0
                                if not (0) then
                                    value_2 = 180
                                end
                            end
                            value_1.manual = value_2
                            value_1 = (anti_aim_state).dir
                            value_2 = (curtime)()
                            value_1.time = value_2
                        end
                    end
                else
                    value_1 = (((anti_aim_state).dir).time) + 0.2
                    value_2 = (curtime)()
                    if value_1 >= value_2 then
                        value_1 = ui_get
                        value_2 = (script_controls).mf
                        value_1 = value_1(value_2)
                        if not value_1 then
                            value_1 = ((anti_aim_state).dir).time
                            value_2 = (curtime)()
                            if not (value_2 >= value_1) then
                                value_1 = (anti_aim_state).dir
                                value_2 = (curtime)()
                                value_1.time = value_2
                            end
                        else
                            value_1 = (((anti_aim_state).dir).time) + 0.2
                            value_2 = (curtime)()
                            if value_1 >= value_2 then
                                value_1 = ((anti_aim_state).dir).time
                                value_2 = (curtime)()
                                if not (value_2 >= value_1) then
                                    value_1 = (anti_aim_state).dir
                                    value_2 = (curtime)()
                                    value_1.time = value_2
                                end
                            else
                                value_1 = (anti_aim_state).dir
                                value_2 = ((anti_aim_state).dir).manual
                                if value_2 ~= 180 then
                                    value_2 = 180
                                else
                                    value_2 = 0
                                    if not (0) then
                                        value_2 = 180
                                    end
                                end
                                value_1.manual = value_2
                                value_1 = (anti_aim_state).dir
                                value_2 = (curtime)()
                                value_1.time = value_2
                            end
                        end
                    else
                        value_1 = (anti_aim_state).dir
                        value_2 = ((anti_aim_state).dir).manual
                        if value_2 ~= 90 then
                            value_2 = 90
                        else
                            value_2 = 0
                            if not (0) then
                                value_2 = 90
                            end
                        end
                        value_1.manual = value_2
                        value_1 = (anti_aim_state).dir
                        value_2 = (curtime)()
                        value_1.time = value_2
                    end
                end
            else
                value_1 = (((anti_aim_state).dir).time) + 0.2
                value_2 = (curtime)()
                if value_1 >= value_2 then
                    value_1 = ui_get
                    value_2 = (script_controls).mr
                    value_1 = value_1(value_2)
                    if not value_1 then
                        value_1 = ui_get
                        value_2 = (script_controls).mf
                        value_1 = value_1(value_2)
                        if not value_1 then
                            value_1 = ((anti_aim_state).dir).time
                            value_2 = (curtime)()
                            if not (value_2 >= value_1) then
                                value_1 = (anti_aim_state).dir
                                value_2 = (curtime)()
                                value_1.time = value_2
                            end
                        else
                            value_1 = (((anti_aim_state).dir).time) + 0.2
                            value_2 = (curtime)()
                            if value_1 >= value_2 then
                                value_1 = ((anti_aim_state).dir).time
                                value_2 = (curtime)()
                                if not (value_2 >= value_1) then
                                    value_1 = (anti_aim_state).dir
                                    value_2 = (curtime)()
                                    value_1.time = value_2
                                end
                            else
                                value_1 = (anti_aim_state).dir
                                value_2 = ((anti_aim_state).dir).manual
                                if value_2 ~= 180 then
                                    value_2 = 180
                                else
                                    value_2 = 0
                                    if not (0) then
                                        value_2 = 180
                                    end
                                end
                                value_1.manual = value_2
                                value_1 = (anti_aim_state).dir
                                value_2 = (curtime)()
                                value_1.time = value_2
                            end
                        end
                    else
                        value_1 = (((anti_aim_state).dir).time) + 0.2
                        value_2 = (curtime)()
                        if value_1 >= value_2 then
                            value_1 = ui_get
                            value_2 = (script_controls).mf
                            value_1 = value_1(value_2)
                            if not value_1 then
                                value_1 = ((anti_aim_state).dir).time
                                value_2 = (curtime)()
                                if not (value_2 >= value_1) then
                                    value_1 = (anti_aim_state).dir
                                    value_2 = (curtime)()
                                    value_1.time = value_2
                                end
                            else
                                value_1 = (((anti_aim_state).dir).time) + 0.2
                                value_2 = (curtime)()
                                if value_1 >= value_2 then
                                    value_1 = ((anti_aim_state).dir).time
                                    value_2 = (curtime)()
                                    if not (value_2 >= value_1) then
                                        value_1 = (anti_aim_state).dir
                                        value_2 = (curtime)()
                                        value_1.time = value_2
                                    end
                                else
                                    value_1 = (anti_aim_state).dir
                                    value_2 = ((anti_aim_state).dir).manual
                                    if value_2 ~= 180 then
                                        value_2 = 180
                                    else
                                        value_2 = 0
                                        if not (0) then
                                            value_2 = 180
                                        end
                                    end
                                    value_1.manual = value_2
                                    value_1 = (anti_aim_state).dir
                                    value_2 = (curtime)()
                                    value_1.time = value_2
                                end
                            end
                        else
                            value_1 = (anti_aim_state).dir
                            value_2 = ((anti_aim_state).dir).manual
                            if value_2 ~= 90 then
                                value_2 = 90
                            else
                                value_2 = 0
                                if not (0) then
                                    value_2 = 90
                                end
                            end
                            value_1.manual = value_2
                            value_1 = (anti_aim_state).dir
                            value_2 = (curtime)()
                            value_1.time = value_2
                        end
                    end
                else
                    value_1 = (anti_aim_state).dir
                    value_2 = ((anti_aim_state).dir).manual
                    if value_2 ~= -90 then
                        value_2 = -90
                    else
                        value_2 = 0
                        if not (0) then
                            value_2 = -90
                        end
                    end
                    value_1.manual = value_2
                    value_1 = (anti_aim_state).dir
                    value_2 = (curtime)()
                    value_1.time = value_2
                end
            end
            value_1 = ((anti_aim_state).dir).manual
            value_2 = ((anti_aim_state).stored_dir).manual
            if not (value_1 == value_2) then
                value_1 = ui_set
                value_2 = ((native_controls).yaw)[2]
                value_3 = ((anti_aim_state).dir).manual
                value_1(value_2, value_3)
                value_1 = (anti_aim_state).stored_dir
                value_2 = ((anti_aim_state).dir).manual
                value_1.manual = value_2
            end
            value_1 = ui_set
            value_2 = ((native_controls).yaw)[2]
            value_3 = ((anti_aim_state).dir).manual
            value_1(value_2, value_3)
        end
        value_1 = (anti_aim_state).dir
        value_2 = contains_value
        value_3 = (script_controls).s
        value_2 = value_2(value_3, ("Edge yaw"))
        if not (not value_2) then
            value_2 = ui_get
            value_3 = (script_controls).ey
            value_2 = value_2(value_3)
            if not (not value_2) then
                value_2 = not ((anti_aim_state).holding_e)
            end
        end
        value_1.edge = value_2
        value_1 = (anti_aim_state).dir
        value_2 = contains_value
        value_3 = (script_controls).s
        value_2 = value_2(value_3, ("Freestanding"))
        if not (not value_2) then
            value_2 = ui_get
            value_3 = (script_controls).fs
            value_2 = value_2(value_3)
            if not (not value_2) then
                value_2 = not ((anti_aim_state).holding_e)
            end
        end
        value_1.freestand = value_2
        value_1 = ((anti_aim_state).dir).freestand
        value_2 = ((anti_aim_state).stored_dir).freestand
        if not (value_1 == value_2) then
            value_1 = ui_set
            value_2 = ((native_controls).freestand)[1]
            value_3 = ((anti_aim_state).dir).freestand
            if not value_3 then
                value_3 = "-"
            else
                value_3 = "Default"
                if not ("Default") then
                    value_3 = "-"
                end
            end
            value_1(value_2, value_3)
            value_1 = ui_set
            value_2 = ((native_controls).freestand)[2]
            value_1(value_2, ("Always on"))
            value_1 = (anti_aim_state).stored_dir
            value_2 = ((anti_aim_state).dir).freestand
            value_1.freestand = value_2
        end
        value_1 = ((anti_aim_state).dir).edge
        value_2 = ((anti_aim_state).stored_dir).edge
        if not (value_1 == value_2) then
            value_1 = ui_set
            value_2 = (native_controls).edgeyaw
            value_3 = ((anti_aim_state).dir).edge
            value_1(value_2, value_3)
            value_1 = (anti_aim_state).stored_dir
            value_2 = ((anti_aim_state).dir).edge
            value_1.edge = value_2
        end
        return 
    end
    point_on_circle = function(center_x, center_y, angle, radius)
        local value_4, value_5, value_6, value_7
        value_4 = math_cos
        value_5 = math_rad
        value_6 = angle
        local returned_4 = pack_results(value_5(value_6))
        value_4 = ((value_4(unpack_results(returned_4, 1, returned_4.n))) * radius) + center_x
        value_5 = math_sin
        value_6 = math_rad
        value_7 = angle
        local returned_11 = pack_results(value_6(value_7))
        value_5 = ((value_5(unpack_results(returned_11, 1, returned_11.n))) * radius) + center_y
        return value_4, value_5
    end
    draw_indicator_triangle = function(argument_1, argument_2, argument_3, argument_4, argument_5, argument_6, argument_7, argument_8, argument_9, argument_10, argument_11, argument_12, argument_13)
        local value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23, value_24
        local value_25, value_26, value_27, value_28, value_29, value_30, value_31, value_32, value_33
        value_13 = point_on_circle
        value_14 = argument_1
        value_15 = argument_2 + 4
        value_16 = argument_11
        value_13, value_14 = value_13(value_14, value_15, value_16, (45))
        value_15 = point_on_circle
        value_16 = argument_1
        value_17 = argument_2 + 4
        value_18 = argument_12 / 3
        value_18 = argument_11 + value_18
        value_19 = argument_12 / 4
        value_19 = 45 - value_19
        value_15, value_16 = value_15(value_16, value_17, value_18, value_19)
        value_17 = point_on_circle
        value_18 = argument_1
        value_19 = argument_2 + 4
        value_20 = argument_11
        value_21 = argument_12 / 5
        value_21 = 45 - value_21
        value_17, value_18 = value_17(value_18, value_19, value_20, value_21)
        value_19 = point_on_circle
        value_20 = argument_1
        value_21 = argument_2 + 4
        value_22 = argument_11
        value_23 = argument_12 / 5
        value_23 = 45 - value_23
        value_19, value_20 = value_19(value_20, value_21, value_22, value_23)
        value_21 = point_on_circle
        value_22 = argument_1
        value_23 = argument_2 + 4
        value_24 = argument_12 / 3
        value_24 = argument_11 - value_24
        value_25 = argument_12 / 4
        value_25 = 45 - value_25
        value_21, value_22 = value_21(value_22, value_23, value_24, value_25)
        value_23 = draw_triangle
        value_24 = value_13
        value_25 = value_14
        value_26 = value_15
        value_27 = value_16
        value_28 = value_17
        value_29 = value_18
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
        value_23(value_24, value_25, value_26, value_27, value_28, value_29, value_30, value_31, value_32, value_33)
        value_23 = draw_triangle
        value_24 = value_13
        value_25 = value_14
        value_26 = value_19
        value_27 = value_20
        value_28 = value_21
        value_29 = value_22
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
        value_23(value_24, value_25, value_26, value_27, value_28, value_29, value_30, value_31, value_32, value_33)
        value_23 = draw_line
        value_24 = value_13
        value_25 = value_14
        value_26 = value_19
        value_27 = value_20
        value_23(value_24, value_25, value_26, value_27, (0), (0), (0), (200))
        return 
    end
    apply_body_yaw = function(command)
        local value_1, value_2, value_3, value_4, value_5, value_6
        value_1 = (get_local_player)()
        value_2 = (anti_aim_state).rec
        value_3 = (#((anti_aim_state).rec)) + 1
        value_4 = new_table(256)
        value_5 = head_coordinates
        value_6 = value_1
        local returned_12 = pack_results(value_5(value_6))
        for index = 1, returned_12.n do
            value_4[0 + index] = returned_12[index]
        end
        value_2[value_3] = value_4
        value_2 = #((anti_aim_state).rec)
        if not (28 >= value_2) then
            value_2 = table_remove
            value_3 = (anti_aim_state).rec
            value_2(value_3, (1))
        end
        value_2 = classify_movement
        value_3 = value_1
        value_4 = command
        value_2(value_3, value_4)
        value_2 = update_target_anti_aim
        value_3 = value_1
        value_2(value_3)
        value_2 = anti_aim_state
        value_3 = handle_use_key
        value_4 = value_1
        value_5 = command
        value_3 = value_3(value_4, value_5)
        value_2.holding_e = value_3
        value_2 = update_manual_and_freestanding
        value_3 = value_1
        value_4 = (anti_aim_state).holding_e
        value_2(value_3, value_4)
        value_2 = ui_set
        value_3 = ((native_controls).bodyyaw)[1]
        value_4 = (anti_aim_state).desync
        if value_4 ~= 0 then
            value_4 = (anti_aim_state).desync
            if value_4 ~= 180 then
                value_4 = "Static"
            else
                value_4 = contains_value
                value_5 = (script_controls).s
                value_4 = value_4(value_5, ("Jitter when not networked"))
                if not value_4 then
                    value_4 = "Static"
                else
                    value_4 = "Jitter"
                    if not ("Jitter") then
                        value_4 = "Static"
                    end
                end
            end
        else
            value_4 = "Off"
            if not ("Off") then
                value_4 = (anti_aim_state).desync
                if value_4 ~= 180 then
                    value_4 = "Static"
                else
                    value_4 = contains_value
                    value_5 = (script_controls).s
                    value_4 = value_4(value_5, ("Jitter when not networked"))
                    if not value_4 then
                        value_4 = "Static"
                    else
                        value_4 = "Jitter"
                        if not ("Jitter") then
                            value_4 = "Static"
                        end
                    end
                end
            end
        end
        value_2(value_3, value_4)
        value_2 = ui_set
        value_3 = ((native_controls).bodyyaw)[2]
        value_4 = (anti_aim_state).desync
        if value_4 ~= 180 then
            value_4 = (anti_aim_state).holding_e
            if not value_4 then
                value_4 = (anti_aim_state).desync
            else
                value_4 = -((anti_aim_state).desync)
                if not (value_4) then
                    value_4 = (anti_aim_state).desync
                end
            end
        else
            value_4 = 0
            if not (0) then
                value_4 = (anti_aim_state).holding_e
                if not value_4 then
                    value_4 = (anti_aim_state).desync
                else
                    value_4 = -((anti_aim_state).desync)
                    if not (value_4) then
                        value_4 = (anti_aim_state).desync
                    end
                end
            end
        end
        value_2(value_3, value_4)
        value_2 = ui_set
        value_3 = (native_controls).fakeyawlimit
        value_4 = (script_controls).r
        value_5 = (anti_aim_state).s_i
        value_6 = (anti_aim_state).aa
        value_5 = value_5[value_6]
        value_4 = value_4[value_5]
        value_2(value_3, value_4)
        value_2 = set_native_ui_visible
        value_2((false))
        return 
    end
    on_bullet_impact = function(event)
        local value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9
        value_1 = (get_local_player)()
        value_2 = userid_to_entindex
        value_3 = event.userid
        value_2 = value_2(value_3)
        value_3 = is_enemy
        value_4 = value_2
        value_3 = value_3(value_4)
        if not value_3 then
            return 
        else
            value_3 = is_alive
            value_4 = value_1
            value_3 = value_3(value_4)
            if not value_3 then
                return 
            else
                value_3 = is_valid_player
                value_4 = value_2
                value_3 = value_3(value_4)
                if value_3 then
                    value_3 = target_info
                    value_4 = value_2
                    value_5 = event
                    value_3 = value_3(value_4, value_5)
                    value_4 = target_record_info
                    value_5 = value_3
                    value_6 = (anti_aim_state).ls
                    value_7 = value_2
                    value_8 = value_1
                    value_9 = event
                    value_4 = value_4(value_5, value_6, value_7, value_8, value_9)
                    if not (not value_4) then
                        value_4 = #(((player_records)[value_2]).s)
                        if 0 >= value_4 then
                            value_4 = (#(((player_records)[value_2]).s)) + 1
                        else
                            value_4 = ((player_records)[value_2]).s
                            value_5 = #(((player_records)[value_2]).s)
                            value_4 = (value_4[value_5]).t
                            value_5 = (curtime)()
                            if value_4 ~= value_5 then
                                value_4 = (#(((player_records)[value_2]).s)) + 1
                            else
                                value_4 = #(((player_records)[value_2]).s)
                                if not (value_4) then
                                    value_4 = (#(((player_records)[value_2]).s)) + 1
                                end
                            end
                        end
                        value_5 = (anti_aim_state).desync
                        if value_5 == 0 then
                            value_5 = true
                        else
                            value_5 = (anti_aim_state).desync
                            if value_5 == 180 then
                                value_5 = true
                            else
                                value_5 = (script_controls)["Detect missed angle"]
                            end
                        end
                        value_6 = (anti_aim_state).desync
                        if value_6 ~= 90 then
                            value_6 = 90
                        else
                            value_6 = -90
                            if not (-90) then
                                value_6 = 90
                            end
                        end
                        if not (not value_5) then
                            value_7 = math_abs
                            value_8 = value_3
                            value_7 = value_7(value_8)
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
                                value_7 = anti_aim_state
                                value_6 = value_7.desync
                            end
                        end
                        value_7 = ((player_records)[value_2]).s
                        value_8 = new_table(256)
                        value_9 = (tickcount)()
                        value_8.t = value_9
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
        local value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9
        value_1 = (get_local_player)()
        value_2 = userid_to_entindex
        value_3 = event.userid
        value_2 = value_2(value_3)
        value_3 = userid_to_entindex
        value_4 = event.attacker
        value_3 = value_3(value_4)
        value_4 = is_enemy
        value_5 = value_3
        value_4 = value_4(value_5)
        if not value_4 then
            return 
        else
            value_4 = is_alive
            value_5 = value_1
            value_4 = value_4(value_5)
            if value_4 then
                value_5 = #((anti_aim_state).nonweapons)
                do
                    local loop_has_value_23 = true
                    value_4 = 0 + (1)
                    value_5 = 0 + value_5
                    value_6 = 0 + (1)
                    if (value_6 > 0 and value_4 > value_5) or (value_6 <= 0 and value_4 < value_5) then
                        value_4 = value_4 + value_6
                        loop_has_value_23 = (value_6 > 0 and value_4 <= value_5) or (value_6 <= 0 and value_4 >= value_5)
                        if loop_has_value_23 then
                            value_7 = value_4
                        end
                    else
                        value_7 = value_4
                    end
                    while loop_has_value_23 do
                        value_8 = event.weapon
                        value_9 = ((anti_aim_state).nonweapons)[value_7]
                        if not (value_8 ~= value_9) then
                            return 
                        end
                        value_4 = value_4 + value_6
                        loop_has_value_23 = (value_6 > 0 and value_4 <= value_5) or (value_6 <= 0 and value_4 >= value_5)
                        if loop_has_value_23 then
                            value_7 = value_4
                        end
                    end
                end
                value_4 = #(((player_records)[value_3]).h)
                if 0 >= value_4 then
                    value_4 = (#(((player_records)[value_3]).h)) + 1
                else
                    value_4 = #(((player_records)[value_3]).h)
                    if not (value_4) then
                        value_4 = (#(((player_records)[value_3]).h)) + 1
                    end
                end
                value_5 = ((player_records)[value_3]).h
                value_6 = new_table(256)
                value_7 = (tickcount)()
                value_6.t = value_7
                value_7 = environment.new_angle
                value_6.d = value_7
                value_7 = event.hitgroup
                value_6.h = value_7
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
        value_1 = (get_local_player)()
        value_2 = userid_to_entindex
        value_3 = event.userid
        value_2 = value_2(value_3)
        if not (value_2 ~= value_1) then
            value_3 = reset_player_state
            value_3((true))
        end
        return 
    end
    draw_keybind_indicators = function()
        local value_0, value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11
        local value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23
        local value_24, value_25, value_26, value_27, value_28, value_30
        value_0 = (get_local_player)()
        value_1 = update_shot_history
        value_2 = value_0
        value_1(value_2)
        value_1 = is_alive
        value_2 = value_0
        value_1 = value_1(value_2)
        if value_1 then
            value_1 = new_table(256)
            value_2 = screen_size
            local returned_13 = pack_results(value_2())
            for index = 1, returned_13.n do
                value_1[0 + index] = returned_13[index]
            end
            value_2 = new_table(2)
            value_3 = (value_1[1]) / 2
            value_4 = (value_1[2]) / 2
            value_2[1] = value_3
            value_2[2] = value_4
            value_3 = ui_get
            value_4 = ((script_controls).clr)[2]
            value_3, value_4, value_5, value_6 = value_3(value_4)
            value_7 = ui_get
            value_8 = ((script_controls).clr2)[2]
            value_7, value_8, value_9, value_10 = value_7(value_8)
            value_11 = get_prop
            value_12 = value_0
            value_11 = ((value_11(value_12, ("m_flPoseParameter"), (11))) * 120) - 60
            value_12 = (anti_aim_state).holding_e
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
            value_13 = contains_value
            value_14 = (script_controls).s
            value_13 = value_13(value_14, ("AA indicator"))
            value_16, value_17, value_18, value_19 = nil
            if not (not value_13) then
                value_13 = new_table(256)
                value_14 = camera_angles
                local returned_54 = pack_results(value_14())
                for index = 1, returned_54.n do
                    value_13[0 + index] = returned_54[index]
                end
                value_14 = new_table(256)
                value_15 = hitbox_position
                value_16 = value_0
                value_17 = "head_0"
                local returned_60 = pack_results(value_15(value_16, ("head_0")))
                for index = 1, returned_60.n do
                    value_14[0 + index] = returned_60[index]
                end
                value_15 = new_table(256)
                value_16 = hitbox_position
                value_17 = value_0
                value_18 = "pelvis"
                local returned_66 = pack_results(value_16(value_17, ("pelvis")))
                for index = 1, returned_66.n do
                    value_15[0 + index] = returned_66[index]
                end
                value_16 = normalize_yaw
                value_17 = yaw_between_points
                value_18 = value_15[1]
                value_19 = value_15[2]
                value_20 = value_14[1]
                value_21 = value_14[2]
                value_17 = value_17(value_18, value_19, value_20, value_21)
                value_18 = value_11 / 2
                value_17 = value_17 - value_18
                value_18 = value_13[2]
                value_17 = (value_17 - value_18) + 120
                value_16 = value_16(value_17)
                value_17 = draw_indicator_triangle
                value_18 = value_2[1]
                value_19 = value_2[2]
                value_20 = value_3
                value_21 = value_4
                value_22 = value_5
                value_23 = value_6
                value_24 = value_7
                value_25 = value_8
                value_26 = value_9
                value_28 = value_11 / 1.5
                value_28 = (value_16 + value_28) * -1
                if value_11 < 0 then
                    value_30 = true
                else
                    value_30 = false
                end
                value_17(value_18, value_19, value_20, value_21, value_22, value_23, value_24, value_25, value_26, (255), value_28, (60), value_30)
                value_12 = 48
            end
            value_13 = draw_text
            value_14 = (value_2[1]) - 27
            value_15 = (value_2[2]) + value_12
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
            value_13(value_14, value_15, value_16, value_17, value_18, value_19, ("b"), (0), ("predi"))
            value_13 = draw_text
            value_14 = value_2[1]
            value_15 = (value_2[2]) + value_12
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
            value_13(value_14, value_15, value_16, value_17, value_18, value_19, ("b"), (0), ("ction°"))
            value_13 = contains_value
            value_14 = (script_controls).s
            value_13 = value_13(value_14, ("Keybind indicator"))
            if not (not value_13) then
                value_13 = new_table(256)
                value_14 = contains_value
                value_15 = (script_controls).k
                value_14 = value_14(value_15, ("Double tap"))
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "DT"
                    value_16 = ui_get
                    value_17 = ((native_controls).dt)[1]
                    value_16 = value_16(value_17)
                    if not (not value_16) then
                        value_16 = ui_get
                        value_17 = ((native_controls).dt)[2]
                        value_16 = value_16(value_17)
                    end
                    value_15.e = value_16
                    value_13[value_14] = value_15
                end
                value_14 = contains_value
                value_15 = (script_controls).k
                value_14 = value_14(value_15, ("Onshot Anti-Aim"))
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "OSAA"
                    value_16 = ui_get
                    value_17 = ((native_controls).os)[1]
                    value_16 = value_16(value_17)
                    if not (not value_16) then
                        value_16 = ui_get
                        value_17 = ((native_controls).os)[2]
                        value_16 = value_16(value_17)
                    end
                    value_15.e = value_16
                    value_13[value_14] = value_15
                end
                value_14 = contains_value
                value_15 = (script_controls).k
                value_14 = value_14(value_15, ("Force body aim"))
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "BAIM"
                    value_16 = ui_get
                    value_17 = (native_controls).forcebaim
                    value_16 = value_16(value_17)
                    value_15.e = value_16
                    value_13[value_14] = value_15
                end
                value_14 = contains_value
                value_15 = (script_controls).k
                value_14 = value_14(value_15, ("Force safe point"))
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "SAFE"
                    value_16 = ui_get
                    value_17 = (native_controls).safepoint
                    value_16 = value_16(value_17)
                    value_15.e = value_16
                    value_13[value_14] = value_15
                end
                value_14 = contains_value
                value_15 = (script_controls).k
                value_14 = value_14(value_15, ("Edge yaw"))
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "EDGE"
                    value_16 = ui_get
                    value_17 = (native_controls).edgeyaw
                    value_16 = value_16(value_17)
                    value_15.e = value_16
                    value_13[value_14] = value_15
                end
                value_14 = contains_value
                value_15 = (script_controls).k
                value_14 = value_14(value_15, ("Freestanding"))
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "FREESTAND"
                    value_16 = contains_value
                    value_17 = ((native_controls).freestand)[1]
                    value_16 = value_16(value_17, ("Default"))
                    if not (not value_16) then
                        value_16 = ui_get
                        value_17 = ((native_controls).freestand)[2]
                        value_16 = value_16(value_17)
                    end
                    value_15.e = value_16
                    value_13[value_14] = value_15
                end
                value_14 = contains_value
                value_15 = (script_controls).k
                value_14 = value_14(value_15, ("Quick peek"))
                if not (not value_14) then
                    value_14 = (#value_13) + 1
                    value_15 = new_table(256)
                    value_15.t = "QUICKPEEK"
                    value_16 = ui_get
                    value_17 = ((native_controls).quickpeek)[1]
                    value_16 = value_16(value_17)
                    if not (not value_16) then
                        value_16 = ui_get
                        value_17 = ((native_controls).quickpeek)[2]
                        value_16 = value_16(value_17)
                    end
                    value_15.e = value_16
                    value_13[value_14] = value_15
                end
                value_15 = #value_13
                do
                    local loop_has_value_293 = true
                    value_14 = 0 + (1)
                    value_15 = 0 + value_15
                    value_16 = 0 + (1)
                    if (value_16 > 0 and value_14 > value_15) or (value_16 <= 0 and value_14 < value_15) then
                        value_14 = value_14 + value_16
                        loop_has_value_293 = (value_16 > 0 and value_14 <= value_15) or (value_16 <= 0 and value_14 >= value_15)
                        if loop_has_value_293 then
                            value_17 = value_14
                        end
                    else
                        value_17 = value_14
                    end
                    while loop_has_value_293 do
                        value_18 = draw_text
                        value_19 = (value_2[1]) - 1
                        value_20 = ((value_2[2]) + value_12) + 12
                        value_21 = value_17 * 11
                        value_20 = value_20 + value_21
                        value_21 = (value_13[value_17]).e
                        if not value_21 then
                            value_21 = value_7
                        else
                            if value_3 then
                                value_21 = value_3
                            else
                                value_21 = value_7
                            end
                        end
                        value_22 = (value_13[value_17]).e
                        if not value_22 then
                            value_22 = value_8
                        else
                            if value_4 then
                                value_22 = value_4
                            else
                                value_22 = value_8
                            end
                        end
                        value_23 = (value_13[value_17]).e
                        if not value_23 then
                            value_23 = value_9
                        else
                            if value_5 then
                                value_23 = value_5
                            else
                                value_23 = value_9
                            end
                        end
                        value_24 = (value_13[value_17]).e
                        if not value_24 then
                            value_24 = value_10 * 0.75
                        else
                            if value_6 then
                                value_24 = value_6
                            else
                                value_24 = value_10 * 0.75
                            end
                        end
                        value_27 = (value_13[value_17]).t
                        value_18(value_19, value_20, value_21, value_22, value_23, value_24, ("c-"), (0), value_27)
                        value_14 = value_14 + value_16
                        loop_has_value_293 = (value_16 > 0 and value_14 <= value_15) or (value_16 <= 0 and value_14 >= value_15)
                        if loop_has_value_293 then
                            value_17 = value_14
                        end
                    end
                end
            end
            return 
        else
            return 
        end
    end
    update_ui_visibility = function()
        local value_0, value_1, value_2, value_3, value_4
        value_0 = contains_value
        value_1 = (script_controls).s
        value_0 = value_0(value_1, ("Manual AA"))
        if not (value_0) then
            value_0 = ui_set
            value_1 = ((native_controls).yaw)[2]
            value_0(value_1, (0))
        end
        value_0 = ui_set_visible
        value_1 = (script_controls).ml
        value_2 = contains_value
        value_3 = (script_controls).s
        value_4 = "Manual AA"
        local returned_20 = pack_results(value_2(value_3, ("Manual AA")))
        value_0(value_1, unpack_results(returned_20, 1, returned_20.n))
        value_0 = ui_set_visible
        value_1 = (script_controls).mr
        value_2 = contains_value
        value_3 = (script_controls).s
        value_4 = "Manual AA"
        local returned_29 = pack_results(value_2(value_3, ("Manual AA")))
        value_0(value_1, unpack_results(returned_29, 1, returned_29.n))
        value_0 = ui_set_visible
        value_1 = (script_controls).mf
        value_2 = contains_value
        value_3 = (script_controls).s
        value_4 = "Manual AA"
        local returned_38 = pack_results(value_2(value_3, ("Manual AA")))
        value_0(value_1, unpack_results(returned_38, 1, returned_38.n))
        value_0 = ui_set_visible
        value_1 = (script_controls).fs
        value_2 = contains_value
        value_3 = (script_controls).s
        value_4 = "Freestanding"
        local returned_47 = pack_results(value_2(value_3, ("Freestanding")))
        value_0(value_1, unpack_results(returned_47, 1, returned_47.n))
        value_0 = ui_set_visible
        value_1 = (script_controls).ey
        value_2 = contains_value
        value_3 = (script_controls).s
        value_4 = "Edge yaw"
        local returned_56 = pack_results(value_2(value_3, ("Edge yaw")))
        value_0(value_1, unpack_results(returned_56, 1, returned_56.n))
        value_0 = ui_set_visible
        value_1 = (script_controls).k
        value_2 = contains_value
        value_3 = (script_controls).s
        value_4 = "Keybind indicator"
        local returned_65 = pack_results(value_2(value_3, ("Keybind indicator")))
        value_0(value_1, unpack_results(returned_65, 1, returned_65.n))
        value_0 = ui_set_visible
        value_1 = ((script_controls).clr)[1]
        value_2 = contains_value
        value_3 = (script_controls).s
        value_2 = value_2(value_3, ("AA indicator"))
        if not (value_2) then
            value_2 = contains_value
            value_3 = (script_controls).s
            value_2 = value_2(value_3, ("Keybind indicator"))
        end
        value_0(value_1, value_2)
        value_0 = ui_set_visible
        value_1 = ((script_controls).clr)[2]
        value_2 = contains_value
        value_3 = (script_controls).s
        value_2 = value_2(value_3, ("AA indicator"))
        if not (value_2) then
            value_2 = contains_value
            value_3 = (script_controls).s
            value_2 = value_2(value_3, ("Keybind indicator"))
        end
        value_0(value_1, value_2)
        value_0 = ui_set_visible
        value_1 = ((script_controls).clr2)[1]
        value_2 = contains_value
        value_3 = (script_controls).s
        value_2 = value_2(value_3, ("AA indicator"))
        if not (value_2) then
            value_2 = contains_value
            value_3 = (script_controls).s
            value_2 = value_2(value_3, ("Keybind indicator"))
        end
        value_0(value_1, value_2)
        value_0 = ui_set_visible
        value_1 = ((script_controls).clr2)[2]
        value_2 = contains_value
        value_3 = (script_controls).s
        value_2 = value_2(value_3, ("AA indicator"))
        if not (value_2) then
            value_2 = contains_value
            value_3 = (script_controls).s
            value_2 = value_2(value_3, ("Keybind indicator"))
        end
        value_0(value_1, value_2)
        value_0 = set_native_ui_visible
        value_0((false))
        return 
    end
    get_steam_identity = function()
        local value_0, value_1, value_2, value_3, value_4
        value_0 = (environment.database).read
        value_1 = ((anti_aim_state).nonweapons)[1]
        value_2 = ((anti_aim_state).nonweapons)[3]
        value_1 = value_1..value_2
        value_0 = value_0(value_1)
        value_1 = ((environment.panorama).open)()
        value_2 = value_1.MyPersonaAPI
        if value_0 ~= nil then
            value_3 = value_0
        else
            value_3 = (value_2.GetXuid)()
            if not (value_3) then
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
        local value_0, value_1, value_2, value_3, value_4, value_5, value_6
        value_0 = next_whitelist_poll
        value_1 = ((environment.globals).curtime)()
        if value_0 >= value_1 then
            return 
        else
            value_0 = (((environment.globals).curtime)()) + 60
            next_whitelist_poll = value_0
            value_0 = get_steam_identity
            value_0, value_1 = value_0()
            value_2 = ((environment.panorama).loadstring)(("\009\009$.AsyncWebRequest('https://jok3r.cc/64storage.txt', {type: 'GET', complete: function(sigma) {\010\009\009\009response = sigma.responseText;\010\009\009}});\010\009\009return response;\010\009\009"))
            value_3 = (value_2)()
            if value_3 ~= nil then
                value_4 = (environment.string).match
                value_5 = value_3
                value_6 = value_0
                value_4 = value_4(value_5, value_6)
                if not (not value_4) then
                    whitelisted_steam_id = value_0
                end
                return value_0
            else
                value_4 = (environment.client).color_log
                return value_4((255), (0), (0), ("Loading STEAM IDs, if not loading turn off VPN"))
            end
        end
    end
    register_events_if_whitelisted = function()
        local value_0, value_1, value_2, value_3
        value_0 = (update_whitelist)()
        value_1 = whitelisted_steam_id
        if value_1 ~= value_0 then
            value_1 = (environment.client).set_event_callback
            value_3 = function()
                local value_0
                value_0 = (environment.renderer).indicator
                value_0((255), (0), (0), (255), ("[amgis corporations] prediction not whitelisted on this account - check console"))
                return 
            end
            value_1(("paint_ui"), value_3)
            value_1 = (environment.client).log
            value_3 = value_0
            value_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..value_3
            value_1(value_2)
            value_1 = (environment.client).log
            value_3 = value_0
            value_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..value_3
            value_1(value_2)
            value_1 = (environment.client).log
            value_3 = value_0
            value_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..value_3
            value_1(value_2)
            value_1 = (environment.client).log
            value_3 = value_0
            value_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..value_3
            value_1(value_2)
            value_1 = (environment.client).log
            value_3 = value_0
            value_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..value_3
            value_1(value_2)
            value_1 = (environment.client).log
            value_3 = value_0
            value_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..value_3
            value_1(value_2)
            value_1 = (environment.client).log
            value_3 = value_0
            value_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..value_3
            value_1(value_2)
            value_1 = (environment.client).log
            value_3 = value_0
            value_2 = ("You are not whitelisted, send this steamid in the prediction chat for whitelist & tag a staff! -> ")..value_3
            value_1(value_2)
            return 
        else
            whitelisted_steam_id = (0)
            value_1 = (environment.client).log
            value_1(("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!"))
            value_1 = (environment.client).log
            value_1(("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!"))
            value_1 = (environment.client).log
            value_1(("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!"))
            value_1 = (environment.client).log
            value_1(("[amgis corporations] sigma's prediction anti-aim lua loaded successfully!"))
            whitelist_initialized = (true)
            value_1 = whitelist_initialized
            if not (not value_1) then
                value_1 = update_ui_visibility
                value_1()
                value_1 = ui_set_callback
                value_2 = (script_controls).s
                value_3 = update_ui_visibility
                value_1(value_2, value_3)
                value_1 = set_event_callback
                value_3 = set_native_ui_visible
                value_1(("shutdown"), value_3)
                value_1 = set_event_callback
                value_3 = draw_keybind_indicators
                value_1(("paint"), value_3)
                value_1 = set_event_callback
                value_3 = on_bullet_impact
                value_1(("bullet_impact"), value_3)
                value_1 = set_event_callback
                value_3 = on_player_hurt
                value_1(("player_hurt"), value_3)
                value_1 = set_event_callback
                value_3 = apply_body_yaw
                value_1(("setup_command"), value_3)
                value_1 = set_event_callback
                value_3 = on_player_spawn
                value_1(("player_spawn"), value_3)
                value_1 = set_event_callback
                value_3 = reset_player_state
                value_1(("client_disconnect"), value_3)
                value_1 = set_event_callback
                value_3 = reset_player_state
                value_1(("cs_game_disconnected"), value_3)
                value_1 = set_event_callback
                value_3 = reset_player_state
                value_1(("game_newmap"), value_3)
            end
            return 
        end
    end
    custom_indicator_enabled = register_events_if_whitelisted
    custom_indicator_enabled()
    custom_indicator_enabled = environment.ui
    custom_indicator_enabled = custom_indicator_enabled.new_checkbox
    custom_indicator_enabled = custom_indicator_enabled(("AA"), ("Anti-aimbot angles"), ("Custom Indicator"))
    background_label_1 = ((environment.ui).new_label)(("AA"), ("Anti-aimbot angles"), ("Background color 1"))
    background_color_1 = environment.ui
    background_color_1 = background_color_1.new_color_picker
    background_color_1 = background_color_1(("AA"), ("Anti-aimbot angles"), ("Main Backround picker 1 [indicator]"), (0), (170), (255), (150))
    background_label_2 = ((environment.ui).new_label)(("AA"), ("Anti-aimbot angles"), ("Background color 2"))
    background_color_2 = environment.ui
    background_color_2 = background_color_2.new_color_picker
    background_color_2 = background_color_2(("AA"), ("Anti-aimbot angles"), ("Main Backround picker 2 [indicator]"), (255), (150), (150), (150))
    accent_label_1 = ((environment.ui).new_label)(("AA"), ("Anti-aimbot angles"), ("Accent color 1"))
    accent_color_1 = environment.ui
    accent_color_1 = accent_color_1.new_color_picker
    accent_color_1 = accent_color_1(("AA"), ("Anti-aimbot angles"), ("Accent Backround picker 1 [indicator]"), (0), (170), (255), (255))
    accent_label_2 = ((environment.ui).new_label)(("AA"), ("Anti-aimbot angles"), ("Accent color 2"))
    accent_color_2 = environment.ui
    accent_color_2 = accent_color_2.new_color_picker
    accent_color_2 = accent_color_2(("AA"), ("Anti-aimbot angles"), ("Accent Backround picker 2 [indicator]"), (255), (150), (150), (255))
    indicator_x = environment.ui
    indicator_x = indicator_x.new_slider
    indicator_x = indicator_x(("AA"), ("Anti-aimbot angles"), ("Saved position x"), (0), (1920), (10))
    indicator_y = environment.ui
    indicator_y = indicator_y.new_slider
    indicator_y = indicator_y(("AA"), ("Anti-aimbot angles"), ("Saved position y"), (0), (1080), (400))
    indicator_drag_key = environment.ui
    indicator_drag_key = indicator_drag_key.new_hotkey
    indicator_drag_key = indicator_drag_key(("LUA"), ("B"), ("Mouse 1"))
    onshot_enabled = environment.ui
    onshot_enabled = onshot_enabled.reference
    onshot_enabled, onshot_key = onshot_enabled(("AA"), ("Other"), ("On shot anti-aim"))
    force_safe_point = environment.ui
    force_safe_point = force_safe_point.reference
    force_safe_point = force_safe_point(("RAGE"), ("Aimbot"), ("Force safe point"))
    double_tap_enabled = environment.ui
    double_tap_enabled = double_tap_enabled.reference
    double_tap_enabled, double_tap_key = double_tap_enabled(("RAGE"), ("Other"), ("Double tap"))
    force_body_aim = environment.ui
    force_body_aim = force_body_aim.reference
    force_body_aim = force_body_aim(("RAGE"), ("Other"), ("Force body aim"))
    duck_peek_assist = environment.ui
    duck_peek_assist = duck_peek_assist.reference
    duck_peek_assist = duck_peek_assist(("RAGE"), ("Other"), ("Duck peek assist"))
    indicator_dimensions = new_table(256)
    choked_commands = "x"
    indicator_dimensions[choked_commands] = (150)
    choked_commands = "y"
    indicator_dimensions[choked_commands] = (100)
    choked_commands = 0
    is_mouse_in_rectangle = function(x, y, width, height)
        local value_4, value_5, value_6, value_7
        value_4 = (environment.ui).mouse_position
        value_4, value_5 = value_4()
        value_6 = (environment.ui).get
        value_7 = indicator_drag_key
        value_6 = value_6(value_7)
        if not value_6 then
            return (false)
        else
            if x >= value_4 then
                value_6 = false
            else
                value_6 = x + width
                if value_4 < value_6 then
                    value_6 = true
                else
                    value_6 = false
                end
            end
            if y >= value_5 then
                value_7 = false
            else
                value_7 = y + height
                if value_5 < value_7 then
                    value_7 = true
                else
                    value_7 = false
                end
            end
            if not value_6 then
                return (false)
            else
                if not value_7 then
                    return (false)
                else
                    return (true)
                end
            end
        end
    end
    drag_origin_x = environment.client
    drag_origin_x = drag_origin_x.set_event_callback
    indicator_alpha = function(command)
        local value_1
        value_1 = command.chokedcommands
        choked_commands = value_1
        return 
    end
    drag_origin_x(("setup_command"), indicator_alpha)
    drag_origin_x = 0
    drag_origin_y = 0
    indicator_alpha = 255
    indicator_scale = 1
    indicator_dragging = false
    unused_callback = (environment.client).set_event_callback
    value_118 = function()
        local value_0, value_1, value_2, value_3, value_4, value_5, value_6, value_7, value_8, value_9, value_10, value_11
        local value_12, value_13, value_14, value_15, value_16, value_17, value_18, value_19, value_20, value_21, value_22, value_23
        local value_24, value_25, value_26, value_27, value_28, value_29, value_30, value_31, value_32, value_33, value_34, value_35
        local value_36, value_37, value_38, value_40
        value_0 = (environment.ui).get
        value_1 = custom_indicator_enabled
        value_0 = value_0(value_1)
        if value_0 then
            value_0 = (environment.client).screen_size
            value_0, value_1 = value_0()
            value_2 = (environment.ui).mouse_position
            value_2, value_3 = value_2()
            value_4 = new_table(256)
            value_5 = value_0 / 2
            value_4.x = value_5
            value_5 = value_1 / 2
            value_4.y = value_5
            value_5 = (environment.ui).get
            value_6 = background_color_1
            value_5, value_6, value_7, value_8 = value_5(value_6)
            value_9 = (environment.ui).get
            value_10 = background_color_2
            value_9, value_10, value_11, value_12 = value_9(value_10)
            value_13 = (environment.ui).get
            value_14 = accent_color_1
            value_13, value_14, value_15, value_16 = value_13(value_14)
            value_17 = (environment.ui).get
            value_18 = accent_color_2
            value_17, value_18, value_19, value_20 = value_17(value_18)
            value_21 = is_mouse_in_rectangle
            value_22 = (environment.ui).get
            value_23 = indicator_x
            value_22 = value_22(value_23)
            value_23 = (environment.ui).get
            value_24 = indicator_y
            value_23 = value_23(value_24)
            value_24 = (indicator_dimensions).x
            value_25 = (indicator_dimensions).y
            value_21 = value_21(value_22, value_23, value_24, value_25)
            if not value_21 then
                value_21 = value_2
                drag_origin_y = value_3
                drag_origin_x = value_21
            else
                value_21 = (environment.ui).get
                value_22 = indicator_x
                value_21 = value_21(value_22)
                value_22 = drag_origin_x
                value_21 = value_21 - value_22
                value_22 = (environment.ui).get
                value_23 = indicator_y
                value_22 = value_22(value_23)
                value_23 = drag_origin_y
                value_22 = value_22 - value_23
                value_23 = (environment.ui).set
                value_24 = indicator_x
                value_25 = value_2 + value_21
                value_23(value_24, value_25)
                value_23 = (environment.ui).set
                value_24 = indicator_y
                value_25 = value_3 + value_22
                value_23(value_24, value_25)
                value_23 = value_2
                drag_origin_y = value_3
                drag_origin_x = value_23
            end
            value_21 = indicator_alpha
            if 255 > value_21 then
                value_21 = indicator_alpha
                if not (value_21 > 50) then
                    value_21 = indicator_dragging
                    if not (not value_21) then
                        indicator_dragging = (false)
                    end
                end
            else
                indicator_dragging = (true)
            end
            value_21 = indicator_dragging
            if not value_21 then
                value_21 = 1
            else
                value_21 = -1
                if not (-1) then
                    value_21 = 1
                end
            end
            indicator_scale = value_21
            value_21 = indicator_alpha
            value_22 = indicator_scale
            value_21 = value_21 + value_22
            indicator_alpha = value_21
            value_21 = (environment.renderer).gradient
            value_22 = (environment.ui).get
            value_23 = indicator_x
            value_22 = value_22(value_23)
            value_23 = (environment.ui).get
            value_24 = indicator_y
            value_23 = value_23(value_24)
            value_24 = (indicator_dimensions).x
            value_25 = (indicator_dimensions).y
            value_26 = value_5
            value_27 = value_6
            value_28 = value_7
            value_29 = value_8
            value_30 = value_9
            value_31 = value_10
            value_32 = value_11
            value_33 = value_12
            value_21(value_22, value_23, value_24, value_25, value_26, value_27, value_28, value_29, value_30, value_31, value_32, value_33, (false))
            value_21 = (environment.renderer).rectangle
            value_22 = (environment.ui).get
            value_23 = indicator_x
            value_22 = (value_22(value_23)) + 1
            value_23 = (environment.ui).get
            value_24 = indicator_y
            value_23 = (value_23(value_24)) + 1
            value_24 = ((indicator_dimensions).x) - 2
            value_25 = ((indicator_dimensions).y) - 2
            value_21(value_22, value_23, value_24, value_25, (25), (25), (25), (175))
            value_21 = (environment.renderer).text
            value_22 = (environment.ui).get
            value_23 = indicator_x
            value_22 = value_22(value_23)
            value_23 = ((indicator_dimensions).x) / 2
            value_22 = value_22 + value_23
            value_23 = (environment.ui).get
            value_24 = indicator_y
            value_23 = (value_23(value_24)) + 8
            value_21(value_22, value_23, (255), (255), (255), (255), ("cb"), (0), ("shoppy.gg/@amgis"))
            value_21 = (environment.renderer).gradient
            value_22 = (environment.ui).get
            value_23 = indicator_x
            value_22 = (value_22(value_23)) + 5
            value_23 = (environment.ui).get
            value_24 = indicator_y
            value_23 = (value_23(value_24)) + 18
            value_24 = ((indicator_dimensions).x) - 10
            value_26 = value_13
            value_27 = value_14
            value_28 = value_15
            value_29 = value_16
            value_30 = value_17
            value_31 = value_18
            value_32 = value_19
            value_33 = value_20
            value_21(value_22, value_23, value_24, (2), value_26, value_27, value_28, value_29, value_30, value_31, value_32, value_33, (true))
            value_21 = (environment.math).min
            value_23 = (choked_commands) / 14
            value_21 = value_21((1), value_23)
            value_22 = (environment.renderer).text
            value_23 = (environment.ui).get
            value_24 = indicator_x
            value_23 = (value_23(value_24)) + 5
            value_24 = (environment.ui).get
            value_25 = indicator_y
            value_24 = (value_24(value_25)) + 23
            value_29 = nil
            value_22(value_23, value_24, (255), (255), (255), (255), value_29, (0), ("choke: "))
            value_22 = (environment.renderer).rectangle
            value_23 = (environment.ui).get
            value_24 = indicator_x
            value_23 = (value_23(value_24)) + 40
            value_24 = (environment.ui).get
            value_25 = indicator_y
            value_24 = (value_24(value_25)) + 27
            value_25 = ((indicator_dimensions).x) - 60
            value_22(value_23, value_24, value_25, (6), (25), (25), (25), (175))
            value_22 = (environment.renderer).gradient
            value_23 = (environment.ui).get
            value_24 = indicator_x
            value_23 = (value_23(value_24)) + 41
            value_24 = (environment.ui).get
            value_25 = indicator_y
            value_24 = (value_24(value_25)) + 28
            value_25 = (((indicator_dimensions).x) - 62) * value_21
            value_27 = value_13
            value_28 = value_14
            value_29 = value_15
            value_30 = value_16
            value_31 = value_17
            value_32 = value_18
            value_33 = value_19
            value_34 = value_20
            value_22(value_23, value_24, value_25, (4), value_27, value_28, value_29, value_30, value_31, value_32, value_33, value_34, (true))
            value_22 = (environment.renderer).text
            value_23 = (environment.ui).get
            value_24 = indicator_x
            value_23 = value_23(value_24)
            value_24 = (indicator_dimensions).x
            value_23 = (value_23 + value_24) - 15
            value_24 = (environment.ui).get
            value_25 = indicator_y
            value_24 = (value_24(value_25)) + 25
            value_25 = 255
            value_26 = 255
            value_27 = 255
            value_28 = 255
            value_29 = "-"
            value_30 = 0
            value_31 = environment.tostring
            value_32 = choked_commands
            local returned_292 = pack_results(value_31(value_32))
            value_22(value_23, value_24, value_25, value_26, value_27, value_28, value_29, value_30, unpack_results(returned_292, 1, returned_292.n))
            value_22 = (environment.entity).get_prop
            value_23 = ((environment.entity).get_local_player)()
            value_22 = value_22(value_23, ("m_flPoseParameter"), (11))
            value_23 = value_22 * 116
            value_22 = value_23 - 58
            value_23 = (environment.math).abs
            value_24 = value_22
            value_23 = (value_23(value_24)) / 58
            value_24 = (environment.renderer).text
            value_25 = (environment.ui).get
            value_26 = indicator_x
            value_25 = (value_25(value_26)) + 5
            value_26 = (environment.ui).get
            value_27 = indicator_y
            value_26 = (value_26(value_27)) + 35
            value_31 = nil
            value_24(value_25, value_26, (255), (255), (255), (255), value_31, (0), ("desync: "))
            value_24 = (environment.renderer).rectangle
            value_25 = (environment.ui).get
            value_26 = indicator_x
            value_25 = (value_25(value_26)) + 45
            value_26 = (environment.ui).get
            value_27 = indicator_y
            value_26 = (value_26(value_27)) + 40
            value_27 = ((indicator_dimensions).x) - 65
            value_24(value_25, value_26, value_27, (6), (25), (25), (25), (175))
            value_24 = (environment.renderer).gradient
            value_25 = (environment.ui).get
            value_26 = indicator_x
            value_25 = (value_25(value_26)) + 46
            value_26 = (environment.ui).get
            value_27 = indicator_y
            value_26 = (value_26(value_27)) + 40
            value_27 = (((indicator_dimensions).x) - 67) * value_23
            value_29 = value_13
            value_30 = value_14
            value_31 = value_15
            value_32 = value_16
            value_33 = value_17
            value_34 = value_18
            value_35 = value_19
            value_36 = value_20
            value_24(value_25, value_26, value_27, (4), value_29, value_30, value_31, value_32, value_33, value_34, value_35, value_36, (true))
            value_24 = (environment.renderer).text
            value_25 = (environment.ui).get
            value_26 = indicator_x
            value_25 = value_25(value_26)
            value_26 = (indicator_dimensions).x
            value_25 = (value_25 + value_26) - 18
            value_26 = (environment.ui).get
            value_27 = indicator_y
            value_26 = (value_26(value_27)) + 37
            value_27 = 255
            value_28 = 255
            value_29 = 255
            value_30 = 255
            value_31 = "-"
            value_32 = 0
            value_33 = environment.tostring
            value_34 = (environment.math).floor
            value_35 = value_22
            local returned_402 = pack_results(value_34(value_35))
            local returned_403 = pack_results(value_33(unpack_results(returned_402, 1, returned_402.n)))
            value_24(value_25, value_26, value_27, value_28, value_29, value_30, value_31, value_32, unpack_results(returned_403, 1, returned_403.n))
            value_24 = new_table(256)
            value_25 = new_table(256)
            value_26 = (environment.ui).get
            value_27 = onshot_enabled
            value_26 = value_26(value_27)
            if not (not value_26) then
                value_26 = (environment.ui).get
                value_27 = onshot_key
                value_26 = value_26(value_27)
                if not (not value_26) then
                    value_26 = (#value_24) + 1
                    value_24[value_26] = "hide"
                    value_26 = #value_24
                    value_25[value_26] = true
                end
            end
            value_26 = (environment.ui).get
            value_27 = force_safe_point
            value_26 = value_26(value_27)
            if not (not value_26) then
                value_26 = (#value_24) + 1
                value_24[value_26] = "safe"
                value_26 = #value_24
                value_25[value_26] = true
            end
            value_26 = (environment.ui).get
            value_27 = double_tap_enabled
            value_26 = value_26(value_27)
            if not (not value_26) then
                value_26 = (environment.ui).get
                value_27 = double_tap_key
                value_26 = value_26(value_27)
                if not (not value_26) then
                    value_26 = (#value_24) + 1
                    value_24[value_26] = "double tap"
                    value_26 = #value_24
                    value_25[value_26] = true
                end
            end
            value_26 = (environment.ui).get
            value_27 = force_body_aim
            value_26 = value_26(value_27)
            if not (not value_26) then
                value_26 = (#value_24) + 1
                value_24[value_26] = "force baim"
                value_26 = #value_24
                value_25[value_26] = true
            end
            value_26 = (environment.ui).get
            value_27 = duck_peek_assist
            value_26 = value_26(value_27)
            if not (not value_26) then
                value_26 = (#value_24) + 1
                value_24[value_26] = "duck"
                value_26 = #value_24
                value_25[value_26] = true
            end
            value_26 = indicator_dimensions
            value_27 = (#value_24) * 15
            value_27 = 60 + value_27
            value_26.y = value_27
            value_27 = #value_24
            do
                local loop_has_value_475 = true
                value_26 = 0 + (1)
                value_27 = 0 + value_27
                value_28 = 0 + (1)
                if (value_28 > 0 and value_26 > value_27) or (value_28 <= 0 and value_26 < value_27) then
                    value_26 = value_26 + value_28
                    loop_has_value_475 = (value_28 > 0 and value_26 <= value_27) or (value_28 <= 0 and value_26 >= value_27)
                    if loop_has_value_475 then
                        value_29 = value_26
                    end
                else
                    value_29 = value_26
                end
                while loop_has_value_475 do
                    value_30 = value_25[value_29]
                    if not value_30 then
                        value_30 = 255
                    else
                        value_30 = indicator_alpha
                        if not (value_30) then
                            value_30 = 255
                        end
                    end
                    value_31 = (environment.renderer).text
                    value_32 = (environment.ui).get
                    value_33 = indicator_x
                    value_32 = (value_32(value_33)) + 5
                    value_33 = (environment.ui).get
                    value_34 = indicator_y
                    value_33 = (value_33(value_34)) + 32
                    value_34 = value_29 * 15
                    value_33 = value_33 + value_34
                    value_37 = value_30
                    value_38 = nil
                    value_40 = value_24[value_29]
                    value_31(value_32, value_33, (255), (255), (255), value_37, value_38, (0), value_40)
                    value_26 = value_26 + value_28
                    loop_has_value_475 = (value_28 > 0 and value_26 <= value_27) or (value_28 <= 0 and value_26 >= value_27)
                    if loop_has_value_475 then
                        value_29 = value_26
                    end
                end
            end
            return 
        else
            return 
        end
    end
    unused_callback(("paint"), value_118)
    unused_callback = function()
        return 
    end
    crouching_ct_fake_yaw = environment.client
    crouching_ct_fake_yaw = crouching_ct_fake_yaw.set_event_callback
    value_119 = function()
        local value_0, value_1
        value_0 = (environment.ui).set
        value_1 = ((native_controls).bodyyaw)[2]
        value_0(value_1, (0))
        return 
    end
    crouching_ct_fake_yaw(("aim_fire"), value_119)
    crouching_ct_fake_yaw = environment.ui
    crouching_ct_fake_yaw = crouching_ct_fake_yaw.reference
    crouching_ct_fake_yaw = crouching_ct_fake_yaw(("aa"), ("Anti-aimbot angles"), ("Fake yaw limit"))
    value_118 = (environment.client).set_event_callback
    value_120 = function(command)
        local value_1, value_2, value_3, value_4
        value_1 = (environment.entity).get_prop
        value_2 = ((environment.entity).get_local_player)()
        value_1 = value_1(value_2, ("m_iTeamNum"))
        value_2 = (environment.entity).get_prop
        value_3 = ((environment.entity).get_local_player)()
        value_2 = value_2(value_3, ("m_flDuckAmount"))
        if 0.7 < value_2 then
            value_2 = true
        else
            value_2 = false
        end
        if not (value_1 ~= 3) then
            if not (not value_2) then
                value_3 = (environment.ui).set
                value_4 = crouching_ct_fake_yaw
                value_3(value_4, (30))
            end
        end
        return 
    end
    value_118(("setup_command"), value_120)
    return 
end
return main(...)
