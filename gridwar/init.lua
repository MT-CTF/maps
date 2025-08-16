local MAP_NAME = "GridWar"
local DEATH_BARRIER_Y_OFFSET = 12
local RESPAWN_Y_OFFSET = 2
local AIR_LIGHT_LEVEL = 3
local MESSAGE_INTERVAL = 600


local gridwar_messages = {
    "You can never reach the ground",
    "Headache?",
    "I feel I am in heaven",
    "Don't confuse direction",
    "Am I in heaven?",
    "The void calls to you",
    "Reality bends around you",
    "Which way is up?",
    "Gravity is just a suggestion",
    "Lost in the grid...",
    "The platform knows your thoughts",
    "Time moves differently here",
    "Are you still falling?",
    "The lights whisper secrets",
    "Nothing is as it seems",
    "Welcome to the endless maze",
    "The grid remembers everything",
    "Footsteps echo in eternity",
    "Your shadow has left you",
    "The air tastes of electricity",
    "Distance is an illusion",
    "Something watches from below",
    "The patterns repeat forever",
    "Can you trust your eyes?",
    "The platform shifts when you sleep",
    "Echoes of forgotten battles",
    "The void has infinite patience",
    "Your reflection lies to you",
    "The grid dreams of escape",
    "Falling upward is still falling",
    "The silence is deafening",
    "I don't feel gravity",
    "In a dream",
    "I feel light"
}

local message_timer = nil

local function send_atmospheric_message()
    if not ctf_map.current_map or ctf_map.current_map.name ~= MAP_NAME then
        return
    end

    local message = gridwar_messages[math.random(#gridwar_messages)]

    minetest.chat_send_all(minetest.colorize("#FFAA00", "◊ " .. message .. " ◊"))
end

minetest.register_node("ctf_map:glowing_air", {
    description = "Glowing Air",
    drawtype = "airlike",
    paramtype = "light",
    light_source = AIR_LIGHT_LEVEL,
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    air_equivalent = true,
    drop = "",
    groups = {not_in_creative_inventory = 1}
})


local world_bound_pos1, world_bound_pos2 = nil, nil
ctf_api.register_on_new_match(function ()
    if ctf_map.current_map and ctf_map.current_map.name == MAP_NAME then
        minetest.after(0, function ()
            world_bound_pos1 = ctf_map.current_map.pos1
            world_bound_pos2 = ctf_map.current_map.pos2
        end)

        local function schedule_next_message()
            if ctf_map.current_map and ctf_map.current_map.name == MAP_NAME then
                send_atmospheric_message()
                message_timer = minetest.after(MESSAGE_INTERVAL, schedule_next_message)
            end
        end
        message_timer = minetest.after(120, schedule_next_message)
    end
end)

ctf_api.register_on_match_end(function ()
    if ctf_map.current_map and ctf_map.current_map.name == MAP_NAME then
        world_bound_pos1 = nil
        world_bound_pos2 = nil

        if message_timer then
            message_timer:cancel()
            message_timer = nil
        end
    end
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if reason and reason.type == "fall" then
        if ctf_map.current_map and ctf_map.current_map.name == MAP_NAME then
            return 0
        end
    end
    return hp_change
end, true)

-- teleport barriers

local function is_below_death_barrier(player)
    if not world_bound_pos1 then return false end
    return player:get_pos().y < world_bound_pos1.y + DEATH_BARRIER_Y_OFFSET
end

local function respawn_player_at_top(player)
    if not world_bound_pos2 then return end
    local pos = player:get_pos()
    local new_pos = {x = pos.x, y = world_bound_pos2.y - RESPAWN_Y_OFFSET, z = pos.z}
    player:set_pos(new_pos)
end

minetest.register_globalstep(function ()
    if ctf_map.current_map and ctf_map.current_map.name ~= MAP_NAME then
        return
    end
    for _, player in ipairs(minetest:get_connected_players()) do
        if is_below_death_barrier(player) then
            respawn_player_at_top(player)
        end
    end
end)
