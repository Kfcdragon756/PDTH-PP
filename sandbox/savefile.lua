local module = ... or D:module("PDTH++")
local SavefileManager = module:hook_class("SavefileManager")

if Global._current_save_slot then
	SavefileManager.PROGRESS_SLOT = Global._current_save_slot
	return
end

local KWR_save = 21

do
	local path = Application:windows_user_folder() .. "\\saves\\" .. Steam:userid()
	local save_file = function(id)
		return string.format("%s\\save%03d.sav", path, id)
	end

	if not osx.file_exists(save_file(KWR_save)) then
		osx.copy_file(save_file(99), save_file(KWR_save))
	end
end

-- apply our current selected save slot
SavefileManager.PROGRESS_SLOT = KWR_save
Global._current_save_slot = SavefileManager.PROGRESS_SLOT
--code by _atom