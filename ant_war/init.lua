ctf_api.register_on_new_match(function()
    local map = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map].name
    if map == "Ant War" then
		local closed = true
		local offset = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map].offset
		local barriers = {	{x=offset.x+82, y=offset.y+13, z=offset.z+80},
							{x=offset.x+81, y=offset.y+13, z=offset.z+81},
							{x=offset.x+80, y=offset.y+13, z=offset.z+82},
							{x=offset.x+82, y=offset.y+14, z=offset.z+80},
							{x=offset.x+81, y=offset.y+14, z=offset.z+81},
							{x=offset.x+80, y=offset.y+14, z=offset.z+82},
							{x=offset.x+81, y=offset.y+15, z=offset.z+81},

							{x=offset.x+80, y=offset.y+19, z=offset.z+80},
							{x=offset.x+81, y=offset.y+19, z=offset.z+81},
							{x=offset.x+82, y=offset.y+19, z=offset.z+82},
							{x=offset.x+80, y=offset.y+20, z=offset.z+80},
							{x=offset.x+81, y=offset.y+20, z=offset.z+81},
							{x=offset.x+82, y=offset.y+20, z=offset.z+82},
							{x=offset.x+81, y=offset.y+21, z=offset.z+81},
						}

		function set_barriers(node)
			for _, i in pairs(barriers) do
				minetest.set_node(i, {name=node})
			end
		end

        set_barriers("ctf_map:obsidian")

        local function remove_barriers()
			local map = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map].name
				if map == "Ant War" and closed and math.random(5) == 1 then
					minetest.after(math.random(6, 10), function()
						set_barriers("default:obsidian") minetest.chat_send_all(minetest.colorize("#f49200", "The central passages have been opened!"))
						closed = false
					end)
				end
		end

        local function cleanup()
			for i, f in pairs(ctf_api.registered_on_flag_take) do
				if f == remove_barriers then
					ctf_api.registered_on_flag_take[i] = nil
					break
				end
			end
			for i, f in pairs(ctf_api.registered_on_match_end) do
				if f == cleanup then
					ctf_api.registered_on_match_end[i] = nil
					break
				end
			end
		end

        ctf_api.register_on_flag_take(remove_barriers)
		ctf_api.register_on_match_end(cleanup)
    end
end)


