local module = ... or D:module("PDTH++")
local GroupAITweakData = module:hook_class("GroupAITweakData")

module:post_hook(GroupAITweakData, "_set_easy", function(self)
	self.besiege.assault.units = {
		fbi = {1, 1, 1},
	}
	
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
end, false)

module:post_hook(GroupAITweakData, "_set_normal", function(self)
	self.besiege.assault.units = {
	    fbi = {1, 1, 1},
	}
	
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
end, false)

module:post_hook(GroupAITweakData, "_set_hard", function(self)
	self.besiege.assault.units = {
	    fbi = {1, 1, 1},
	}
	
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
end, false)

module:post_hook(GroupAITweakData, "_set_overkill", function(self)
	self.besiege.assault.units = {
	    fbi = {1, 1, 1},
		spooc = { 0.2, 0.7, 1 },
	}

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
end, false)

module:post_hook(GroupAITweakData, "_set_overkill_145", function(self)
	self.besiege.assault.units = {
	    fbi = {1, 1, 1},
		spooc = { 0.3, 0.9, 1 },
	}

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
end, false)