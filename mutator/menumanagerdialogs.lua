local module = ... or D:module("PDTH++")
local MenuManager = module:hook_class("MenuManager")

function MenuManager:show_mutaotor_conflictions()
	local dialog_data = {}
	dialog_data.title = managers.localization:text("dialog_error_title")
	dialog_data.text = managers.localization:text("dialog_mutator_conflictions")
	local ok_button = {}
	ok_button.text = managers.localization:text("dialog_ok")
	dialog_data.button_list = {ok_button}
	managers.system_menu:show(dialog_data)
end