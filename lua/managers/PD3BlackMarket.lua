function BlackMarketManager:get_real_character(character_name, peer_id)
    -- !! may be useful later does not do anything other than vanilla for now !!
	local character = nil
    --log(tostring(peer_id), tostring(character_name))
	character = (not peer_id or not managers.network or not managers.network:session() or not managers.network:session():peer(peer_id) or managers.network:session():peer(peer_id):character()) and (character_name or self:get_preferred_character())

	return CriminalsManager.convert_old_to_new_character_workname(character)
end