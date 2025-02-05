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
            --PD3Main:log(tostring(fun_hijack) .. " hijacked")
            HijackFunc[fun_hijack] = true

            -- Hijacking function
            global_to_hijack[fun_hijack] = function(self,...)
                --PD3Main:log("Calling " .. tostring(fun_hijack) .. " in " .. tostring(global))

                -- Ensure the function exists before calling
                if global[fun_hijack] then
                    return global[fun_hijack](self, ...)
                else
                    PD3Main:log("ERROR: Function " .. tostring(fun_hijack) .. " not found in redirect class!")
                end
            end
        end
    end
end

local function remove_prefix(str)
    return (tostring(str):gsub("^heister_icon_", ""))
end

PD3Figure_OriginalPositions = {}
function PD3Figure(type, obj)
    if type == "weapon_panel" then
        local text_length = #obj:text()
        local lenghts = {
            wpn_primary_ammo_pd3 = {
                12,
                12,
                -12,
                -12
            },
            wpn_spare_primary_ammo_pd3 = {
                10,
                10,
                1,
                -12
            },
            wpn_secondary_ammo_pd3 = {
                24,
                12,
                -24,
                -12
            },
            wpn_spare_secondary_ammo_pd3 = {
                10,
                10,
                0,
                -10
            }
        }

        if not obj:name() then
            return
        end

        if text_length == 1 then
            if not PD3Figure_OriginalPositions[obj:name() .. text_length] then
                obj:set_x(obj:x() + lenghts[obj:name()][text_length])
                PD3Figure_OriginalPositions[obj:name() .. text_length] = obj:x()
            end
            obj:set_x(PD3Figure_OriginalPositions[obj:name() .. text_length])
            return
        end


        if text_length == 2 then
            if not PD3Figure_OriginalPositions[obj:name() .. text_length] then
                obj:set_x(obj:x() + lenghts[obj:name()][text_length])
                PD3Figure_OriginalPositions[obj:name() .. text_length] = obj:x()
            end
            obj:set_x(PD3Figure_OriginalPositions[obj:name() .. text_length])
            return
        end

        if text_length == 3 then
            if not PD3Figure_OriginalPositions[obj:name() .. text_length] then
                obj:set_x(obj:x() + lenghts[obj:name()][text_length])
                PD3Figure_OriginalPositions[obj:name() .. text_length] = obj:x()
            end
            obj:set_x(PD3Figure_OriginalPositions[obj:name() .. text_length])
            return
        end

        if text_length == 4 then
            if not PD3Figure_OriginalPositions[obj:name() .. text_length] then
                obj:set_x(obj:x() + lenghts[obj:name()][text_length])
                PD3Figure_OriginalPositions[obj:name() .. text_length] = obj:x()
            end
            obj:set_x(PD3Figure_OriginalPositions[obj:name() .. text_length])
            return
        end
    end

    if type == "heister_icon" then
        local sizes = {
            bonnie = { w = 48, h = 48 },
            female_1 = { w = 48, h = 48 },
            dragan = { w = 48, h = 48 },
            american = { w = 48, h = 48 },
            dragon = { w = 48, h = 48 },
            russian = { w = 48, h = 48 },
            chico = { w = 48, h = 48 },
            sokol = { w = 48, h = 48 },
            sydney = { w = 48, h = 48 },
            old_hoxton = { w = 48, h = 48 },
            jowi = { w = 48, h = 48 },
            german = { w = 48, h = 48 },
            bodhi = { w = 48, h = 48 },
            spanish = { w = 48, h = 48 },
            myh = { w = 48, h = 48 },
            ecp_male = { w = 48, h = 48 },
            ecp_female = { w = 48, h = 48 },
            jacket = { w = 48, h = 48 },
            jimmy = { w = 48, h = 48 },
            joy = { w = 48, h = 48 },
            wild = { w = 48, h = 48 },
            max = { w = 48, h = 48 },
        }
        local positons = {
            bonnie = { x = -10 , y = -6 },
            female_1 = { x = -10 , y = -6 },
            dragan = { x = -10 , y = -6 },
            american = { x = -10 , y = -6 },
            dragon = { x = -10 , y = -6 },
            russian = { x = -10 , y = -6 },
            chico = { x = -10 , y = -6 },
            sokol = { x = -10 , y = -6 },
            sydney = { x = -10 , y = -6 },
            old_hoxton = { x = -10 , y = -6 },
            jowi = { x = -10 , y = -6 },
            german = { x = -10 , y = -6 },
            bodhi = { x = -10 , y = -6 },
            spanish = { x = -10 , y = -6 },
            myh = { x = -10 , y = -6 },
            ecp_male = { x = -10 , y = -6 },
            ecp_female = { x = -10 , y = -6 },
            jacket = { x = -10 , y = -6 },
            jimmy = { x = -10 , y = -6 },
            joy = { x = -10 , y = -6 },
            wild = { x = -10 , y = -6 },
            max = { x = -10 , y = -6 },
        }

        if obj then
            if obj:name() then
                local index = remove_prefix(tostring(obj:name()))
                if index and sizes[index] and positons[index]  then
                    PD3Main:log("[PD3Figure] setting sizes and positons for " .. tostring(index))
                    obj:set_w(sizes[index].w)
                    obj:set_h(sizes[index].h)
                    obj:set_x(positons[index].x)
                    obj:set_y(positons[index].y)
                else
                    PD3Main:log("[ERROR] obj:name() is incorrect! (heister name expected, got " .. index .. ")")
                end
            else
                PD3Main:log("[ERROR] obj:name() is invalid! (bitmap name expected, got nil)")
            end
        else
            PD3Main:log("[ERROR] obj is invalid! (bitmap expected, got nil)")
        end
    end
end