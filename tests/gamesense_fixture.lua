-- Offline GameSense fixture. Never invokes native memory APIs or network requests.
bit = require('bit')
local function noop() end
local function zero() return 0 end
local vec_mt = {}
vec_mt.__index = {length=function(self) return math.sqrt(self.x*self.x+self.y*self.y+self.z*self.z) end,
    unpack=function(self) return self.x,self.y,self.z end, normalized=function(self) return self end}
function vector(x,y,z) return setmetatable({x=x or 0,y=y or 0,z=z or 0},vec_mt) end
vec_mt.__add=function(a,b) return vector(a.x+b.x,a.y+b.y,a.z+b.z) end
vec_mt.__sub=function(a,b) return vector(a.x-b.x,a.y-b.y,a.z-b.z) end
vec_mt.__mul=function(a,b) return vector(a.x*b,a.y*b,a.z*b) end
vec_mt.__div=function(a,b) return vector(a.x/b,a.y/b,a.z/b) end
new_table=function(x) return x or {} end
truthy_iterator=function(f,s,c) return function(a,b) local k,v=f(a,b); if k then return k,v end end,s,c end
table.unpack=unpack
ffi={cast=function() error('Native cast reached in offline fixture') end,
    new=function() return {} end, typeof=function(s) return s end,
    string=function(x) return tostring(x) end}
local ids, controls, refs = 0, {}, {}
local function create(kind,tab,container,name,...)
    assert(type(name)=='string', 'UI name required')
    ids=ids+1
    local args={...}
    local value=false
    if kind=='slider' then value=args[3] or args[1] or 0
    elseif kind=='combobox' then value=type(args[1])=='table' and args[1][1] or args[1]
    elseif kind=='listbox' then value=0
    elseif kind=='multiselect' then value={}
    elseif kind=='textbox' or kind=='string' then value=''
    elseif kind=='color_picker' then value=args end
    controls[ids]={kind=kind,name=name,value=value,visible=true,callback=nil,options=args}
    return ids
end
ui={is_menu_open=function() return true end,mouse_position=function() return 0,0 end}
for _,kind in ipairs({'checkbox','hotkey','label','listbox','multiselect','slider','textbox','color_picker','combobox','button'}) do
    ui['new_'..kind]=function(...) return create(kind,...) end
end
ui.new_string=function(name,default) local id=create('string','','',name); controls[id].value=default or ''; return id end
ui.get=function(id)
    local c=assert(controls[id], 'Unknown UI handle '..tostring(id))
    if c.kind=='color_picker' then return unpack(c.value) end
    return c.value
end
ui.set=function(id,...) local c=assert(controls[id]); c.value=select(1,...); if c.kind=='color_picker' then c.value={...} end end
ui.name=function(id) return assert(controls[id]).name end
ui.type=function(id) return assert(controls[id]).kind end
ui.set_callback=function(id,fn) assert(type(fn)=='function','UI callback must be a function'); controls[id].callback=fn end
ui.set_visible=function(id,visible) assert(type(visible)=='boolean'); assert(controls[id]).visible=visible end
ui.update=function(id,...) assert(controls[id]); end
ui.reference=function(tab,container,name)
    local key=tab..'/'..container..'/'..name
    if not refs[key] then
        local multi={Pitch=true,Yaw=true,['Yaw jitter']=true,['Body yaw']=true,Freestanding=true,['Double tap']=true,['Quick peek assist']=true,['On shot anti-aim']=true,['Duck peek assist']=true}
        if name=='Enabled' and (container:lower()=='fake lag' or tab:lower()=='rage') then multi[name]=true end
        multi['Slow motion']=true
        multi['Duck peek assist']=false
        local kind='checkbox'
        if name=='Pitch' or name=='Yaw' or name=='Yaw jitter' or name=='Body yaw' then kind='combobox' end
        local id=create(kind,tab,container,name,'Off')
        refs[key]={id}
        if multi[name] then refs[key][2]=create('hotkey',tab,container,name..' hotkey') end
    end
    return unpack(refs[key])
end
events,delayed={},{}
client={screen_size=function() return 1920,1080 end,
    set_event_callback=function(event,fn) assert(type(fn)=='function',event..': callback is '..type(fn)); events[#events+1]={event,fn} end,
    unset_event_callback=function(event,fn) assert(type(fn)=='function') end,
    delay_call=function(t,fn,...) assert(type(fn)=='function'); delayed[#delayed+1]={fn,{...}} end,
    log=noop,error_log=noop,color_log=noop,exec=noop,random_int=function(a,b) return a end,
    random_float=function(a,b) return a end,key_state=function() return false end,
    system_time=function() return 12,0,0 end,unix_time=function() return 0 end,
    latency=zero,current_threat=function() return nil end,eye_position=function() return 0,0,0 end,
    camera_angles=function() return 0,0 end,trace_line=function() return 1,0 end,
    userid_to_entindex=zero,set_clan_tag=noop}
vtable_bind=function(module,interface,index,signature)
    return function() return 0 end
end
entity={get_local_player=function() return nil end,is_alive=function() return false end,
    get_players=function() return {} end,get_all=function() return {} end,
    get_game_rules=function() return nil end,get_prop=zero,set_prop=noop,
    get_classname=function() return '' end,is_dormant=function() return false end,
    is_enemy=function() return false end,get_player_name=function() return 'fixture' end,
    get_player_weapon=function() return nil end,get_origin=function() return 0,0,0 end,
    get_bounding_box=function() return 0,0,0,0,0 end,get_steam64=function() return '0' end}
renderer={text=noop,rectangle=noop,gradient=noop,circle=noop,circle_outline=noop,triangle=noop,line=noop,
    world_to_screen=function() return nil end,measure_text=function(_,text) return #text*6,12 end,
    texture=noop,load_svg=function() return 1 end}
globals={frametime=function() return 1/120 end,absoluteframetime=function() return 1/120 end,
    realtime=zero,curtime=zero,tickcount=zero,tickinterval=function() return 1/64 end,
    maxplayers=function() return 64 end,mapname=function() return nil end,framecount=zero}
plist={set=noop,get=zero}
database={read=function() return nil end,write=noop}
readfile=function() return nil end
writefile=noop
json={parse=function() return {} end,stringify=function() return '{}' end}
cvar=setmetatable({}, {__index=function() return {get_int=zero,get_float=zero,get_string=function() return '' end,set_int=noop,set_float=noop,set_string=noop} end})
local image={measure=function() return 16,16 end,draw=noop}
mock_images={get_panorama_image=function() return image end,load=function() return image end,get_weapon_icon=function() return image end}
mock_http={get=function() end}
mock_msgpack={pack=function() return '' end,unpack=function() return {} end}
mock_antiaim={get_desync=zero,get_overlap=zero,get_max_desync=zero,get_double_tap=function() return false end}
mock_weapons={}
function fixture_stats() return ids,#events,#delayed end
panorama={loadstring=function() return function() return {get_text=function() return '' end,change_text=function() end,change_color=function() end} end end}

client.register_esp_flag=function(label,r,g,b,fn) assert(type(fn)=="function") end

panorama.open=function() return {MyPersonaAPI={GetXuid=function() return '76561198000000000' end}} end

local old_load=panorama.loadstring
panorama.loadstring=function(...) local f=old_load(...); return function() local obj=f(); obj.delete=function() end; obj.create_panel=function() end; obj.change_position=function() end; return obj end end

function fixture_ui_callbacks()
 local failures, count = {}, 0
 for id=1,ids do
  local c=controls[id]
  if c.callback then
   local ok,why=xpcall(function() c.callback(id) end,debug.traceback); count=count+1
   if not ok then failures[#failures+1]=c.name..': '..why end
  end
 end
 return count,#failures,table.concat(failures,'\n')
end

local panel_load=panorama.loadstring
panorama.loadstring=function(...) local f=panel_load(...); return function() local obj=f(); obj.set_visible=function() end; return obj end end

function fixture_variants()
 local count,failures=0,{}
 for id=1,ids do
  local c=controls[id]
  if c.callback and (c.kind=='checkbox' or c.kind=='combobox' or c.kind=='multiselect') then
   local original=c.value
   local variants=c.kind=='checkbox' and {true,false} or (type(c.options[1])=='table' and c.options[1] or c.options)
   if c.kind=='multiselect' then local options=type(c.options[1])=='table' and c.options[1] or c.options; variants={{}}; for _,opt in ipairs(options) do variants[#variants+1]={opt} end; variants[#variants+1]=options end
   for _,value in ipairs(variants) do
    c.value=value
    local ok,why=xpcall(function() c.callback(id) end,debug.traceback)
    count=count+1
    if not ok then failures[#failures+1]=c.name..': '..why end
   end
   c.value=original
   local ok,why=xpcall(function() c.callback(id) end,debug.traceback)
   if not ok then failures[#failures+1]=c.name..' restore: '..why end
  end
 end
 return count,#failures,table.concat(failures,'\n')
end
