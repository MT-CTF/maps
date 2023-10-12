local closed = true
local map = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.map_dirnames.ant_war]
local barriers = {
	map.offset:offset(80, 13, 82),
	map.offset:offset(80, 14, 82),
	map.offset:offset(81, 13, 81),
	map.offset:offset(81, 14, 81),
	map.offset:offset(81, 15, 81),
	map.offset:offset(82, 13, 80),
	map.offset:offset(82, 14, 80),

	map.offset:offset(80, 19, 80),
	map.offset:offset(80, 20, 80),
	map.offset:offset(81, 19, 81),
	map.offset:offset(81, 20, 81),
	map.offset:offset(81, 21, 81),
	map.offset:offset(82, 19, 82),
	map.offset:offset(82, 20, 82),
}

local function set_barriers(node)
	for _, i in pairs(barriers) do
		minetest.set_node(i, {name=node})
	end
end

ctf_api.register_on_new_match(function()
	if ctf_map.current_map.dirname == "ant_war" then
		closed = true
		set_barriers("ctf_map:obsidian")
	end
end)

ctf_api.register_on_flag_capture(function()
	if ctf_map.current_map.dirname == "ant_war" and closed then
		closed = false
		minetest.chat_send_all(minetest.colorize("#f49200", "The central barriers have weakened!"))
		set_barriers("default:obsidian")
	end
end)
