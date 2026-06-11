local module = ... or D:module("PDTH++")
local GroupAITweakData = module:hook_class("GroupAITweakData")

local function _remove_blockade_murkies(self)
	-- Aggressive safety: street blockade uses very map-specific defend/frontal/flank points.
	-- Murkies tend to expose bad/unsupported pathing there on some maps, so keep them
	-- in regular assault pools but do not let them become blockade specialists.
	if self.street and self.street.blockade and self.street.blockade.units then
		local blockade = self.street.blockade.units
		if blockade.defend then
			blockade.defend.murky = nil
			blockade.defend.fbi = blockade.defend.fbi or { 0.35, 0.5, 0.65 }
		end
		if blockade.frontal then
			blockade.frontal.murky = nil
			blockade.frontal.fbi = blockade.frontal.fbi or { 0.35, 0.6, 0.8 }
		end
		if blockade.flank then
			blockade.flank.murky = nil
			blockade.flank.fbi = blockade.flank.fbi or { 1, 1, 1 }
		end
	end
end

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

	_remove_blockade_murkies(self)
end, false)

module:post_hook(GroupAITweakData, "_set_overkill_145", function(self)
	self.besiege.assault.units.swat = { 0.4, 0.4, 0.3 }
	self.besiege.assault.units.swat_kevlar = { 0.3, 0.6, 0.9 }
	self.besiege.assault.units.fbi = { 0.5, 0.6, 0.8 }
	self.besiege.assault.units.murky = { 0.4, 1, 1 }

	self.street.assault.units.swat = { 0.5, 0.5, 0.5 }
	self.street.assault.units.swat_kevlar = { 0.5, 0.5, 0.5 }
	self.street.assault.units.murky = { 1, 1, 1 }
	self.street.blockade.units.defend.swat = { 0.05, 0.05, 0.1 }
	self.street.blockade.units.defend.swat_kevlar = { 0.4, 0.5, 0.5 }
	self.street.blockade.units.frontal.swat = { 0.2, 0.2, 0.4 }
	self.street.blockade.units.frontal.swat_kevlar = { 0.1, 0.1, 0.1 }

	_remove_blockade_murkies(self)
end, false)
