Hooks:PostHook(HUDManager, "add_teammate_panel", "add_teammate_panel_PD3", function (self, character_name, player_name, ai, peer_id)
    self._teammate_panels_PD3 = self._teammate_panels_PD3 or {}
    self._players_present = (self._players_present or 0)
    local teammate_panel = PD3Teammate:_get_stored_data("teammate_panels")
    local name = PD3Teammate:_get_stored_data("_name_panel")

    -- log(tostring(ai), tostring(peer_id))

    self._teammate_panels_PD3 = teammate_panel

    self._players_present = self._players_present + 1

    if not teammate_panel then
        log("teammate_panel does not exist!")
        return
    end

    if not name then
        log("_name_panel does not exist!")
        return
    end

    for i=1, self._players_present do
        log("teammate_panel.linked_to", tostring(self._teammate_panels_PD3[i].linked_to))
        log("self._teammate_panels_PD3.taken", tostring(self._teammate_panels_PD3[i].taken))
        if not self._teammate_panels_PD3[i].taken then
            PD3Teammate:set_player_portrait(i, character_name)
            self._teammate_panels_PD3[i].taken = true
        end
    end
end)

Hooks:PostHook(HUDManager, "remove_teammate_panel", "remove_teammate_panel_PD3", function (self, id)
    -- !!TO DO!! 
    -- log(tostring(id))
end)

-- function HUDManager:remove_teammate_panel(id)
-- 	self._teammate_panels[id]:remove_panel()

-- 	local panel_data = self._hud.teammate_panels_data[id]
-- 	panel_data.taken = false
-- 	local is_ai = self._teammate_panels[HUDManager.PLAYER_PANEL]._ai

-- 	if self._teammate_panels[HUDManager.PLAYER_PANEL]._peer_id and self._teammate_panels[HUDManager.PLAYER_PANEL]._peer_id ~= managers.network:session():local_peer():id() or is_ai then
-- 		print(" MOVE!!!", self._teammate_panels[HUDManager.PLAYER_PANEL]._peer_id, is_ai)

-- 		local peer_id = self._teammate_panels[HUDManager.PLAYER_PANEL]._peer_id

-- 		self:remove_teammate_panel(HUDManager.PLAYER_PANEL)

-- 		if is_ai then
-- 			local character_name = managers.criminals:character_name_by_panel_id(HUDManager.PLAYER_PANEL)
-- 			local name = managers.localization:text("menu_" .. character_name)
-- 			local panel_id = self:add_teammate_panel(character_name, name, true, nil)
-- 			managers.criminals:character_data_by_name(character_name).panel_id = panel_id
-- 		else
-- 			local character_name = managers.criminals:character_name_by_peer_id(peer_id)
-- 			local panel_id = self:add_teammate_panel(character_name, managers.network:session():peer(peer_id):name(), false, peer_id)
-- 			managers.criminals:character_data_by_name(character_name).panel_id = panel_id
-- 		end
-- 	end

-- 	managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]:add_panel()
-- 	managers.hud._teammate_panels[HUDManager.PLAYER_PANEL]:set_state("player")
-- end