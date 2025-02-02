_G.PD3Main = _G.PD3Main or class()

local pdebug = true

function PD3Main:log(...)
    if not pdebug then return end
    local message = "[PD3 HUD] " .. ...
    log(message)
end