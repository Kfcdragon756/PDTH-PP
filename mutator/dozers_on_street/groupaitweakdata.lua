local module = ... or D:module("PDTH++")
local GroupAITweakData = module:hook_class("GroupAITweakData")

module:post_hook(GroupAITweakData, "_set_overkill", function(self)
	self.street.assault.units.tank = { 0, 0.1, 0.2 }
	self.street.blockade.units.defend.tank = { 0.1, 0.2, 0.2 }
end, false)

module:post_hook(GroupAITweakData, "_set_overkill_145", function(self)
	self.street.assault.units.tank = { 0, 0.1, 0.2 }
	self.street.blockade.units.defend.tank = { 0.1, 0.2, 0.2 }
end, false)