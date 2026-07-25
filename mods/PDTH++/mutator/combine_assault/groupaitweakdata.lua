local module = ... or D:module("PDTH++")
local GroupAITweakData = module:hook_class("GroupAITweakData")

module:post_hook(GroupAITweakData, "_set_overkill", function(self)
	self.besiege.assault.units.swat = { 0.25, 0.35, 0.5 }
	self.besiege.assault.units.swat_kevlar = { 0.25, 0.5, 0.6 }
	self.besiege.assault.units.fbi = { 0.5, 0.6, 0.6 }
	self.besiege.assault.units.murky = { 0.3, 0.7, 0.9 }

	self.street.assault.units.swat = { 0.5, 0.4, 0.4 }
	self.street.assault.units.swat_kevlar = { 0.4, 0.5, 0.5 }
	self.street.assault.units.murky = { 0.7, 0.7, 0.7 }

	self.street.blockade.units.frontal.swat = { 0.05, 0.05, 0.1 }	
	self.street.blockade.units.frontal.swat_kevlar = { 0.1, 0.1, 0.2 }
	self.street.blockade.units.frontal.murky = { 0.2, 0.6, 0.8 }
	self.street.blockade.units.flank.murky = { 1, 1, 1 }
end, false)

module:post_hook(GroupAITweakData, "_set_overkill_145", function(self)
	self.besiege.assault.units.swat = { 0.4, 0.4, 0.3 }
	self.besiege.assault.units.swat_kevlar = { 0.3, 0.6, 0.9 }
	self.besiege.assault.units.fbi = { 0.5, 0.6, 0.8 }
	self.besiege.assault.units.murky = { 0.4, 1, 1 }

	self.street.assault.units.swat = { 0.5, 0.5, 0.5 }
	self.street.assault.units.swat_kevlar = { 0.5, 0.5, 0.5 }
	self.street.assault.units.murky = { 1, 1, 1 }
	self.street.blockade.units.defend.murky = { 1, 1, 1 }
	self.street.blockade.units.defend.swat = { 0.05, 0.05, 0.1 }
	self.street.blockade.units.defend.swat_kevlar = { 0.4, 0.5, 0.5 }
	self.street.blockade.units.frontal.swat = { 0.2, 0.2, 0.4 }	
	self.street.blockade.units.frontal.swat_kevlar = { 0.1, 0.1, 0.1 }
	self.street.blockade.units.frontal.murky = { 0.4, 1, 1 }
	self.street.blockade.units.flank.murky = { 1, 1, 1 }
end, false)