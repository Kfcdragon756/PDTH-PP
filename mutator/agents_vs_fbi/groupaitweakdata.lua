local module = ... or D:module("PDTH++")
local GroupAITweakData = module:hook_class("GroupAITweakData")

function GroupAITweakData:_set_easy()
	self.difficulty_curve_points = { 0.35 }
	self.besiege.assault.sustain_duration_min = { 30, 70, 140 }
	self.besiege.assault.sustain_duration_max = { 40, 120, 200 }
	self.besiege.assault.delay = { 80, 50, 40 }
	self.besiege.assault.units = {
		fbi = {1, 1, 1},
	}
	
	local is_singleplayer = Global.game_settings.single_player
	self.besiege.assault.force = is_singleplayer and { 10, 10, 15 } or { 10, 15, 20 }
	self.street.assault.force.aggressive = is_singleplayer and { 10, 13, 15 } or { 10, 15, 20 }
	self.street.assault.build_duration = 35
	self.street.assault.sustain_duration_min = { 30, 50, 70 }
	self.street.assault.sustain_duration_max = { 40, 60, 80 }
	self.street.assault.delay = { 40, 35, 30 }
	self.street.assault.units = {
		fbi = {1, 1, 1},
	}
	self.street.blockade.units = {
		defend = {
			fbi = {1, 1, 1},
		},
		frontal = {
			fbi = {1, 1, 1},
		},
		flank = {
			fbi = {1, 1, 1},
		},
	}
end

function GroupAITweakData:_set_normal()
	self.difficulty_curve_points = { 0.25 }
	self.max_nr_simultaneous_boss_types = 4
	self.besiege.assault.sustain_duration_min = { 100, 120, 200 }
	self.besiege.assault.sustain_duration_max = { 150, 180, 300 }
	self.besiege.assault.delay = { 40, 35, 30 }
	self.besiege.assault.units = {
	    fbi = {1, 1, 1},
	}
	
	local is_singleplayer = Global.game_settings.single_player
	self.besiege.assault.force = is_singleplayer and { 10, 10, 15 } or { 10, 15, 20 }
	self.street.assault.force.aggressive = is_singleplayer and { 10, 13, 15 } or { 15, 20, 23 }
	self.street.assault.build_duration = 35
	self.street.assault.sustain_duration_min = { 40, 60, 80 }
	self.street.assault.sustain_duration_max = { 50, 80, 100 }
	self.street.assault.delay = { 40, 35, 30 }
	self.street.assault.units = {
		fbi = {1, 1, 1},
	}
	self.street.blockade.units = {
		defend = {
			fbi = {1, 1, 1},
		},
		frontal = {
			fbi = {1, 1, 1},
		},
		flank = {
			fbi = {1, 1, 1},
		},
	}
end

function GroupAITweakData:_set_hard()
	self.difficulty_curve_points = { 0.2 }
	self.max_nr_simultaneous_boss_types = 4
	self.besiege.assault.sustain_duration_min = { 150, 180, 250 }
	self.besiege.assault.sustain_duration_max = { 200, 220, 360 }
	self.besiege.assault.delay = { 40, 35, 30 }
	self.besiege.assault.units = {
	    fbi = {1, 1, 1},
	}
	
	local is_singleplayer = Global.game_settings.single_player
	self.besiege.assault.force = is_singleplayer and { 15, 20, 25 } or { 15, 20, 25 }
	self.street.assault.force.aggressive = is_singleplayer and { 15, 20, 25 } or { 15, 20, 25 }
	self.street.assault.build_duration = 35
	self.street.assault.sustain_duration_min = { 50, 70, 90 }
	self.street.assault.sustain_duration_max = { 60, 90, 120 }
	self.street.assault.delay = { 40, 35, 30 }
	self.street.assault.units = {
		fbi = {1, 1, 1},
	}
	self.street.blockade.units = {
		defend = {
			fbi = {1, 1, 1},
		},
		frontal = {
			fbi = {1, 1, 1},
			spooc = { 0.1, 0.3, 0.4 },
		},
		flank = {
			spooc = { 1, 1, 1 },
			fbi = {1, 1, 1},
		},
	}
end

function GroupAITweakData:_set_overkill()
	self.difficulty_curve_points = { 0.2 }
	self.max_nr_simultaneous_boss_types = 4
	self.besiege.assault.build_duration = 30
	self.besiege.assault.sustain_duration_min = { 200, 280, 360 }
	self.besiege.assault.sustain_duration_max = { 200, 360, 400 }
	self.besiege.assault.delay = { 40, 35, 30 }
	self.besiege.assault.units = {
	    fbi = {1, 1, 1},
		spooc = { 0.2, 0.7, 1 },
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
		fbi = {1, 1, 1},
		spooc = { 0.2, 0.7, 1 },
	}
	self.street.blockade.units = {
		defend = {
			fbi = {1, 1, 1},
		},
		frontal = {
			fbi = {1, 1, 1},
			spooc = { 0.1, 0.3, 0.4 },
		},
		flank = {
			spooc = { 1, 1, 1 },
			fbi = { 1, 1, 1 },
		},
	}
end

function GroupAITweakData:_set_overkill_145()
	self.difficulty_curve_points = { 0.1 }
	self.max_nr_simultaneous_boss_types = 4
	self.besiege.assault.build_duration = 30
	self.besiege.assault.sustain_duration_min = { 200, 360, 400 }
	self.besiege.assault.sustain_duration_max = { 200, 360, 400 }
	self.besiege.assault.delay = { 40, 35, 30 }
	self.besiege.assault.units = {
	    fbi = {1, 1, 1},
		spooc = { 0.3, 0.9, 1 },
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
		spooc = { 0.2, 0.7, 1 },
		fbi = {1, 1, 1},
	}
	self.street.blockade.units = {
		defend = {
			fbi = {1, 1, 1},
		},
		frontal = {
			fbi = {1, 1, 1},
			spooc = { 0.1, 0.3, 0.4 },
		},
		flank = {
			spooc = { 1, 1, 1 },
			fbi = { 1, 1, 1 },
		},
	}
end

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
	
	local access_type_all = {"walk", "acrobatic"}
	table.merge(self.unit_categories, {
		fbi = {
			units = {
				Idstring("units/characters/enemies/fbi1/fbi1"),
				Idstring("units/characters/enemies/fbi2/fbi2"),
				Idstring("units/characters/enemies/fbi3/fbi3")
			},
			access = access_type_all
		},
		murky = {
			units = {
				Idstring("units/characters/enemies/murky_water1/murky_water1"),
				Idstring("units/characters/enemies/murky_water2/murky_water2")
			},
			access = access_type_all
		},
	})
end, false)