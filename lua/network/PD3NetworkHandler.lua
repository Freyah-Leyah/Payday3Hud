_G.PD3NetworkHandler = _G.PD3NetworkHandler or class(UnitNetworkHandler)

PD3Hijack({
	global_to_hijack = UnitNetworkHandler,  -- Target instance where functions will be hijacked
	func_to_hijack = { "sync_ammo_amount" }, -- Name of the functions to hijack
	global = PD3NetworkHandler  -- Instance where the redirect functions exist
})

function PD3NetworkHandler:sync_ammo_amount(selection_index, max_clip, current_clip, current_left, max, sender)
    -- !!TO DO!! commented out cuz crashing with vanilla stuff being sent to host/peer

	-- local peer = self._verify_sender(sender)

	-- if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
	-- 	return
	-- end

	-- managers.player:set_synced_ammo_info(peer:id(), selection_index, max_clip, current_clip, current_left, max)
end