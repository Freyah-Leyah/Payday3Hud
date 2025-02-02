PD3Teammate = PD3Teammate or class()

local VoidFuncs = {}
local function Void(global, func)
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

function HUDTeammate:init(i, teammates_panel, is_player, width)
	Void(self, { "init", "_create_carry", "_create_radial_health" })
end

function PD3Teammate:init(i, teammates_panel, is_player, width)
	self._id = i
	local small_gap = 8
	local gap = 0
	local pad = 4
	local main_player = i == HUDManager.PLAYER_PANEL
	self._main_player = main_player
	local names = {
		"WWWWWWWWWWWWQWWW",
		"AI Teammate",
		"FutureCatCar",
		"WWWWWWWWWWWWQWWW"
	}
	local teammate_panel = teammates_panel:panel({
		halign = "right",
		visible = false,
		x = 0,
		name = "" .. i,
		w = math.round(width)
	})
	self._panel = teammate_panel

	if not main_player then
		teammate_panel:set_h(84)
		teammate_panel:set_bottom(teammates_panel:h())
		teammate_panel:set_halign("left")
	end

	self._player_panel = teammate_panel:panel({
		name = "player"
	})
	self._health_data = {
		current = 0,
		total = 0
	}
	self._armor_data = {
		current = 0,
		total = 0
	}
	local name = teammate_panel:text({
		name = "name",
		vertical = "bottom",
		y = 0,
		layer = 1,
		text = " " .. names[i],
		color = Color.white,
		font_size = tweak_data.hud_players.name_size,
		font = tweak_data.hud_players.name_font
	})
	local _, _, name_w, _ = name:text_rect()

	managers.hud:make_fine_text(name)
	name:set_leftbottom(name:h(), teammate_panel:h() - 70 - 2)

	if not main_player then
		name:set_x(48 + name:h() + 4)
		name:set_bottom(teammate_panel:h() - 30)
	end

	local tabs_texture = "guis/textures/pd2/hud_tabs"
	local bg_rect = {
		84,
		0,
		44,
		32
	}
	local cs_rect = {
		84,
		34,
		19,
		19
	}
	local csbg_rect = {
		105,
		34,
		19,
		19
	}
	local bg_color = Color.white / 3

	teammate_panel:bitmap({
		name = "name_bg",
		visible = true,
		layer = 0,
		texture = tabs_texture,
		texture_rect = bg_rect,
		color = bg_color,
		x = name:x(),
		y = name:y() - 1,
		w = name_w + 4,
		h = name:h()
	})
	teammate_panel:bitmap({
		name = "callsign_bg",
		layer = 0,
		blend_mode = "normal",
		texture = tabs_texture,
		texture_rect = csbg_rect,
		color = bg_color,
		x = name:x() - name:h(),
		y = name:y() + 1,
		w = name:h() - 2,
		h = name:h() - 2
	})
	teammate_panel:bitmap({
		name = "callsign",
		layer = 1,
		blend_mode = "normal",
		texture = tabs_texture,
		texture_rect = cs_rect,
		color = (tweak_data.chat_colors[i] or tweak_data.chat_colors[#tweak_data.chat_colors]):with_alpha(1),
		x = name:x() - name:h(),
		y = name:y() + 1,
		w = name:h() - 2,
		h = name:h() - 2
	})

	local name_bg = teammate_panel:child("name_bg")

	self._panel:child("callsign_bg"):set_visible(false)
	self._panel:child("callsign"):set_visible(false)
	name_bg:set_h(name:h() + 4)

	local revive_panel = self._player_panel:panel({
		name = "revive_panel",
		w = name:h() - 1,
		h = name_bg:h()
	})

	revive_panel:set_center_y(name_bg:y() + name_bg:h() / 2)
	revive_panel:set_right(name_bg:x())
	revive_panel:bitmap({
		alpha = 0.8,
		name = "revive_bg",
		layer = 2
	})
	revive_panel:text({
		text = "2x",
		name = "revive_amount",
		font_size = 16,
		font = "fonts/font_medium_mf",
		align = "center",
		layer = 3,
		color = Color.white
	})

	local arrow_size = 14
	local arrow = revive_panel:bitmap({
		texture = "guis/textures/pd2/arrow_downcounter",
		name = "revive_arrow",
		layer = 3,
		y = revive_panel:h() - arrow_size + 1,
		h = arrow_size,
		w = arrow_size
	})

	arrow:set_center_x(revive_panel:w() / 2)

	local box_ai_bg = teammate_panel:bitmap({
		texture = "guis/textures/pd2/box_ai_bg",
		name = "box_ai_bg",
		alpha = 0,
		visible = false,
		y = 0,
		color = Color.white,
		w = teammate_panel:w()
	})

	box_ai_bg:set_bottom(name:top())

	local box_bg = teammate_panel:bitmap({
		texture = "guis/textures/pd2/box_bg",
		name = "box_bg",
		y = 0,
		visible = false,
		color = Color.white,
		w = teammate_panel:w()
	})

	box_bg:set_bottom(name:top())

	local texture, rect = tweak_data.hud_icons:get_icon_data("pd2_mask_" .. i)
	local size = 64
	local mask_pad = 2
	local mask_pad_x = 3
	local y = teammate_panel:h() - name:h() - size + mask_pad
	local mask = teammate_panel:bitmap({
		name = "mask",
		visible = false,
		layer = 1,
		color = Color.white,
		texture = texture,
		texture_rect = rect,
		x = -mask_pad_x,
		w = size,
		h = size,
		y = y
	})
	local radial_size = main_player and 64 or 48
	local radial_health_panel = self._player_panel:panel({
		name = "radial_health_panel",
		x = 0,
		layer = 1,
		w = radial_size + 4,
		h = radial_size + 4,
		y = mask:y()
	})

	radial_health_panel:set_bottom(self._player_panel:h())
	self:_create_radial_health(radial_health_panel, main_player)

	self._alt_ammo = managers.user:get_setting("alt_hud_ammo")
	local weapon_panel_w = 80
	local weapons_panel = self._player_panel:panel({
		name = "weapons_panel",
		visible = true,
		layer = 0,
		w = weapon_panel_w,
		h = radial_health_panel:h(),
		x = radial_health_panel:right() + 4,
		y = radial_health_panel:y()
	})

	self:_create_weapon_panels(weapons_panel)
	self:_create_equipment_panels(self._player_panel, weapons_panel:right(), weapons_panel:top(), weapons_panel:bottom())

	local bag_w = 32
	local bag_h = 31
	local carry_panel = self._player_panel:panel({
		name = "carry_panel",
		visible = false,
		x = 0,
		layer = 1,
		w = bag_w,
		h = bag_h + 2,
		y = radial_health_panel:top() - bag_h
	})

	self:_create_carry(carry_panel)

	local interact_panel = self._player_panel:panel({
		layer = 3,
		name = "interact_panel",
		visible = false
	})

	interact_panel:set_shape(weapons_panel:shape())
	interact_panel:set_shape(radial_health_panel:shape())
	interact_panel:set_size(radial_size * 1.25, radial_size * 1.25)
	interact_panel:set_center(radial_health_panel:center())

	local radius = interact_panel:h() / 2 - 4
	self._interact = CircleBitmapGuiObject:new(interact_panel, {
		blend_mode = "add",
		use_bg = true,
		rotation = 360,
		layer = 0,
		radius = radius,
		color = Color.white
	})

	self._interact:set_position(4, 4)

	self._special_equipment = {}

	self:create_waiting_panel(teammates_panel)
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