local closed = true

local barriers = {}

minetest.register_on_mods_loaded(function()
	local map = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.map_dirnames.ant_war]

	barriers = {
		map.offset:offset(80, 13, 82),
		map.offset:offset(80, 14, 82),
		map.offset:offset(81, 13, 81),
		map.offset:offset(81, 14, 81),
		map.offset:offset(81, 15, 81),
		map.offset:offset(82, 13, 80),
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
end)

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

ctf_api.register_on_flag_take(function()
	if ctf_map.current_map.dirname == "ant_war" and closed and math.random(5) == 1 then
		closed = false
		minetest.after(math.random(6, 10), function()
			set_barriers("default:obsidian")
			minetest.chat_send_all(minetest.colorize("#f49200", "The central passages have been weakened!"))
		end)
	end
end)
