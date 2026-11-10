"""Apply bounded HUD optimizations to the verified readable Emberlash baseline."""
from pathlib import Path
import hashlib,json
ROOT=Path(__file__).resolve().parent.parent
BASE=ROOT.parent/'emberlash_source.lua'
s=BASE.read_text()
assert hashlib.sha256(BASE.read_bytes()).hexdigest()=='0f0a68e4441296cba4838f9c21e08ac4068e13845b335b33a2cf6c99b151170b'
changes=[]
def replace(old,new,label):
 global s
 assert s.count(old)==1,(label,s.count(old))
 s=s.replace(old,new);changes.append(label)
cache='''    -- HUD-only snapshots expire every frame; dynamic strings are bounded.
    do
        local native_measure = renderer_measure_text_15537
        local native_screen = client_screen_size_15535
        local last_frame = nil
        local screen_ready, screen_w, screen_h = false, nil, nil
        local text_cache, text_count = {}, 0
        local function refresh_frame()
            local frame = globals_framecount_15533()
            if frame ~= last_frame then
                if last_frame ~= nil and frame < last_frame then
                    text_cache, text_count = {}, 0
                end
                last_frame, screen_ready = frame, false
            end
            return frame
        end
        renderer_measure_text_15537 = function(...)
            if select("#", ...) ~= 2 then return native_measure(...) end
            local flags, value = ...
            if type(flags) ~= "string" or type(value) ~= "string" then
                return native_measure(...)
            end
            local frame = refresh_frame()
            local bucket = text_cache[flags]
            local entry = bucket and bucket[value]
            if entry ~= nil and entry.frame == frame then return entry.w, entry.h end
            local w, h = native_measure(...)
            if entry == nil then
                if text_count >= 512 then
                    text_cache, text_count, bucket = {}, 0, nil
                end
                if bucket == nil then bucket = {}; text_cache[flags] = bucket end
                entry = {}; bucket[value] = entry; text_count = text_count + 1
            end
            entry.frame, entry.w, entry.h = frame, w, h
            return w, h
        end
        client_screen_size_15535 = function(...)
            if select("#", ...) ~= 0 then return native_screen(...) end
            refresh_frame()
            if not screen_ready then
                screen_w, screen_h = native_screen()
                screen_ready = true
            end
            return screen_w, screen_h
        end
    end
    local perf_lightweight_hud = true
    do
        local control = pui_lib.group("LUA", "A"):checkbox("Emberlash: lightweight HUD", true)
        control:set_callback(function()
            perf_lightweight_hud = control:get() == true
        end, true)
    end
'''
replace('    local helper_15539 = nil\n',cache+'    local helper_15539 = nil\n','HUD frame caches and lightweight option')
replace('    local result_16221 = helper_15543()\n','    local result_16221 = helper_15543 -- Lazily create blur resources on first use.\n','lazy blur resources')
replace('    local result_16283 = helper_15543()\n','    local result_16283 = helper_15543 -- Lazily create shadow resources on first use.\n','lazy shadow resources')
# Keep the original geometry and drawing paths available when the option is off.
for member,pool in [('draw_blur','result_16221'),('draw_shadow','result_16283')]:
 start=s.index('    hud_effects.'+member+' = function(');end=s.index('\n',start)
 s=s[:end+1]+'        if perf_lightweight_hud then return end\n'+s[end+1:]
 needle='        '+pool+'.renderer_rect('
 replacement='        if type('+pool+') == "function" then '+pool+' = '+pool+'() end\n'+needle
 replace(needle,replacement,'lightweight guard and lazy '+member)
# Empty pools need one hide pass; after that there is no frame work to do.
for name,var in [('rounded_rect_pool','math_min_15514_result_16217'),('shadow_rect_pool','math_min_15514_result_16279')]:
 old='            local '+var+' = math_min_15514('+name+'.count, '+name+'.max_rects)\n'
 new=old+'            if '+var+' == 0 and '+name+'._last_active_count == 0 then return end\n            '+name+'._last_active_count = '+var+'\n'
 replace(old,new,'idle '+name+' fast path')
# Share immutable input snapshots between HUD windows within a render frame.
drag='''    local perf_read_drag_input
    do
        local frame_id = nil
        local input = {}
        perf_read_drag_input = function(frame)
            if frame ~= frame_id then
                input.mouse_down = a[64](1) == true
                input.menu_open = pui_lib.is_menu_open()
                input.mouse_x, input.mouse_y = pui_lib.mouse_position()
                input.menu_x, input.menu_y = pui_lib.menu_position()
                input.menu_w, input.menu_h = pui_lib.menu_size()
                input.screen_w, input.screen_h = client_screen_size_15535()
                frame_id = frame
            end
            return input
        end
    end
'''
replace('    draggable_class._refresh_input = function(self_state_16131, argument_16132)\n',drag+'    draggable_class._refresh_input = function(self_state_16131, argument_16132)\n','shared drag-input snapshot')
old='''        self_state_16131.mouse_down = a[64] --[[ client.key_state ]](1) == true
        self_state_16131.menu_open = pui_lib.is_menu_open()
        self_state_16131.mouse_x, self_state_16131.mouse_y = pui_lib.mouse_position()
        self_state_16131.menu_x, self_state_16131.menu_y = pui_lib.menu_position()
        self_state_16131.menu_w, self_state_16131.menu_h = pui_lib.menu_size()
        self_state_16131.screen_w, self_state_16131.screen_h = client_screen_size_15535()
'''
new='''        local input = perf_read_drag_input(last_frame_16133)
        self_state_16131.mouse_down = input.mouse_down
        self_state_16131.menu_open = input.menu_open
        self_state_16131.mouse_x, self_state_16131.mouse_y = input.mouse_x, input.mouse_y
        self_state_16131.menu_x, self_state_16131.menu_y = input.menu_x, input.menu_y
        self_state_16131.menu_w, self_state_16131.menu_h = input.menu_w, input.menu_h
        self_state_16131.screen_w, self_state_16131.screen_h = input.screen_w, input.screen_h
'''
replace(old,new,'reuse drag-input snapshot')
s=s[s.index('-- emberlash (decompiled'):]
s='-- Emberlash performance edition: bounded HUD caches and optional lightweight effects.\n-- See README_PERFORMANCE_RU.md and optimization_validation.json.\n\n'+s
(ROOT/'emberlash_optimized.lua').write_text(s)
(ROOT/'changes.json').write_text(json.dumps({'baseline_sha256':hashlib.sha256(BASE.read_bytes()).hexdigest(),'optimized_sha256':hashlib.sha256(s.encode()).hexdigest(),'changes':changes},indent=2)+'\n')
print('Applied',len(changes),'scoped changes. Optimized bytes:',len(s.encode()))
