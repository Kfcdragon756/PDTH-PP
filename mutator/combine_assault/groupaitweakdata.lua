local GroupAITweakData = module:hook_class("GroupAITweakData")

function GroupAITweakData:_set_overkill()
	self.difficulty_curve_points = { 0.1 }
	self.max_nr_simultaneous_boss_types = 4
	self.besiege.assault.build_duration = 30
	self.besiege.assault.sustain_duration_min = { 200, 280, 360 }
	self.besiege.assault.sustain_duration_max = { 200, 360, 400 }
	self.besiege.assault.delay = { 40, 35, 30 }
	self.besiege.assault.units = {
	    cop = { 0.5, 0.1, 0 },
		fbi = { 0.5, 0.6, 0.6 },
		swat = { 0.25, 0.35, 0.5 },
		swat_kevlar = { 0.25, 0.5, 0.6 },
		murky = { 0.3, 0.7, 0.9 },
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
		swat = { 0.5, 0.4, 0.4 },
		swat_kevlar = { 0.4, 0.5, 0.5 },
		murky = { 0.7, 0.7, 0.7 },
		shield = { 0.5, 0.7, 0.8 },
		spooc = { 0.2, 0.7, 1 },
		taser = { 0.05, 0.35, 0.45 },
	}
	self.street.blockade.units = {
		defend = {
			swat = { 1, 0.6, 0.6 },
			swat_kevlar = { 0.3, 0.4, 0.5 },
			shield = { 0.7, 0.7, 0.7 },
		},
		frontal = {
			swat_kevlar = { 0.1, 0.1, 0.2 },
			murky = { 1, 1, 1 },
			shield = { 0, 0.1, 0.5 },
			spooc = { 0.1, 0.3, 0.4 },
		},
		flank = {
			murky = { 1, 1, 1 },
			spooc = { 1, 1, 1 },
			taser = { 1, 1, 1 },
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
	    cop = { 0.3, 0, 0 },
		swat = { 0.4, 0.4, 0.3 },
		fbi = { 0.5, 0.6, 0.8 },
		swat_kevlar = { 0.3, 0.6, 0.9 },
		murky = { 0.4, 1, 1 },
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
		swat = { 0.5, 0.5, 0.5 },
		swat_kevlar = { 0.5, 0.5, 0.5 },
		murky = { 1, 1, 1 },
		shield = { 0.5, 0.7, 0.7 },
		tank = { 0, 0.1, 0.2 },
		spooc = { 0.2, 0.7, 1 },
		taser = { 0.4, 0.4, 0.5 },
	}
	self.street.blockade.units = {
		defend = {
			murky = { 1, 1, 1 },
			swat_kevlar = { 0.4, 0.5, 0.5 },
			shield = { 0.7, 0.9, 0.9 },
			tank = { 0, 0.1, 0.1 },
		},
		frontal = {
			swat = { 0.2, 0.2, 0.4 },
			swat_kevlar = { 0.1, 0.1, 0.1 },
			murky = { 0.4, 1, 1 },
			shield = { 0, 0.1, 0.5 },
			spooc = { 0.1, 0.3, 0.4 },
			fbi = { 0.6, 0.7, 0.8 },
		},
		flank = {
			murky = { 1, 1, 1 },
			spooc = { 1, 1, 1 },
			taser = { 1, 1, 1 },
			fbi = { 1, 1, 1 },
		},
	}
end