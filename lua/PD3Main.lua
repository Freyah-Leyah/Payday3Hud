_G.PD3Main = _G.PD3Main or class()
PD3Main._path = ModPath
PD3Main._data_path = SavePath .. "PD3Hud.json"
PD3Main._data = {}

local pdebug = true

function PD3Main:log(...)
    if not pdebug then return end
    local message = "[PD3 HUD] " .. tostring(...)
    log(message)
end