local MAP_NAME = "GridWar"

local enabled = false


ctf_api.register_on_new_match(function ()
    if ctf_map.current_map and ctf_map.current_map.name == MAP_NAME then
        enabled = true
    end
end)

ctf_api.register_on_match_end(function ()
    if ctf_map.current_map and ctf_map.current_map.name == MAP_NAME then
        enabled = false
    end
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if reason and reason.type == "fall" then
        if enabled then
            return hp_change * 0.5
        end
    end
    return hp_change
end, true)