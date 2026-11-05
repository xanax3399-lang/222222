-- This factory is embedded in skeet.dll. It never replaces Gamesense globals.
return function(native, gs, ffi)
    local api = {version = '0.1.0', gs = gs}
    local inventory = __GSNL_INVENTORY__
    local unpack = unpack
    local function fail(name, reason)
        error('GSNL: ' .. name .. ' unavailable: ' .. (reason or 'not implemented in this bridge'), 3)
    end
    local function finite(value, name)
        if type(value) ~= 'number' or value ~= value or math.abs(value) == math.huge then
            error('GSNL: finite number required for ' .. (name or 'argument'), 3)
        end
        return value
    end
    local function clone(t)
        if type(t) ~= 'table' then return t end
        local out = {}; for k,v in pairs(t) do out[k] = clone(v) end; return out
    end
    function api.capability(name) return clone(inventory[name]) end
    function api.capabilities() return clone(inventory) end
    function api.supports(name) return inventory[name] ~= nil and inventory[name].status == 'supported' end
    local function namespace(name, values)
        return setmetatable(values or {}, {__index = function(_, key)
            fail(name .. '.' .. tostring(key))
        end})
    end
    api.native = {}
    function api.native.snapshot()
        local out = ffi.new('GsnlSnapshot[1]')
        assert(native.gsnl_snapshot(out, ffi.sizeof(out[0])) == 1, 'GSNL: snapshot ABI mismatch')
        local result = {}
        for _,k in ipairs({'size','abi','loader_state','mode','points_installed','points_calls','points_added',
            'brake_enabled','brake_installed','brake_applied','crown_enabled','crown_installed','crown_added',
            'fire_installed','guard_enabled','guard_canceled','recharge_enabled','recharge_overrides'}) do
            result[k] = tonumber(out[0][k])
        end
        return result
    end

    local V, vm = {}, {}
    vm.__index = function(_, k) local fn = V[k]; if fn then return fn end; fail('vector:' .. tostring(k)) end
    local function vector(x,y,z)
        return setmetatable({x=finite(x or 0),y=finite(y or 0),z=finite(z or 0)}, vm)
    end
    api.vector = vector
    local function component(v,k) return type(v)=='number' and v or v[k] end
    for key,op in pairs({__add=function(a,b)return a+b end,__sub=function(a,b)return a-b end,
        __mul=function(a,b)return a*b end,__div=function(a,b)return a/b end}) do
        vm[key] = function(a,b) return vector(op(component(a,'x'),component(b,'x')),
            op(component(a,'y'),component(b,'y')),op(component(a,'z'),component(b,'z'))) end
    end
    vm.__unm=function(a)return vector(-a.x,-a.y,-a.z)end
    vm.__eq=function(a,b)return a.x==b.x and a.y==b.y and a.z==b.z end
    vm.__tostring=function(a)return string.format('vector(%g, %g, %g)',a.x,a.y,a.z)end
    function V:init(x,y,z) self.x,self.y,self.z=finite(x),finite(y),finite(z); return self end
    function V:unpack()return self.x,self.y,self.z end
    function V:clone()return vector(self:unpack())end
    function V:dot(b)return tonumber(native.gsnl_dot3(self.x,self.y,self.z,b.x,b.y,b.z))end
    function V:length()return tonumber(native.gsnl_length3(self.x,self.y,self.z))end
    function V:length2d()return tonumber(native.gsnl_length3(self.x,self.y,0))end
    function V:lengthsqr()return self:dot(self)end
    function V:length2dsqr()return self.x*self.x+self.y*self.y end
    function V:distsqr(b)return (self-b):lengthsqr()end
    function V:dist2dsqr(b)return (self-b):length2dsqr()end
    function V:dist(b)return (self-b):length()end
    function V:dist2d(b)return (self-b):length2d()end
    function V:in_range(b,r)return self:dist(b)<=finite(r)end
    function V:cross(b)return vector(self.y*b.z-self.z*b.y,self.z*b.x-self.x*b.z,self.x*b.y-self.y*b.x)end
    function V:normalize()local n=self:length(); if n>0 then self:init(self.x/n,self.y/n,self.z/n)end; return n end
    function V:normalized()local b=self:clone();b:normalize();return b end
    function V:scale(s)return self:init(self.x*s,self.y*s,self.z*s)end
    function V:scaled(s)return self*s end
    function V:lerp(b,t)return self+(b-self)*finite(t)end
    function V:to(b)return (b-self):normalized()end
    function V:floor()return self:init(math.floor(self.x),math.floor(self.y),math.floor(self.z))end
    function V:ceil()return self:init(math.ceil(self.x),math.ceil(self.y),math.ceil(self.z))end
    function V:closest_ray_point(a,b)
        local d=b-a; local n=d:lengthsqr(); if n==0 then return a:clone()end
        local t=math.max(0,math.min(1,(self-a):dot(d)/n));return a+d*t
    end
    function V:dist_to_ray(a,d)
        local n=d:lengthsqr();if n==0 then return self:dist(a)end
        return self:dist(a+d*math.max(0,(self-a):dot(d)/n))
    end
    function V:angles(pitch,yaw)
        if type(pitch)=='table' then pitch,yaw=pitch.x,pitch.y end
        pitch,yaw=math.rad(pitch or self.x),math.rad(yaw or self.y)
        return self:init(math.cos(pitch)*math.cos(yaw),math.cos(pitch)*math.sin(yaw),-math.sin(pitch))
    end
    function V:vectors()
        local right
        if self.x==0 and self.y==0 then right=vector(0,-1,0)else right=vector(self.y,-self.x,0):normalized()end
        return right,right:cross(self):normalized()
    end
    function V:to_screen()return api.render.world_to_screen(self)end

    local C, cm = {}, {}
    cm.__index=function(_,k)local fn=C[k];if fn then return fn end;fail('color:'..tostring(k))end
    local function channel(v)return math.floor(math.max(0,math.min(255,finite(v)))+.5)end
    local function color(r,g,b,a)
        if type(r)=='string' then
            local h=r:gsub('^#','');assert(h:match('^%x+$') and (#h==2 or #h==4 or #h==6 or #h==8),'GSNL: invalid color hex')
            local bytes={};for i=1,#h,2 do bytes[#bytes+1]=tonumber(h:sub(i,i+1),16)end
            return color(unpack(bytes))
        end
        if r==nil then r,g,b,a=255,255,255,255
        elseif b==nil then r,g,b,a=r,r,r,g or 255 end
        return setmetatable({r=channel(r),g=channel(g),b=channel(b),a=channel(a or 255)},cm)
    end
    api.color=color
    function C:unpack()return self.r,self.g,self.b,self.a end
    function C:clone()return color(self:unpack())end
    function C:init(...)local c=color(...);self.r,self.g,self.b,self.a=c:unpack();return self end
    function C:to_fraction()return self.r/255,self.g/255,self.b/255,self.a/255 end
    function C:as_fraction(r,g,b,a)return self:init(r*255,g*255,b*255,(a or 1)*255)end
    function C:to_hex()return string.format('%02X%02X%02X%02X',self:unpack())end
    function C:lerp(b,t)return color(self.r+(b.r-self.r)*t,self.g+(b.g-self.g)*t,self.b+(b.b-self.b)*t,self.a+(b.a-self.a)*t)end
    function C:alpha_modulate(a)return color(self.r,self.g,self.b,a)end
    function C:grayscale(t)
        local gray=.299*self.r+.587*self.g+.114*self.b
        return self:lerp(color(gray,gray,gray,self.a),t or 1)
    end
    function C:to_int32()return self.r+self.g*256+self.b*65536+self.a*16777216 end
    function C:as_int32(n)
        finite(n);n=n%4294967296
        return self:init(n%256,math.floor(n/256)%256,math.floor(n/65536)%256,math.floor(n/16777216)%256)
    end

    local gm={};for k,v in pairs(math)do gm[k]=v end
    function gm.clamp(v,lo,hi)
        if lo==nil or hi==nil then fail('math.clamp','explicit min and max required')end
        assert(lo<=hi,'GSNL: inverted clamp range');return math.max(lo,math.min(hi,v))
    end
    function gm.map(v,a,b,c,d,clamp)
        assert(a~=b,'GSNL: zero input range');local t=(v-a)/(b-a)
        if clamp then t=gm.clamp(t,0,1)end;return c+(d-c)*t
    end
    function gm.normalize_yaw(v)return tonumber(native.gsnl_normalize_yaw(finite(v)))end
    function gm.difference(a,b)return math.abs(a-b)end
    api.math=gm
    function api.to_ticks(t)return math.floor(.5+finite(t)/gs.globals.tickinterval())end
    function api.to_time(t)return finite(t)*gs.globals.tickinterval()end
    local global_map={curtime='curtime',realtime='realtime',frametime='frametime',framecount='framecount',
        absoluteframetime='absoluteframetime',tickcount='tickcount',tickinterval='tickinterval',max_players='maxplayers',
        choked_commands='chokedcommands',commandack='commandack',commandack_prev='oldcommandack',last_outgoing_command='lastoutgoingcommand'}
    api.globals=setmetatable({}, {__index=function(_,key)
        local fn=global_map[key];if fn and type(gs.globals[fn])=='function' then return gs.globals[fn]()end
        fail('globals.'..tostring(key),'no verified host getter')
    end,__newindex=function()error('GSNL: globals are read-only',2)end})

    local E, em={},{}
    local function entity(idx)
        if idx==nil or idx<0 or gs.entity.get_classname(idx)==nil then return nil end
        return setmetatable({_index=idx},em)
    end
    em.__index=function(self,k)
        if E[k] then return E[k]end
        if type(k)=='string' and k:sub(1,2)=='m_' then
            local x,y,z=gs.entity.get_prop(self._index,k)
            if y~=nil and z~=nil then return vector(x,y,z)end
            return x
        end
        fail('entity:'..tostring(k))
    end
    em.__newindex=function(_,k)fail('entity.'..tostring(k),'direct netprop writes are not exposed; use gs.entity explicitly')end
    em.__eq=function(a,b)return a._index==b._index end
    em.__tostring=function(a)return 'entity('..a._index..')'end
    function E:get_index()return self._index end
    function E:get_name()return gs.entity.get_player_name(self._index)end
    function E:get_classname()return gs.entity.get_classname(self._index)end
    function E:is_player()return self:get_classname()=='CCSPlayer'end
    function E:is_dormant()return gs.entity.is_dormant(self._index)end
    function E:is_alive()return gs.entity.is_alive(self._index)end
    function E:is_enemy()return gs.entity.is_enemy(self._index)end
    function E:get_origin()local x,y,z=gs.entity.get_origin(self._index);if x then return vector(x,y,z)end end
    function E:get_angles()local x,y,z=gs.entity.get_prop(self._index,'m_angEyeAngles');if x then return vector(x,y,z)end end
    function E:get_simulation_time()return gs.entity.get_prop(self._index,'m_flSimulationTime')end
    function E:get_hitbox_position(h)local x,y,z=gs.entity.hitbox_position(self._index,h);if x then return vector(x,y,z)end end
    function E:get_player_weapon(all)if all then fail('entity:get_player_weapon','all_weapons overload not implemented')end;return entity(gs.entity.get_player_weapon(self._index))end
    function E:get_xuid()return gs.entity.get_steam64(self._index)end
    function E:get_eye_position()
        if self._index~=gs.entity.get_local_player()then fail('entity:get_eye_position','only local eye getter is verified')end
        local x,y,z=gs.client.eye_position();if x then return vector(x,y,z)end
    end
    function E:get_weapon_index()local n=gs.entity.get_prop(self._index,'m_iItemDefinitionIndex');return n and n%65536 end
    function E:get_weapon_owner()return entity(gs.entity.get_prop(self._index,'m_hOwnerEntity'))end
    function E:get_resource()return entity(gs.entity.get_player_resource())end
    api.entity=namespace('entity',{})
    function api.entity.get(idx,userid)if userid then idx=gs.client.userid_to_entindex(idx)end;return entity(idx)end
    function api.entity.get_local_player()return entity(gs.entity.get_local_player())end
    function api.entity.get_game_rules()return entity(gs.entity.get_game_rules())end
    function api.entity.get_player_resource()return entity(gs.entity.get_player_resource())end
    function api.entity.get_players(enemies,dormant,callback)
        local out={}
        for _,idx in ipairs(gs.entity.get_all('CCSPlayer'))do
            if (not enemies or gs.entity.is_enemy(idx)) and (dormant or not gs.entity.is_dormant(idx))then
                local e=entity(idx);if e then out[#out+1]=e;if callback then callback(e)end end
            end
        end
        if not callback then return out end
    end
    function api.entity.get_entities(class,dormant,callback)
        if class~=nil and type(class)~='string'then fail('entity.get_entities','numeric class IDs are unsupported')end
        local out={};for _,idx in ipairs(gs.entity.get_all(class))do
            if dormant or not gs.entity.is_dormant(idx)then local e=entity(idx);if e then out[#out+1]=e;if callback then callback(e)end end end
        end;if not callback then return out end
    end

    local alive,disposing,handles=true,false,{}
    local event_map={render='paint',createmove='setup_command',createmove_run='run_command',aim_fire='aim_fire',
        console_input='console_input',level_init='level_init',pre_render='pre_render',post_render='post_render',
        net_update_start='net_update_start',net_update_end='net_update_end',shutdown='shutdown',
        player_hurt='player_hurt',player_death='player_death',weapon_fire='weapon_fire',round_start='round_start',round_end='round_end',bullet_impact='bullet_impact'}
    local cmd_fields={choked_commands='chokedcommands',command_number='command_number',tickcount='tick_count',
        move_yaw='move_yaw',forwardmove='forwardmove',sidemove='sidemove',upmove='upmove'}
    local buttons={};for _,k in ipairs({'attack','attack2','use','jump','duck','walk','speed','reload','moveleft','moveright','forward','back','left','right','bullrush'})do buttons['in_'..k]=true end
    local function command(raw)
        local angles=setmetatable({}, {__index=function(_,key)
            if key=='x'then return raw.pitch elseif key=='y'then return raw.yaw elseif key=='z'then return 0 end
            if V[key]then return V[key]end;fail('UserCmd.view_angles.'..tostring(key))
        end,__newindex=function(_,key,value)
            if key=='x'then raw.pitch=finite(value)elseif key=='y'then raw.yaw=finite(value)
            elseif key~='z'or value~=0 then fail('UserCmd.view_angles.'..tostring(key),'roll is unsupported')end
        end})
        return setmetatable({}, {__index=function(_,k)
            if k=='view_angles'then return angles end
            if buttons[k]then return raw[k]==1 end
            if cmd_fields[k]then return raw[cmd_fields[k]]end
            fail('UserCmd.'..tostring(k),'field has no verified mapping')
        end,__newindex=function(_,k,v)
            if k=='view_angles'then raw.pitch,raw.yaw=finite(v.x),finite(v.y);return end
            if buttons[k]then assert(type(v)=='boolean','GSNL: button value must be boolean');raw[k]=v and 1 or 0;return end
            if k=='forwardmove'or k=='sidemove'or k=='upmove'or k=='move_yaw'then raw[k]=finite(v);return end
            fail('UserCmd.'..tostring(k),'field is read-only or unsupported')
        end})
    end
    local H={}
    function H:set(fn)
        assert(alive,'GSNL: bridge disposed');assert(type(fn)=='function','GSNL: callback must be a function')
        if self.callbacks[fn]then return end
        local wrapped=fn
        if self.name=='createmove'then wrapped=function(raw)
            local staged={};for k,v in pairs(raw)do staged[k]=v end
            -- An unsupported-field error must not leave a half-written attack
            -- or movement command behind. Commit only after a successful call.
            local result=fn(command(staged))
            for _,key in ipairs({'pitch','yaw','forwardmove','sidemove','upmove','move_yaw'})do
                if staged[key]~=raw[key]then raw[key]=staged[key]end
            end
            for key in pairs(buttons)do if staged[key]~=raw[key]then raw[key]=staged[key]end end
            return result
        end end
        if self.name=='aim_fire'then wrapped=function(raw)
            local e={};for k,v in pairs(raw)do e[k]=v end
            e.hitchance=raw.hit_chance;e.aim=vector(raw.x,raw.y,raw.z)
            return fn(e)
        end end
        if self.name=='createmove_run'then wrapped=function(raw)
            return fn(setmetatable({}, {__index=function(_,k)
                if k=='choked_commands'then return raw.chokedcommands end
                if k=='command_number'then return raw.command_number end
                fail('RunCommand.'..tostring(k),'host run_command does not expose this field')
            end,__newindex=function()error('GSNL: RunCommand is read-only',2)end}))
        end end
        local deliver=wrapped
        wrapped=function(...)if alive then return deliver(...)end end
        if self.name~='shutdown'then gs.client.set_event_callback(self.host,wrapped)end
        self.callbacks[fn]=wrapped
    end
    function H:unset(fn)
        local w=self.callbacks[fn]
        if w then if self.name~='shutdown'then gs.client.unset_event_callback(self.host,w)end;self.callbacks[fn]=nil end
    end
    function H:call(...)local list={};for fn in pairs(self.callbacks)do list[#list+1]=fn end;for _,fn in ipairs(list)do fn(...)end end
    local hm={__index=H,__call=function(h,fn,state)
        if state==nil then state=h.callbacks[fn]==nil end;if state then h:set(fn)else h:unset(fn)end
    end}
    api.events=setmetatable({}, {__index=function(_,name)
        if not event_map[name]then fail('events.'..tostring(name),'event or payload has no verified mapping')end
        if not handles[name]then handles[name]=setmetatable({name=name,host=event_map[name],callbacks={}},hm)end
        return handles[name]
    end})
    function api.dispose()
        if not alive or disposing then return end;disposing=true
        -- Deliver script cleanup while controls are still usable, independent
        -- of the host callback enumeration order. Cleanup failures cannot leak
        -- other registrations or prevent the remaining callbacks from running.
        local shutdown=handles.shutdown
        if shutdown then
            local callbacks={};for fn in pairs(shutdown.callbacks)do callbacks[#callbacks+1]=fn end
            for _,fn in ipairs(callbacks)do local ok,err=pcall(fn);if not ok then gs.client.log('GSNL shutdown: '..tostring(err))end end
        end
        alive=false
        for _,h in pairs(handles)do local callbacks={};for fn in pairs(h.callbacks)do callbacks[#callbacks+1]=fn end;for _,fn in ipairs(callbacks)do h:unset(fn)end end
    end
    gs.client.set_event_callback('shutdown',api.dispose)

    api.render=namespace('render',{})
    function api.render.screen_size()return vector(gs.client.screen_size())end
    function api.render.camera_position()return vector(gs.client.camera_position())end
    function api.render.camera_angles(a)
        if a then gs.client.camera_angles(a.x,a.y);return end
        return vector(gs.client.camera_angles())
    end
    function api.render.world_to_screen(p)local x,y=gs.renderer.world_to_screen(p.x,p.y,p.z);if x then return vector(x,y)end end
    function api.render.line(a,b,c,thickness)
        if thickness and thickness~=1 then fail('render.line','only thickness=1 supported')end
        gs.renderer.line(a.x,a.y,b.x,b.y,c:unpack())
    end
    function api.render.rect(a,b,c,rounding,no_clamp)
        if rounding and rounding~=0 or no_clamp then fail('render.rect','rounding/no_clamp overload unsupported')end
        gs.renderer.rectangle(a.x,a.y,b.x-a.x,b.y-a.y,c:unpack())
    end
    function api.render.circle(p,c,r,start,pct)gs.renderer.circle(p.x,p.y,c.r,c.g,c.b,c.a,r,start or 0,pct or 1)end
    function api.render.circle_outline(p,c,r,start,pct,thickness)gs.renderer.circle_outline(p.x,p.y,c.r,c.g,c.b,c.a,r,start or 0,pct or 1,thickness or 1)end
    function api.render.text(font,p,c,flags,text,...)
        if font~=nil then fail('render.text','custom font handles unsupported; use nil for GS default')end
        flags=flags or '';if flags:find('[^cbrd+%-]')then fail('render.text','unsupported text flags')end
        gs.renderer.text(p.x,p.y,c.r,c.g,c.b,c.a,flags,0,text,...)
    end
    function api.render.measure_text(font,flags,text)
        if font~=nil then fail('render.measure_text','custom font handles unsupported')end
        return vector(gs.renderer.measure_text(flags or '',text))
    end

    local I,G={},{}
    local im={__index=function(_,k)if I[k]then return I[k]end;fail('MenuItem:'..tostring(k))end}
    local function item(ref,kind,initial)
        assert(ref,'GSNL: host UI creation failed');return setmetatable({ref=ref,kind=kind,initial=initial,callbacks={}},im)
    end
    function I:get()if self.kind=='color_picker'then return color(gs.ui.get(self.ref))end;return gs.ui.get(self.ref)end
    function I:set(v,...)
        assert(alive,'GSNL: bridge disposed')
        if self.kind=='color_picker'then gs.ui.set(self.ref,v:unpack())else gs.ui.set(self.ref,v,...)end
    end
    function I:id()return self.ref end
    function I:type()return self.kind end
    function I:visibility(state)gs.ui.set_visible(self.ref,state)end
    function I:reset()if self.initial==nil then fail('MenuItem:reset','no default recorded for this control')end;self:set(self.initial)end
    function I:set_callback(fn,force)
        assert(type(fn)=='function','GSNL: callback must be a function')
        self.callbacks[fn]=true
        gs.ui.set_callback(self.ref,function()
            if not alive then return end
            local list={};for cb in pairs(self.callbacks)do list[#list+1]=cb end
            for _,cb in ipairs(list)do cb(self)end
        end)
        if force then fn(self)end
    end
    function I:unset_callback(fn)self.callbacks[fn]=nil end
    local function label(group,name)return '['..group.name..'] '..name end
    function G:switch(name,initial)
        local ref=gs.ui.new_checkbox('LUA','B',label(self,name));gs.ui.set(ref,initial or false)
        return item(ref,'switch',initial or false)
    end
    function G:slider(name,lo,hi,initial,scale,tooltip)
        if scale and scale~=1 or tooltip then fail('MenuGroup:slider','scale/tooltip overload unsupported')end
        initial=initial or lo;return item(gs.ui.new_slider('LUA','B',label(self,name),lo,hi,initial),'slider',initial)
    end
    local function options(items,...)if type(items)=='table'then return items end;return {items,...}end
    function G:combo(name,items,...)
        local list=options(items,...);return item(gs.ui.new_combobox('LUA','B',label(self,name),list),'combo',list[1])
    end
    function G:selectable(name,items,...)return item(gs.ui.new_multiselect('LUA','B',label(self,name),options(items,...)),'selectable',{})end
    function G:color_picker(name,c)
        c=c or color();return item(gs.ui.new_color_picker('LUA','B',label(self,name),c:unpack()),'color_picker',c:clone())
    end
    function G:button(name,callback,alt)
        if alt then fail('MenuGroup:button','alt_style unsupported')end
        return item(gs.ui.new_button('LUA','B',label(self,name),function()if alive then callback()end end),'button')
    end
    function G:input(name,text)
        local ref=gs.ui.new_textbox('LUA','B',label(self,name));if text then gs.ui.set(ref,text)end
        return item(ref,'input',text or '')
    end
    function G:label(text)return item(gs.ui.new_label('LUA','B',label(self,text)),'label')end
    local mappings={}
    function api.map_menu(path,...)
        assert(type(path)=='table','GSNL: menu path must be a table')
        local refs={...};assert(#refs>0,'GSNL: menu references required')
        local items={};for _,ref in ipairs(refs)do items[#items+1]=item(ref,'host')end
        mappings[table.concat(path,'\0')]=items
    end
    api.ui=namespace('ui',{})
    function api.ui.create(group,...)
        if select('#',...)>0 then fail('ui.create','only group overload supported; controls are placed in LUA/B')end
        return setmetatable({name=tostring(group)},{__index=function(_,k)if G[k]then return G[k]end;fail('MenuGroup:'..tostring(k))end})
    end
    function api.ui.find(...)
        local path={...};local found=mappings[table.concat(path,'\0')]
        if not found then fail('ui.find','register this path with api.map_menu; NL menu paths do not match GS')end
        return unpack(found)
    end
    function api.ui.get_size()return vector(gs.ui.menu_size())end
    function api.ui.get_position()return vector(gs.ui.menu_position())end
    function api.ui.get_mouse_position()return vector(gs.ui.mouse_position())end

    api.utils=namespace('utils',{
        console_exec=gs.client.exec,random_int=gs.client.random_int,
        random_float=gs.client.random_float,create_interface=gs.client.create_interface
    })
    function api.utils.execute_after(delay,callback,...)
        local args={...};local count=select('#',...)
        gs.client.delay_call(delay,function()if alive then callback(unpack(args,1,count))end end)
    end
    api.common=namespace('common',{get_timestamp=gs.client.timestamp,
        is_button_down=gs.client.key_state,set_clan_tag=gs.client.set_clan_tag})
    function api.common.get_unixtime()
        if type(gs.client.unix_time)~='function'then fail('common.get_unixtime','host unix_time getter unavailable')end
        return gs.client.unix_time()
    end
    function api.common.get_date(format,time)
        local host_os=gs.environment.os
        if not host_os or type(host_os.date)~='function'then fail('common.get_date','host os.date unavailable')end
        return host_os.date(format,time)
    end
    function api.common.get_system_time()
        local t=api.common.get_date('*t');return {year=t.year,month=t.month,day=t.day,hours=t.hour,minutes=t.min,seconds=t.sec}
    end
    api.json=namespace('json',{parse=gs.json.parse,stringify=gs.json.stringify})
    api.db=setmetatable({}, {__index=function(_,k)return gs.database.read('gsnl:'..tostring(k))end,
        __newindex=function(_,k,v)gs.database.write('gsnl:'..tostring(k),v)end})
    for _,name in ipairs({'rage','esp','materials','network','files','panorama','cvar'})do api[name]=namespace(name,{})end
    api.rage.antiaim=namespace('rage.antiaim',{})
    api.rage.exploit=namespace('rage.exploit',{})
    api.bit=gs.bit
    api.print=gs.client.log
    function api.new_class()
        local cls={};function cls:struct(name)return function(definition)
            assert(rawget(cls,name)==nil,'GSNL: duplicate struct')
            assert(type(definition)=='table','GSNL: struct definition must be a table')
            cls[name]=setmetatable(definition,{__index=cls});return cls
        end end;return cls
    end
    -- Run NL-style code with its own globals. Host GS tables remain available
    -- as gamesense/api.gs. This is compatibility isolation, not a security sandbox.
    function api.load(source,name)
        local fn,err=loadstring(source,name or '@gsnl-script');if not fn then return nil,err end
        local env={gamesense=gs,gsnl=api}
        env._G=env
        setmetatable(env,{__index=function(_,k)
            local v=rawget(api,k);if v~=nil then return v end
            if inventory[k] and inventory[k].status=='unavailable'then fail(k)end
            return gs.environment[k]
        end})
        setfenv(fn,env);return fn
    end
    return api
end
