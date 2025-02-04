_G.PD3HUDManager = _G.PD3HUDManager or class(HUDManager)

Hooks:PostHook(HUDManager, "_create_teammates_panel", "_create_teammates_panelPD3", function (self, character_name, player_name, ai, peer_id)
    local character_texture = nil
	local character = nil
    local id = peer_id
    local teammate_panel = PD3Teammate:_get_stored_data("_teammate_panel")
    local name = PD3Teammate:_get_stored_data("_name_panel")

    if not teammate_panel then
        log("teammate_panel does not exist!")
        return
    end

    if not name then
        log("_name_panel does not exist!")
        return
    end

    -- !!this works but places all icons at local player panel, i was too sleepy to think of anything else. this entire thing makes me wanna kms!!

    if character_name then
        character_texture = "textures/" .. tostring(character_name)
        PD3Main:log(tostring(character_texture))

        local size = 64
        local heister_pad_x = 17
        local heister_pad_y = 6
        local heister = teammate_panel:bitmap({
            name = "heister" .. tostring(id),
            visible = true,
            layer = 2,
            texture = character_texture or "",
            x = -heister_pad_x,
            y = -heister_pad_y,
            w = size,
            h = size,
            blend_mode = "normal",
            render_template = "VertexColorTextured"
        })
	else
		character = managers.criminals:character_name_by_peer_id(managers.network:session():local_peer():id())
		if character then
			character_texture = "textures/" .. tostring(character)
		end

		PD3Main:log(tostring(character_texture) .. " main player")

		local size = 64
		local heister_pad = 2
		local heister_pad_x = 17
		local heister_pad_y = 6
		local y = teammate_panel:h() - name:h() - size + heister_pad
		local heister = teammate_panel:bitmap({
			name = "heister_main",
			visible = true,
			layer = 2,
			texture = character_texture or "", -- no idea what to put here
			x = - heister_pad_x,
			y = - heister_pad_y,
			blend_mode = "normal",
			render_template = "VertexColorTextured"
		})
	end
end)