local module = ... or D:module("PDTH++")
local GroupAITweakData = module:hook_class("GroupAITweakData")

module:hook(GroupAITweakData, "_set_easy", function(self)
	self.difficulty_curve_points = { 0.35 }
	self.besiege.assault.sustain_duration_min = { 30, 70, 140 }
	self.besiege.assault.sustain_duration_max = { 40, 120, 200 }
	self.besiege.assault.delay = { 80, 50, 40 }
	self.besiege.assault.units = {
		cop = { 1, 0.2, 0 },
		swat = { 0.25, 0.75, 1 },
		shield = { 0, 0.1, 0.2 },
	}

	local is_singleplayer = Global.game_settings.single_player
	self.besiege.assault.force = is_singleplayer and { 10, 10, 15 } or { 10, 15, 20 }
	self.street.assault.force.aggressive = is_singleplayer and { 10, 13, 15 } or { 10, 15, 20 }
	self.street.assault.build_duration = 35
	self.street.assault.sustain_duration_min = { 30, 50, 70 }
	self.street.assault.sustain_duration_max = { 40, 60, 80 }
	self.street.assault.delay = { 40, 35, 30 }
	self.street.assault.units = {
		swat = { 1, 1, 1 },
		shield = { 0, 0.2, 0.2 },
	}
	self.street.blockade.units = {
		defend = {
			swat = { 1, 1, 1 },
			shield = { 0.1, 0.2, 0.3 },
		},
		frontal = {
			swat = { 1, 1, 1 },
			shield = { 0, 0.1, 0.3 },
		},
		flank = {
			fbi_special = { 1, 1, 1 },
		},
	}
end)

module:hook(GroupAITweakData, "_set_normal", function(self)
	self.difficulty_curve_points = { 0.25 }
	self.max_nr_simultaneous_boss_types = 4
	self.besiege.assault.sustain_duration_min = { 100, 120, 200 }
	self.besiege.assault.sustain_duration_max = { 150, 180, 300 }
	self.besiege.assault.delay = { 40, 35, 30 }
	self.besiege.assault.units = {
		cop = { 1, 0.5, 0 },
		swat = { 0.25, 0.8, 1 },
		swat_kevlar = { 0, 0.1, 0.2 },
		shield = { 0.2, 0.5, 0.5 },
	}

	local is_singleplayer = Global.game_settings.single_player
	self.besiege.assault.force = is_singleplayer and { 10, 10, 15 } or { 10, 15, 20 }
	self.street.assault.force.aggressive = is_singleplayer and { 10, 13, 15 } or { 15, 20, 23 }
	self.street.assault.build_duration = 35
	self.street.assault.sustain_duration_min = { 40, 60, 80 }
	self.street.assault.sustain_duration_max = { 50, 80, 100 }
	self.street.assault.delay = { 40, 35, 30 }
	self.street.assault.units = {
		swat = { 1, 1, 1 },
		swat_kevlar = { 0, 0.1, 0.12 },
		shield = { 0.2, 0.5, 0.5 },
	}
	self.street.blockade.units = {
		defend = {
			swat = { 1, 1, 1 },
			swat_kevlar = { 0, 0.09, 0.1 },
			shield = { 0.1, 0.2, 0.5 },
			tank = { 0, 0.1, 0.2 },
		},
		frontal = {
			swat = { 1, 1, 1 },
			shield = { 0, 0.1, 0.3 },
		},
		flank = {
			fbi_special = { 0.5, 1, 1 },
		},
	}
end)

module:hook(GroupAITweakData, "_set_hard", function(self)
	self.difficulty_curve_points = { 0.2 }
	self.max_nr_simultaneous_boss_types = 4
	self.besiege.assault.sustain_duration_min = { 150, 180, 250 }
	self.besiege.assault.sustain_duration_max = { 200, 220, 360 }
	self.besiege.assault.delay = { 40, 35, 30 }
	self.besiege.assault.units = {
		cop = { 1, 0.2, 0 },
		swat = { 0.5, 0.9, 0.8 },
		swat_kevlar = { 0, 0.4, 0.5 },
		shield = { 0.2, 0.5, 0.5 },
		tank = { 0, 0, 0.127 },
		spooc = { 0.2, 0.5, 0.65 },
		taser = { 0.05, 0.4, 0.5 },
	}

	local is_singleplayer = Global.game_settings.single_player
	self.besiege.assault.force = is_singleplayer and { 15, 20, 25 } or { 15, 20, 25 }
	self.street.assault.force.aggressive = is_singleplayer and { 15, 20, 25 } or { 15, 20, 25 }
	self.street.assault.build_duration = 35
	self.street.assault.sustain_duration_min = { 50, 70, 90 }
	self.street.assault.sustain_duration_max = { 60, 90, 120 }
	self.street.assault.delay = { 40, 35, 30 }
	self.street.assault.units = {
		swat = { 1, 1, 1 },
		swat_kevlar = { 0.2, 0.2, 0.2 },
		shield = { 0.2, 0.5, 0.5 },
		spooc = { 0.2, 0.5, 1 },
		taser = { 0.1, 0.3, 0.4 },
	}
	self.street.blockade.units = {
		defend = {
			swat = { 1, 1, 1 },
			swat_kevlar = { 0.3, 0.3, 0.3 },
			shield = { 0.1, 0.2, 0.3 },
		},
		frontal = {
			swat = { 1, 1, 1 },
			swat_kevlar = { 0.1, 0.2, 0.2 },
			shield = { 0, 0.1, 0.5 },
			spooc = { 0.1, 0.3, 0.4 },
		},
		flank = {
			spooc = { 1, 1, 1 },
			taser = { 1, 1, 1 },
			fbi = { 1, 1, 1 },
		},
	}
end)

module:hook(GroupAITweakData, "_set_overkill", function(self)
	self.difficulty_curve_points = { 0.2 }
	self.max_nr_simultaneous_boss_types = 4
	self.besiege.assault.build_duration = 30
	self.besiege.assault.sustain_duration_min = { 200, 280, 360 }
	self.besiege.assault.sustain_duration_max = { 200, 360, 400 }
	self.besiege.assault.delay = { 40, 35, 30 }
	self.besiege.assault.units = {
		cop = { 0.5, 0.1, 0 },
		swat = { 0.7, 0.7, 0.8 },
		swat_kevlar = { 0.25, 0.6, 0.6 },
		shield = { 0.5, 0.7, 0.9 },
		tank = { 0, 0.1, 0.2 },
		spooc = { 0.2, 0.7, 1 },
		taser = { 0.2, 0.3, 0.5 },
	}

	local is_singleplayer = Global.game_settings.single_player
	self.besiege.assault.force = is_singleplayer and { 15, 20, 25 } or { 15, 20, 25 }
	self.street.assault.force.aggressive = is_singleplayer and { 15, 20, 25 } or { 15, 20, 25 }
	self.besiege.recon.group_size = is_singleplayer and { 4, 4, 4 } or { 4, 4, 4 }
	self.besiege.recon.interval_variation = 7
	self.besiege.recon.interval = { 1, 1, 1 }
	self.besiege.recon.group_size = { 6, 6, 6 }
	self.besiege.rescue.group_size = { 4, 4, 4 }
	self.street.assault.build_duration = 35
	self.street.assault.sustain_duration_min = { 50, 90, 120 }
	self.street.assault.sustain_duration_max = { 60, 120, 160 }
	self.street.assault.delay = { 40, 35, 30 }
	self.street.assault.units = {
		swat = { 0.8, 0.7, 0.7 },
		swat_kevlar = { 0.4, 0.5, 0.5 },
		shield = { 0.5, 0.7, 0.8 },
		tank = { 0, 0.1, 0.2 },
		spooc = { 0.2, 0.7, 1 },
		taser = { 0.3, 0.35, 0.45 },
	}
	self.street.blockade.units = {
		defend = {
			swat = { 1, 0.6, 0.6 },
			swat_kevlar = { 0.3, 0.4, 0.5 },
			shield = { 0.7, 0.7, 0.7 },
		},
		frontal = {
			swat = { 1, 0.5, 0.5 },
			swat_kevlar = { 0.1, 0.1, 0.2 },
			shield = { 0, 0.1, 0.5 },
			spooc = { 0.1, 0.3, 0.4 },
		},
		flank = {
			spooc = { 1, 1, 1 },
			taser = { 1, 1, 1 },
			fbi = { 1, 1, 1 },
		},
	}
end)

module:hook(GroupAITweakData, "_set_overkill_145", function(self)
	self.difficulty_curve_points = { 0.1 }
	self.max_nr_simultaneous_boss_types = 4
	self.besiege.assault.build_duration = 30
	self.besiege.assault.sustain_duration_min = { 200, 360, 400 }
	self.besiege.assault.sustain_duration_max = { 200, 360, 400 }
	self.besiege.assault.delay = { 40, 35, 30 }
	self.besiege.assault.units = {
		cop = { 0.3, 0, 0 },
		swat = { 1, 0.7, 0.7 },
		swat_kevlar = { 0.5, 0.6, 0.8 },
		shield = { 0.5, 0.7, 0.8 },
		tank = { 0, 0.1, 0.2 },
		spooc = { 0.3, 0.9, 1 },
		taser = { 0.1, 0.4, 0.6 },
	}

	local is_singleplayer = Global.game_settings.single_player
	self.besiege.assault.force = is_singleplayer and { 15, 20, 25 } or { 15, 25, 25 }
	self.besiege.recon.group_size = is_singleplayer and { 2, 2, 2 } or { 4, 4, 4 }
	self.besiege.recon.interval_variation = 7
	self.besiege.recon.interval = { 1, 1, 1 }
	self.besiege.recon.group_size = { 6, 6, 6 }
	self.besiege.rescue.group_size = { 4, 4, 4 }
	self.street.assault.build_duration = 35
	self.street.assault.sustain_duration_min = { 60, 120, 160 }
	self.street.assault.sustain_duration_max = { 60, 120, 160 }
	self.street.assault.delay = { 40, 35, 30 }
	self.street.assault.units = {
		swat = { 0.7, 0.6, 0.5 },
		swat_kevlar = { 0.5, 0.5, 0.5 },
		shield = { 0.5, 0.7, 0.7 },
		tank = { 0, 0.1, 0.2 },
		spooc = { 0.2, 0.7, 1 },
		taser = { 0.4, 0.4, 0.5 },
	}
	self.street.blockade.units = {
		defend = {
			swat = { 0.7, 0.6, 0.6 },
			swat_kevlar = { 0.5, 0.5, 0.5 },
			shield = { 0.7, 0.9, 0.9 },
		},
		frontal = {
			swat = { 0.6, 0.5, 0.5 },
			swat_kevlar = { 0.2, 0.2, 0.3 },
			shield = { 0, 0.1, 0.5 },
			spooc = { 0.1, 0.3, 0.4 },
			fbi = { 0.5, 0.6, 0.6 },
		},
		flank = {
			spooc = { 1, 1, 1 },
			taser = { 1, 1, 1 },
			fbi = { 1, 1, 1 },
		},
	}
end)

module:post_hook(GroupAITweakData, "init", function(self)
	self.besiege.recon.units = {
		cop = { 0.25, 0, 0 },
		fbi = { 0.75, 1, 1 },
	}
	self.besiege.rescue.units = {
		cop = { 0.25, 0, 0 },
		fbi = { 0.75, 1, 1 },
	}
	self.street.capture.units = {
		cop = { 0.25, 0, 0 },
		fbi = { 0.75, 1, 0.1 },
	}

	local access_type_all = { "walk", "acrobatic" }
	table.merge(self.unit_categories, {
		fbi = {
			units = {
				Idstring("units/characters/enemies/fbi1/fbi1"),
				Idstring("units/characters/enemies/fbi2/fbi2"),
				Idstring("units/characters/enemies/fbi3/fbi3"),
			},
			access = access_type_all,
		},
		murky = {
			units = {
				Idstring("units/characters/enemies/murky_water1/murky_water1"),
				Idstring("units/characters/enemies/murky_water2/murky_water2"),
			},
			access = access_type_all,
		},
	})
end, false)
