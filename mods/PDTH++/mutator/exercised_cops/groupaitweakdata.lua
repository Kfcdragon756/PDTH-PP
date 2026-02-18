local module = ... or D:module("PDTH++")
local GroupAITweakData = module:hook_class("GroupAITweakData")


module:post_hook(GroupAITweakData, "_set_overkill", function(self)
	self.besiege.assault.units.swat = { 0.7, 0.5, 0.5 }
	self.besiege.assault.units.swat_kevlar = { 0.4, 0.7, 0.7 }

	self.street.assault.units.swat = { 0.5, 0.7, 0.7 }
	self.street.assault.units.swat_kevlar = { 0.4, 0.5, 0.6 }
	self.street.blockade.units.defend.swat = { 1, 0.6, 0.6 }
	self.street.blockade.units.defend.swat_kevlar = { 0.7, 0.8, 0.9 }
	self.street.blockade.units.frontal.swat = { 1, 0.5, 0.5 }	
	self.street.blockade.units.frontal.swat_kevlar = { 0.3, 0.4, 0.4 }
end, false)

module:post_hook(GroupAITweakData, "_set_overkill_145", function(self)
	self.besiege.assault.units.swat = { 1, 0.5, 0.4 }
	self.besiege.assault.units.swat_kevlar = { 0.4, 0.7, 0.9 }

	self.street.assault.units.swat = { 0.5, 0.4, 0.45 }
	self.street.assault.units.swat_kevlar = { 0.5, 0.6, 0.7 }
	self.street.blockade.units.defend.swat = { 0.5, 0.5, 0.5 }
	self.street.blockade.units.defend.swat_kevlar = { 0.8, 0.8, 0.8 }
	self.street.blockade.units.frontal.swat = { 0.6, 0.5, 0.5 }	
	self.street.blockade.units.frontal.swat_kevlar = { 0.5, 0.5, 0.5 }
end, false)