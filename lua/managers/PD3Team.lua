PD3Teammate = PD3Teammate or class(HUDTeammate)

PD3Hijack({
	global_to_hijack = HUDTeammate,  -- Target instance where functions will be hijacked
	func_to_hijack = { "_create_carry", "_create_radial_health", "set_health", "set_armor" }, -- Name of the functions to hijack
	global = PD3Teammate  -- Instance where the redirect functions exist
})

Hooks:PostHook(HUDTeammate, "init", "PD3Init", function(self, i, teammates_panel, is_player, width)
	if self._panel then
		self._panel:hide()
	end
	if self._player_panel then
		self._player_panel:hide()
	end
	if teammates_panel then
		teammates_panel:hide()
	end

	PD3Teammate.init(self, i, teammates_panel, is_player, width)
end)

function PD3Teammate:init(i, teammates_panel, is_player, width)

end

function PD3Teammate:_create_carry(carry_panel)
	self._carry_panel = carry_panel
	local tabs_texture = "guis/textures/pd2/hud_tabs"
	local bg_color = Color.white / 3
	local bag_rect = {
		32,
		33,
		32,
		31
	}
	local bg_rect = {
		84,
		0,
		44,
		32
	}
	local bag_w = bag_rect[3]
	local bag_h = bag_rect[4]

	carry_panel:set_x(24 - bag_w / 2)
	carry_panel:set_center_x(self._radial_health_panel:center_x())
	carry_panel:bitmap({
		name = "bg",
		visible = false,
		w = 100,
		layer = 0,
		y = 0,
		x = 0,
		texture = tabs_texture,
		texture_rect = bg_rect,
		color = bg_color,
		h = carry_panel:h()
	})
	carry_panel:bitmap({
		name = "bag",
		layer = 0,
		y = 1,
		visible = true,
		x = 1,
		texture = tabs_texture,
		w = bag_w,
		h = bag_h,
		texture_rect = bag_rect,
		color = Color.white
	})
	carry_panel:text({
		y = 0,
		vertical = "center",
		name = "value",
		text = "",
		font = "fonts/font_small_mf",
		visible = false,
		layer = 0,
		color = Color.white,
		x = bag_rect[3] + 4,
		font_size = tweak_data.hud.small_font_size
	})
end

function PD3Teammate:_create_radial_health(radial_health_panel)
	self._radial_health_panel = radial_health_panel
	local radial_size = self._main_player and 64 or 48
	local radial_bg = radial_health_panel:bitmap({
		texture = "guis/textures/pd2/hud_radialbg",
		name = "radial_bg",
		alpha = 1,
		layer = 0,
		w = radial_health_panel:w(),
		h = radial_health_panel:h()
	})
	local radial_health = radial_health_panel:bitmap({
		texture = "guis/textures/pd2/hud_health",
		name = "radial_health",
		layer = 2,
		blend_mode = "add",
		render_template = "VertexColorTexturedRadial",
		texture_rect = {
			128,
			0,
			-128,
			128
		},
		color = Color(1, 0, 1, 1),
		w = radial_health_panel:w(),
		h = radial_health_panel:h()
	})
	local radial_shield = radial_health_panel:bitmap({
		texture = "guis/textures/pd2/hud_shield",
		name = "radial_shield",
		layer = 1,
		blend_mode = "add",
		render_template = "VertexColorTexturedRadial",
		texture_rect = {
			128,
			0,
			-128,
			128
		},
		color = Color(1, 0, 1, 1),
		w = radial_health_panel:w(),
		h = radial_health_panel:h()
	})
	local damage_indicator = radial_health_panel:bitmap({
		blend_mode = "add",
		name = "damage_indicator",
		alpha = 0,
		texture = "guis/textures/pd2/hud_radial_rim",
		layer = 1,
		color = Color(1, 1, 1, 1),
		w = radial_health_panel:w(),
		h = radial_health_panel:h()
	})
	local radial_custom = radial_health_panel:bitmap({
		texture = "guis/textures/pd2/hud_swansong",
		name = "radial_custom",
		blend_mode = "add",
		visible = false,
		render_template = "VertexColorTexturedRadial",
		layer = 5,
		color = Color(1, 0, 0, 0),
		w = radial_health_panel:w(),
		h = radial_health_panel:h()
	})
	local radial_ability_panel = radial_health_panel:panel({
		visible = false,
		name = "radial_ability"
	})
	local radial_ability_meter = radial_ability_panel:bitmap({
		blend_mode = "add",
		name = "ability_meter",
		texture = "guis/textures/pd2/hud_fearless",
		render_template = "VertexColorTexturedRadial",
		layer = 5,
		color = Color(1, 0, 0, 0),
		w = radial_health_panel:w(),
		h = radial_health_panel:h()
	})
	local radial_ability_icon = radial_ability_panel:bitmap({
		blend_mode = "add",
		name = "ability_icon",
		alpha = 1,
		layer = 5,
		w = radial_size * 0.5,
		h = radial_size * 0.5
	})

	radial_ability_icon:set_center(radial_ability_panel:center())

	local radial_delayed_damage_panel = radial_health_panel:panel({
		name = "radial_delayed_damage"
	})
	local radial_delayed_damage_armor = radial_delayed_damage_panel:bitmap({
		texture = "guis/textures/pd2/hud_dot_shield",
		name = "radial_delayed_damage_armor",
		visible = false,
		render_template = "VertexColorTexturedRadialFlex",
		layer = 5,
		w = radial_delayed_damage_panel:w(),
		h = radial_delayed_damage_panel:h()
	})
	local radial_delayed_damage_health = radial_delayed_damage_panel:bitmap({
		texture = "guis/textures/pd2/hud_dot",
		name = "radial_delayed_damage_health",
		visible = false,
		render_template = "VertexColorTexturedRadialFlex",
		layer = 5,
		w = radial_delayed_damage_panel:w(),
		h = radial_delayed_damage_panel:h()
	})

	if self._main_player then
		local radial_rip = radial_health_panel:bitmap({
			texture = "guis/textures/pd2/hud_rip",
			name = "radial_rip",
			layer = 3,
			blend_mode = "add",
			visible = false,
			render_template = "VertexColorTexturedRadial",
			texture_rect = {
				128,
				0,
				-128,
				128
			},
			color = Color(1, 0, 0, 0),
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})
		local radial_rip_bg = radial_health_panel:bitmap({
			texture = "guis/textures/pd2/hud_rip_bg",
			name = "radial_rip_bg",
			layer = 1,
			visible = false,
			render_template = "VertexColorTexturedRadial",
			texture_rect = {
				128,
				0,
				-128,
				128
			},
			color = Color(1, 0, 0, 0),
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})
	end

	radial_health_panel:bitmap({
		texture = "guis/dlcs/coco/textures/pd2/hud_absorb_shield",
		name = "radial_absorb_shield_active",
		visible = false,
		render_template = "VertexColorTexturedRadial",
		layer = 5,
		color = Color(1, 0, 0, 0),
		w = radial_health_panel:w(),
		h = radial_health_panel:h()
	})

	local radial_absorb_health_active = radial_health_panel:bitmap({
		texture = "guis/dlcs/coco/textures/pd2/hud_absorb_health",
		name = "radial_absorb_health_active",
		visible = false,
		render_template = "VertexColorTexturedRadial",
		layer = 5,
		color = Color(1, 0, 0, 0),
		w = radial_health_panel:w(),
		h = radial_health_panel:h()
	})

	radial_absorb_health_active:animate(callback(self, self, "animate_update_absorb_active"))
	radial_health_panel:bitmap({
		texture = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_fg",
		name = "radial_info_meter",
		blend_mode = "add",
		visible = false,
		render_template = "VertexColorTexturedRadial",
		layer = 3,
		color = Color(1, 0, 0, 0),
		w = radial_health_panel:w(),
		h = radial_health_panel:h()
	})
	radial_health_panel:bitmap({
		texture = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_bg",
		name = "radial_info_meter_bg",
		layer = 1,
		visible = false,
		render_template = "VertexColorTexturedRadial",
		texture_rect = {
			128,
			0,
			-128,
			128
		},
		color = Color(1, 0, 0, 0),
		w = radial_health_panel:w(),
		h = radial_health_panel:h()
	})

	local copr_overlay_panel = radial_health_panel:panel({
		name = "copr_overlay_panel",
		layer = 3,
		w = radial_health_panel:w(),
		h = radial_health_panel:h()
	})

	self:_create_condition(radial_health_panel)
end

function PD3Teammate:set_health(data)
	self._health_data = data
	local teammate_panel = self._panel:child("player")
	local radial_health_panel = self._radial_health_panel
	local radial_health = radial_health_panel:child("radial_health")
	local radial_rip = radial_health_panel:child("radial_rip")
	local radial_rip_bg = radial_health_panel:child("radial_rip_bg")
	local red = data.current / data.total

	if managers.player:has_activate_temporary_upgrade("temporary", "copr_ability") and self._id == HUDManager.PLAYER_PANEL then
		local static_damage_ratio = managers.player:upgrade_value_nil("player", "copr_static_damage_ratio")

		if static_damage_ratio then
			red = math.floor((red + 0.01) / static_damage_ratio) * static_damage_ratio
		end

		local copr_overlay_panel = radial_health_panel:child("copr_overlay_panel")

		if alive(copr_overlay_panel) then
			for _, notch in ipairs(copr_overlay_panel:children()) do
				notch:set_visible(notch:script().red <= red + 0.01)
			end
		end
	end

	radial_health:stop()

	if red < radial_health:color().red then
		self:_damage_taken()
		radial_health:set_color(Color(1, red, 1, 1))

		if alive(radial_rip) then
			radial_rip:set_rotation((1 - radial_health:color().r) * 360)
			radial_rip_bg:set_rotation((1 - radial_health:color().r) * 360)
		end

		self:update_delayed_damage()
	else
		radial_health:animate(function (o)
			local s = radial_health:color().r
			local e = red
			local health_ratio = nil

			over(0.2, function (p)
				health_ratio = math.lerp(s, e, p)

				radial_health:set_color(Color(1, health_ratio, 1, 1))

				if alive(radial_rip) then
					radial_rip:set_rotation((1 - radial_health:color().r) * 360)
					radial_rip_bg:set_rotation((1 - radial_health:color().r) * 360)
				end

				self:update_delayed_damage()

				local copr_overlay_panel = radial_health_panel:child("copr_overlay_panel")

				if alive(copr_overlay_panel) then
					for _, notch in ipairs(copr_overlay_panel:children()) do
						notch:set_visible(notch:script().red <= health_ratio + 0.01)
					end
				end
			end)
		end)
	end
end

function PD3Teammate:set_armor(data)
	local teammate_panel = self._panel:child("player")
	self._armor_data = data
	local radial_health_panel = self._radial_health_panel
	local radial_shield = radial_health_panel:child("radial_shield")
	local ratio = data.total ~= 0 and data.current / data.total or 0

	radial_shield:set_color(Color(1, ratio, 1, 1))
	self:update_delayed_damage()
end