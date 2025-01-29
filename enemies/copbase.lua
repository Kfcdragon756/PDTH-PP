local overrides = {
	spooc = { "mp5", "m4" },
	gangster = { "glock", "mac11" },
	dealer = { "bronco" },
	murky = { "m4", "ak47", "mp5", "r870" },
	fbi = { "mp5", "c45", "mossberg", "beretta92" },
	security = {
		slaughter_house = { "bronco", "m4", "mp5", "r870" },
		default = { "bronco", "c45", "beretta92" }, -- bank, no mercy
	},
	patrol = { diamond_heist = { "m4", "mp5" }, default = { "mp5" } },
	tank = { "r870", "hk21", "mossberg" },
	cop = { "c45", "m4", "r870", "beretta92", "mossberg", "bronco" },
}

local current_level
local function get_weapon(data)
	current_level = current_level or Global.level_data.level_id

	local result
	if type(data) == "table" then
		if data[current_level] then
			data = get_weapon(data[current_level])
		elseif data.default then
			data = get_weapon(data.default)
		end

		result = data[math.random(1, #data)]
	end

	if type(data) == "string" then
		result = data
	end

	return result
end

-- credits: Dorentuz` for the template
local CopBase = module:hook_class("CopBase")
module:pre_hook(60, CopBase, "init", function(self, unit)
	if Network:is_client() then
		return
	end

	local data = overrides[unit:base()._tweak_table]
	if type(data) == "nil" then
		return
	end

	self._default_weapon_id_override = get_weapon(data)
end, false)

module:pre_hook(60, CopBase, "post_init", function(self)
	if type(self._default_weapon_id_override) == "string" then
		self._default_weapon_id = self._default_weapon_id_override
	end
end, false)
