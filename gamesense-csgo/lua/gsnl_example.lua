local api = require('gsnl')
local group = api.ui.create('GS + NL bridge')
local enabled = group:switch('Show bridge status', true)
api.events.render:set(function()
    if not enabled:get() then return end
    local s = api.native.snapshot()
    api.render.text(nil, api.vector(24, 220), api.color(170, 210, 255), '',
        'GSNL '..api.version..' | mode '..s.mode..' | points '..s.points_added)
end)
client.log('GSNL loaded. GS API stays available; use api.capability(name) to check NL support.')
