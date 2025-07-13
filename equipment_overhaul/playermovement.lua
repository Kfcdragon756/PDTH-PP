local module = ... or D:module("PDTH++")
local PlayerMovement = module:hook_class("PlayerMovement")

function PlayerMovement:current_state_name()
	return self._current_state_name
end
