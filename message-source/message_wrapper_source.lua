-- Original outer wrapper, rewritten with descriptive names.
local http = require("gamesense/http")
local ffi = require("ffi")
local original_tostring = _G.tostring
local original_loadstring = _G.loadstring
local tostring_identity = tostring(_G.tostring)
local loadstring_identity = tostring(_G.loadstring)
local cast_identity = tostring(ffi.cast)
_G.tostring = function(...)
    local arguments = {...}
    local value = unpack(arguments)
    if value == _G.tostring then return tostring_identity end
    if value == _G.loadstring then return loadstring_identity end
    if value == ffi.cast then return cast_identity end
    return unpack({original_tostring(value)})
end
http.get("https://gist.githubusercontent.com/glockcodes/32f44164f8ede11e86507b920d1d9be9/raw/b26af48e0b4290a917a9e3cf57e5ca1f1da0abbb/module.txt", function(success, response)
    if not success or response.status ~= 200 then
        print("failed to connect to lagoon server")
        return
    end
    _G.loadstring = function(...)
        return original_loadstring(response.body)
    end
end)
local original_panorama_loadstring = _G.panorama.loadstring
_G.panorama.loadstring = function(...)
    local arguments = {...}
    local javascript = unpack(arguments)
    -- The second form is the decoded equivalent used by the recovered loader.
    if javascript:find("_0x3293") or javascript == "return Date.now();" then
        return original_panorama_loadstring("return 0;")
    end
    return original_panorama_loadstring(...)
end
local original_text = _G.renderer.text
_G.renderer.text = function(x, y, red, green, blue, alpha, flags, max_width, ...)
    local text = table.concat({...})
    if text:find("D") then
        return original_text(x, y, red, green, blue, alpha, flags, max_width, "ACATEL [BETA]")
    end
    return original_text(x, y, red, green, blue, alpha, flags, max_width, ...)
end
local original_color_log = _G.client.color_log
_G.client.color_log = function(...)
    local text = table.concat({...})
    if text:find("D") then return original_color_log(255, 255, 255, "Thanks for using acatel") end
    return original_color_log(...)
end
local original_cast = ffi.cast
ffi.cast = function(kind, address)
    if kind == "void*" then
        void_star = original_cast(kind, address) or error("steam_http error")
    end
    if kind == "create_http_request_t" then
        create_http_request_t = original_cast(kind, address) or error("create_http_request_t error")
        return function(...)
            args = {...}
            if args[3]:find("success") then
                return create_http_request_t(void_star, 3, "https://lagoon.solutions/privategibberishsmiley/acatel_beta/success.txt")
            end
            return create_http_request_t(void_star, 3, "https://lagoon.solutions/privategibberishsmiley/acatel_beta/find.txt")
        end
    end
    return original_cast(kind, address)
end
