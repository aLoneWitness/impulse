-- LDoc configuration and style forked from https://github.com/NebulousCloud/helix (check them out for a serious framework)

file = {
	"gamemode",
	"plugins",
	"docs/hooks",
	exclude = {"gamemode/core/libs"}
}

dir = "docs/html"
project = "impulse"
title = "impulse documentation"
description = "impulse framework documentation"

no_space_before_args = true
style = "c:/program files (x86)/steam/steamapps/common/garrysmod/garrysmod/gamemodes/impulse/docs/css"
template = "c:/program files (x86)/steam/steamapps/common/garrysmod/garrysmod/gamemodes/impulse/docs/templates"
format = "markdown"
ignore = true
topics = "c:/program files (x86)/steam/steamapps/common/garrysmod/garrysmod/gamemodes/impulse/docs/manual"
use_markdown_titles = true
kind_names = {module = "Libraries", topic = "Manual"}
merge = true
sort = true
wrap = true
custom_tags = {
	{"realm", hidden = true},
	{"internal", hidden = true}
}

custom_display_name_handler = function(item, default_handler)
	if (item.type == "function" and item.module) then
		if (item.module.type == "classmod" or item.module.type == "panel") then
			return item.module.mod_name .. default_handler(item):gsub(".+:", ":")
		elseif (item.module.type == "hooks") then
			return item.module.mod_name:upper() .. ":" .. default_handler(item)
		end
	end

	return default_handler(item)
end

new_type("hooks", "Hooks", true)
new_type("panel", "Panels", true)

tparam_alias("string", "string")
tparam_alias("bool", "boolean")
tparam_alias("func", "function")
tparam_alias("player", "player")
tparam_alias("entity", "entity")
tparam_alias("color", "color")
tparam_alias("tab", "table")
tparam_alias("material", "material")
tparam_alias("vector", "vector")
tparam_alias("angle", "angle")
tparam_alias("panel", "panel")