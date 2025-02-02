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

local VoidFuncs = {}
function PD3Void(global, func)
	for _, fun in pairs(func) do
		if not VoidFuncs[fun] then
			PD3Main:log(tostring(fun) .. " purged to Void")
			VoidFuncs[fun] = true
			global[fun] = function(...)
				PD3Main:log(tostring(fun) .. " called from Void")
				return nil
			end
		end
	end
end

local HijackFunc = {}
function PD3Hijack(hijack_data)
    local func_to_hijack = hijack_data.func_to_hijack
    local global_to_hijack = hijack_data.global_to_hijack
    local global = hijack_data.global

    for _, fun_hijack in pairs(func_to_hijack) do
        if not HijackFunc[fun_hijack] then
            PD3Main:log(tostring(fun_hijack) .. " hijacked")
            HijackFunc[fun_hijack] = true

            -- Hijacking function
            global_to_hijack[fun_hijack] = function(self,...)
                PD3Main:log("Calling " .. tostring(fun_hijack) .. " in " .. tostring(global))

                -- Ensure the function exists before calling
                if global[fun_hijack] then
                    return global[fun_hijack](self, ...)
                else
                    PD3Main:log("ERROR: Function " .. tostring(fun_hijack) .. " not found in global!")
                end
            end
        end
    end
end