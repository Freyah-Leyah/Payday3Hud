PD3Teammate = PD3Teammate or class(HUDTeammate)

PD3Hijack({
	global_to_hijack = HUDTeammate,  -- Target instance where functions will be hijacked
	func_to_hijack = { "_create_carry", "_create_radial_health", "set_health", "set_armor", "set_ammo_amount_by_type", "set_name" }, -- Name of the functions to hijack
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
	local main_player = i == HUDManager.PLAYER_PANEL
	self._id = i
	self._main_player = main_player
	self._PD3_panel = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2).panel

	local template_names = {
		"WWWWWWWWWWWWQWWW",
		"AI Teammate",
		"FutureCatCar",
		"WWWWWWWWWWWWQWWW"
	}

	local teammate_panel = self._PD3_panel:panel({
		align = "left",
		vertical = "bottom",
		visible = true,
		x = 0,
		name = "" .. i,
		w = 350,
		h = 80
	})

	self._player_panel_pd3 = teammate_panel:panel({
		name = "player_pd3"
	})

	self._health_data = {
		current = 0,
		total = 0
	}
	self._armor_data = {
		current = 0,
		total = 0
	}
	-- Set the panel to appear at the bottom of the screen
	teammate_panel:set_bottom(self._PD3_panel:h())

	if not main_player then
		teammate_panel:set_y(teammate_panel:y() - (70 * i))  -- Move up based on index
	end

	local bitmap = teammate_panel:bitmap({
		name = "panel_background_pd3",
		texture = "textures/HUDBackground",
		blend_mode = "normal",
		alpha = 0.6,
		x = 0,
		y = 0,
		w = teammate_panel:w(),
		h = teammate_panel:h() - 20
	})

	if not main_player then
		bitmap:set_w(bitmap:w() - 80)
		bitmap:set_alpha(0.2)
	end

	local name = teammate_panel:text({
		name = "name",
		vertical = "bottom",
		align = "left",
		y = 0,
		layer = 1,
		text = " " .. template_names[i],
		color = Color.white,
		font_size = tweak_data.hud_players.name_size,
		font = tweak_data.menu.pd2_large_font
	})

	managers.hud:make_fine_text(name)
	name:set_leftbottom(name:h(), teammate_panel:h() - 70 - 2)
	name:set_x(name:h() + 10)
	name:set_bottom(bitmap:h() - 40)

	self._name_panel = name

	-- Draw two bars in the middle of the panel
	local bar_width = teammate_panel:w() - 70  -- Slight margin on sides
	local bar_height = 4  -- Bar thickness

	-- Health Bar
	local health_bar = teammate_panel:rect({
		name = "health_bar",
		color = Color.white,
		alpha = 1,
		x = 40,
		layer = 10,
		y = (teammate_panel:h() / 2) - 7,  -- Centered
		w = bar_width,
		h = bar_height + 2
	})

	-- Armor Bar
	local armor_bar = teammate_panel:rect({
		name = "armor_bar",
		color = Color(1, 192/255, 43/255, 255/255),  -- RGBA: Purple
		alpha = 1,
		x = 40,
		layer = 10,
		y = health_bar:y() - 5,  -- Moves it slightly above
		w = bar_width,
		h = bar_height - 1
	})

	if not main_player then
		bar_width = bar_width - 75
		health_bar:set_w(bar_width)
		armor_bar:set_w(bar_width)
		health_bar:set_alpha(0.5)
		armor_bar:set_alpha(0.5)
	end

	self._health_bar = health_bar
	self._armor_bar = armor_bar

	local texture, rect = tweak_data.hud_icons:get_icon_data("pd2_mask_" .. i)
	local size = 64
	local mask_pad = 2
	local mask_pad_x = 17
	local mask_pad_y = 6
	local y = teammate_panel:h() - name:h() - size + mask_pad
	local mask = teammate_panel:bitmap({
		name = "mask",
		visible = true,
		layer = 1,
		color = Color.white,
		texture = texture,
		texture_rect = rect,
		x = - mask_pad_x,
		w = size,
		h = size,
		y = - mask_pad_y
	})

	if main_player then
		local weapons_panel = self._PD3_panel:panel({
			name = "weapons_panel_pd3",
			visible = true,
			align = "right",
			vertical = "bottom",
			layer = 2,
			x = self._PD3_panel:w() - 450,
			w = 800,
			h = 120
		})

		weapons_panel:set_bottom(self._PD3_panel:h() + 30)

		PD3Teammate._create_weapon_panel(self, weapons_panel)
	end
end

function PD3Teammate:set_name(teammate_name)
	local name = self._name_panel
	name:set_text(" " .. teammate_name)
end

function PD3Teammate:_create_weapon_panel(weapon_panel)
	local primary_bg = weapon_panel:bitmap({
		name = "wpn_panel_background_pd3_primary_bg",
		texture = "textures/SmallHUDBackground",
		blend_mode = "normal",
		alpha = 0.6,
		w = 120,
		h = 60
	})
	local secondary_bg = weapon_panel:bitmap({
		name = "wpn_panel_background_pd3_secondary_bg",
		texture = "textures/SmallHUDBackground",
		blend_mode = "normal",
		alpha = 0.6,
		w = 120,
		h = 60
	})
	local equipment_bg = weapon_panel:bitmap({
		name = "wpn_panel_background_pd3_equipment_bg",
		texture = "textures/SmallHUDBackground",
		blend_mode = "normal",
		alpha = 0.6,
		w = 80,
		h = 60
	})
	local grenades_bg = weapon_panel:bitmap({
		name = "wpn_panel_background_pd3_grenades_bg",
		texture = "textures/SmallHUDBackground",
		blend_mode = "normal",
		alpha = 0.6,
		w = 80,
		h = 60
	})
	local cable_ties_bg = weapon_panel:bitmap({
		name = "wpn_panel_background_pd3_cable_ties_bg",
		texture = "textures/SmallHUDBackground",
		blend_mode = "normal",
		alpha = 0.6,
		w = 80,
		h = 60
	})

	secondary_bg:set_x(primary_bg:w() - 24)
	equipment_bg:set_x(secondary_bg:x() + secondary_bg:w() - 8)
	grenades_bg:set_x(equipment_bg:x() + equipment_bg:w() - 13)
	cable_ties_bg:set_x(grenades_bg:x() + grenades_bg:w()- 13)

	local primary_ammo_counter_bg = weapon_panel:text({
		name = "wpn_primary_ammo_pd3_bg",
		text = "000",
		alpha = 0.5,
		layer = 6,
		blend_mode = "normal",
		font_size = 33,
		x = primary_bg:x(),
		y = primary_bg:y(),
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
	})
	local primary_ammo_counter = weapon_panel:text({
		name = "wpn_primary_ammo_pd3",
		text = "000",
		alpha = 0.9,
		layer = 7,
		blend_mode = "normal",
		font_size = 33,
		x = primary_bg:x(),
		y = primary_bg:y(),
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
	})

	local xp = 11

	if #primary_ammo_counter:text() == 3 then
		xp = 17
	end

	if #primary_ammo_counter:text() == 1 then
		xp = 5
	end

	managers.hud:make_fine_text(primary_ammo_counter_bg)
	primary_ammo_counter_bg:set_center((primary_bg:w() / 2) - 17, primary_bg:h() / 2)

	managers.hud:make_fine_text(primary_ammo_counter)
	primary_ammo_counter:set_center((primary_bg:w() / 2) - xp, primary_bg:h() / 2)

	local spare_primary_ammo_counter_bg = weapon_panel:text({
		name = "wpn_spare_primary_ammo_pd3_bg",
		text = "000",
		alpha = 0.3,
		layer = 6,
		blend_mode = "normal",
		font_size = 26,
		x = primary_bg:x(),
		y = primary_bg:y(),
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
	})
	local spare_primary_ammo_counter = weapon_panel:text({
		name = "wpn_spare_primary_ammo_pd3",
		text = "000",
		alpha = 0.9,
		layer = 7,
		blend_mode = "normal",
		font_size = 26,
		x = primary_bg:x(),
		y = primary_bg:y(),
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
	})

	local x = 44

	if #spare_primary_ammo_counter:text() == 3 then
		x = 34
	end

	if #spare_primary_ammo_counter:text() == 1 then
		x = 54
	end

	managers.hud:make_fine_text(spare_primary_ammo_counter_bg)
	spare_primary_ammo_counter_bg:set_x(spare_primary_ammo_counter_bg:w() + 35)
	spare_primary_ammo_counter_bg:set_y((spare_primary_ammo_counter_bg:h() / 2) + 15)

	managers.hud:make_fine_text(spare_primary_ammo_counter)
	spare_primary_ammo_counter:set_x(spare_primary_ammo_counter_bg:w() + x)
	spare_primary_ammo_counter:set_y((spare_primary_ammo_counter_bg:h() / 2) + 15)

	local function center_text(text_element, parent_panel)
		managers.hud:make_fine_text(text_element)
		text_element:set_center(parent_panel:x() + parent_panel:w() / 2, parent_panel:y() + parent_panel:h() / 2)
	end

	local secondary_ammo_counter_bg = weapon_panel:text({
		name = "wpn_secondary_ammo_pd3_bg",
		text = "000",
		alpha = 0.5,
		layer = 6,
		blend_mode = "normal",
		font_size = 33,
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
	})

	local secondary_ammo_counter = weapon_panel:text({
		name = "wpn_secondary_ammo_pd3",
		text = "000",
		alpha = 0.9,
		layer = 7,
		blend_mode = "normal",
		font_size = 33,
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
	})

	center_text(secondary_ammo_counter_bg, secondary_bg)
	center_text(secondary_ammo_counter, secondary_bg)

	local xps = 23

	if #secondary_ammo_counter:text() == 3 then
		xps = 17
	end

	if #secondary_ammo_counter:text() == 1 then
		xps = 5
	end

	secondary_ammo_counter_bg:set_x(secondary_ammo_counter_bg:x() - 17)
	secondary_ammo_counter:set_x(secondary_ammo_counter:x() - xps)

	local spare_secondary_ammo_counter_bg = weapon_panel:text({
		name = "wpn_spare_secondary_ammo_pd3_bg",
		text = "000",
		alpha = 0.3,
		layer = 6,
		blend_mode = "normal",
		font_size = 26,
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
	})

	local spare_secondary_ammo_counter = weapon_panel:text({
		name = "wpn_spare_secondary_ammo_pd3",
		text = "000",
		alpha = 0.9,
		layer = 7,
		blend_mode = "normal",
		font_size = 26,
		color = Color.white,
		font = tweak_data.menu.pd2_large_font,
	})

	center_text(spare_secondary_ammo_counter_bg, secondary_bg)
	center_text(spare_secondary_ammo_counter, secondary_bg)

	local xs = 22

	if #spare_secondary_ammo_counter:text() == 3 then
		xs = 17
	end

	if #spare_secondary_ammo_counter:text() == 1 then
		xs = 27
	end

	spare_secondary_ammo_counter_bg:set_x(spare_secondary_ammo_counter_bg:x() + 17)
	spare_secondary_ammo_counter:set_x(spare_secondary_ammo_counter:x() + xs)
	spare_secondary_ammo_counter:set_y((spare_secondary_ammo_counter_bg:h() / 2) + 15)
	spare_secondary_ammo_counter_bg:set_y((spare_secondary_ammo_counter_bg:h() / 2) + 15)
	self._spare_ammo_primary = spare_primary_ammo_counter
	self._spare_ammo_secondary = spare_secondary_ammo_counter
	self._ammo_primary = primary_ammo_counter
	self._ammo_secondary = secondary_ammo_counter
	self._ammo_primary_bg = primary_ammo_counter_bg
	self._ammo_secondary_bg = secondary_ammo_counter_bg
	self._spare_ammo_primary_bg = spare_primary_ammo_counter_bg
	self._spare_ammo_secondary_bg = spare_secondary_ammo_counter_bg
	self._ammo_primary_parent = primary_bg
	self._ammo_secondary_parent = secondary_bg
end

function PD3Teammate:set_ammo_amount_by_type(type, max_clip, current_clip, current_left, max, weapon_panel)
	local low_ammo = current_left <= math.round(max_clip / 2)
	local low_ammo_clip = current_clip <= math.round(max_clip / 4)

	local index = managers.player:equipped_weapon_unit():base():selection_index()

	-- Function to set alpha values
	local function set_ammo_display(primary_active)
		if primary_active then
			self._ammo_primary_bg:set_alpha(0.3)
			self._ammo_primary:set_alpha(1)
			self._ammo_primary_parent:set_alpha(0.6)
			self._spare_ammo_primary:set_alpha(0.9)

			self._ammo_secondary_bg:set_alpha(0.2)
			self._ammo_secondary:set_alpha(0.4)
			self._ammo_secondary_parent:set_alpha(0.4)
			self._spare_ammo_secondary:set_alpha(0.4)
		else
			self._ammo_secondary_bg:set_alpha(0.3)
			self._ammo_secondary:set_alpha(1)
			self._ammo_secondary_parent:set_alpha(0.6)
			self._spare_ammo_secondary:set_alpha(0.9)

			self._ammo_primary_bg:set_alpha(0.2)
			self._ammo_primary:set_alpha(0.4)
			self._ammo_primary_parent:set_alpha(0.4)
			self._spare_ammo_primary:set_alpha(0.4)
		end
	end

	-- Function to format numbers with leading zeros
	local function format_number(num)
		if num < 10 then return "00" .. num end
		if num < 100 then return "0" .. num end
		return tostring(num)
	end

	-- Function to set colors
	local function set_ammo_color(ammo_display, ammo_bg, spare_ammo_display, spare_ammo_bg, low_clip, low)
		if low_clip then
			ammo_display:set_color(Color(1, 255/255, 54/255, 54/255))
			ammo_bg:set_color(Color(1, 255/255, 54/255, 54/255))
		elseif low then
			spare_ammo_display:set_color(Color(1, 255/255, 54/255, 54/255))
			spare_ammo_bg:set_color(Color(1, 255/255, 54/255, 54/255))
		else
			ammo_display:set_color(Color.white)
			ammo_bg:set_color(Color.white)
			spare_ammo_display:set_color(Color.white)
			spare_ammo_bg:set_color(Color.white)
		end
	end

	-- Set correct ammo display based on weapon selection
	set_ammo_display(index == 2)

	-- Update ammo text values
	if type == "primary" then
		if self._ammo_primary then
			self._ammo_primary:set_text(tostring(current_clip))
			PD3Figure("weapon_panel", self._ammo_primary)
		end
		if self._spare_ammo_primary then
			self._spare_ammo_primary:set_text(tostring(current_left))
			PD3Figure("weapon_panel", self._spare_ammo_primary)
		end
		if self._ammo_primary_bg then
			self._ammo_primary_bg:set_text(format_number(current_clip))
		end
		if self._spare_ammo_primary_bg then
			self._spare_ammo_primary_bg:set_text(format_number(current_left))
		end
	elseif type == "secondary" then
		if self._ammo_secondary then
			self._ammo_secondary:set_text(tostring(current_clip))
			PD3Figure("weapon_panel", self._ammo_secondary)
		end
		if self._spare_ammo_secondary then
			self._spare_ammo_secondary:set_text(tostring(current_left))
			PD3Figure("weapon_panel", self._spare_ammo_secondary)
		end
		if self._ammo_secondary_bg then
			self._ammo_secondary_bg:set_text(format_number(current_clip))
		end
		if self._spare_ammo_secondary_bg then
			self._spare_ammo_secondary_bg:set_text(format_number(current_left))
		end
	end

	-- Update colors based on ammo count
	if type == "primary" then
		set_ammo_color(
			self._ammo_primary, self._ammo_primary_bg,
			self._spare_ammo_primary, self._spare_ammo_primary_bg,
			low_ammo_clip, low_ammo
		)
	elseif type == "secondary" then
		set_ammo_color(
			self._ammo_secondary, self._ammo_secondary_bg,
			self._spare_ammo_secondary, self._spare_ammo_secondary_bg,
			low_ammo_clip, low_ammo
		)
	end
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
	local teammate_panel = self._player_panel_pd3
	local health_bar = self._health_bar

	if health_bar then
		local health_ratio = math.clamp(data.current / data.total, 0, 1)
		local w = teammate_panel:w() - 70
		health_bar:set_w(w * health_ratio)
	end
end

function PD3Teammate:set_armor(data)
	self._armor_data = data
	local teammate_panel = self._player_panel_pd3
	local armor_bar = self._armor_bar

	if armor_bar then
		local armor_ratio = math.clamp(data.current / data.total, 0, 1)
		local w = teammate_panel:w() - 70

		if armor_ratio >= 0.97 then
			armor_ratio = 1
		end

		if armor_ratio <= 0.01 then
			-- for some reason armor_ratio never actually reaches "0" so we have to hide it manually, ovk pls?
			armor_bar:hide()
		else
			armor_bar:show()
		end

		armor_bar:set_w(w * armor_ratio)
	end
end