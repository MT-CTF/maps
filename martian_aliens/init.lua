local hud = mhud.init()
local clock = 0
local shortclock = 0
local move = {red = -1, blue = -1}
local data = {}
local nodes = {}
local flagposreset = false

minetest.register_node("ctf_map:ufo_beam", {
	description = "UFO Beam",
    drawtype = "glasslike",
	tiles = {"default_glass.png".."^[colorize:#FF0:255"},
	inventory_image = minetest.inventorycube("yellow.png"),
	paramtype = "light",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	buildable_to = false,
	pointable = ctf_core.settings.server_mode == "mapedit",
	groups = {immortal = 1},
    light_source = default.LIGHT_MAX,
	sounds = default.node_sound_glass_defaults()
})

minetest.register_tool("ctf_map:jetpack", {
    description = "Jetpack\nUse to fly in the air!",
    inventory_image = "ctf_mode_nade_fight_knockback_grenade.png",
    on_use = function(itemstack, user, pointed_thing)
        local max = 11
        if itemstack:get_wear() > math.floor(65535 - (65535/(max-1))) then return end
        local upward_velocity
        local maxvel
        if ctf_modebase.taken_flags[user:get_player_name()] then
			upward_velocity = {x = 0, y = 5, z = 0}
            maxvel = 10
		else
			upward_velocity = {x = 0, y = 10, z = 0}
            maxvel = 20
		end
        local playervel = user:get_velocity()
        if upward_velocity.y+playervel.y > maxvel then else
            user:add_velocity(upward_velocity)
        end

		itemstack:add_wear(65535 / (max - 1))
        ctf_modebase.update_wear.start_update(
				user:get_player_name(),
				"ctf_map:jetpack",
				65535/(max - 2),
				true
			)
        return itemstack
    end
})

local function start()
    if #data < 1 then
        local mapmeta = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map]
        local flagpos = {x = mapmeta.teams["red"].flag_pos.x, y = mapmeta.teams["red"].flag_pos.y, z = mapmeta.teams["red"].flag_pos.z}
        local cornerpos1 = {x = flagpos.x-21, y = flagpos.y-7, z = flagpos.z-21}
        local cornerpos2 = {x = flagpos.x+21, y = flagpos.y+7, z = flagpos.z+21}
        for z = cornerpos1.z, cornerpos2.z do
            for y = cornerpos1.y, cornerpos2.y do
                for x = cornerpos1.x, cornerpos2.x do
                    local nodename = minetest.get_node({x=x,y=y,z=z}).name
                    if (nodename ~= "air" and nodename ~= "default:desert_sand") or (math.sqrt(math.pow((x-flagpos.x),2)+math.pow((y-flagpos.y),2)+math.pow((z-flagpos.z),2)) < 8 and y > flagpos.y -1) then
                        local xtranslate, ytranslate, ztranslate = x-flagpos.x, y-flagpos.y, z-flagpos.z
                        table.insert(data, {x = xtranslate, y = ytranslate, z = ztranslate})
                    end
                end
            end
        end
    end
end

local function createbeam(flag_team)
    local mapmeta = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map]
    local flagpos = {x = mapmeta.teams[flag_team].flag_pos.x, y = mapmeta.teams[flag_team].flag_pos.y, z = mapmeta.teams[flag_team].flag_pos.z}
    for y = flagpos.y-23, flagpos.y-6 do
        minetest.set_node({x=flagpos.x,y=y,z=flagpos.z}, {name = "ctf_map:ufo_beam"})
    end
end

local function activatebeam(flag_team)
    local mapmeta = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map]
    local flagpos = {x = mapmeta.teams[flag_team].flag_pos.x, y = mapmeta.teams[flag_team].flag_pos.y, z = mapmeta.teams[flag_team].flag_pos.z}
    for _, player in ipairs(minetest.get_connected_players()) do
        local pos = player:get_pos()
        if math.abs(flagpos.x-pos.x) < .5 and math.abs(flagpos.z-pos.z) < .5 and pos.y > flagpos.y-24 and pos.y < flagpos.y - 6 then
            local playervel = player:get_velocity()
            local upward_velocity = {x = 0, y = 5-playervel.y, z = 0}
            player:add_velocity(upward_velocity)
            if pos.y > 2.7 then
                player:set_pos({x = pos.x, y = flagpos.y-5, z = pos.z})
            end
        end
    end
end

local function moveplayers(flag_team)
    local mapmeta = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map]
    local players = {}
    for _, player in pairs(minetest.get_connected_players()) do
        table.insert(players, player:get_player_name())
    end
    local flagpos = mapmeta.teams[flag_team].flag_pos
    for i,name in ipairs(players) do
        local playerob = minetest.get_player_by_name(name)
        local playerpos = playerob:get_pos()
        playerpos = {x = playerpos.x, y = playerpos.y, z = playerpos.z}
        local closesty = nil
        for i, d in ipairs(data) do
            local x=d.x+flagpos.x
            local y=d.y+flagpos.y
            local z=d.z+flagpos.z
            if flag_team == "blue" then z = (-1 * d.z)+flagpos.z end
            if minetest.get_node({x=x,y=y,z=z}).name ~= "air" and math.floor(playerpos.x + 0.5) == x
                and math.floor(playerpos.z + 0.5) == z and math.floor(playerpos.y - 0.5) > y and (minetest.get_node({x=x,y=math.floor(playerpos.y+0.5),z=z}).name ~= "air" or minetest.get_node({x=x,y=math.floor(playerpos.y - 0.5),z=z}).name ~= "air") then
                if closesty == nil then
                    closesty = y-playerpos.y
                elseif math.abs(closesty) < math.abs(y-playerpos.y) then
                     closesty = y-playerpos.y
                end
            end
        end
        if closesty then
            --minetest.chat_send_all(tostring(closesty))
            local playervel = playerob:get_velocity()
            local upward_velocity = {x = 0, y = 10-playervel.y, z = 0}
            playerob:add_velocity(upward_velocity)
        end
    end
end

local function moveship(flag_team) -- works
    local blockdata = {}
    local mapmeta = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map]
    local flagpos =  {x = mapmeta.teams[flag_team].flag_pos.x, y = mapmeta.teams[flag_team].flag_pos.y, z = mapmeta.teams[flag_team].flag_pos.z}
    mapmeta.teams[flag_team].flag_pos = {x = mapmeta.teams[flag_team].flag_pos.x, y = mapmeta.teams[flag_team].flag_pos.y + 1, z = mapmeta.teams[flag_team].flag_pos.z}
    for __, d in ipairs(data) do
        local x=d.x+flagpos.x
        local y=d.y+flagpos.y
        local z=d.z+flagpos.z
        local nodename = minetest.get_node({x=x,y=y,z=z}).name
        local meta = minetest.get_meta({x=x,y=y,z=z})
        local inv = meta:to_table()
        if nodename:find("ctf_modebase:flag_top_") then nodename = "ctf_modebase:flag_captured_top" end
        table.insert(blockdata,{name = nodename, param2 = minetest.get_node({x=x,y=y,z=z}).param2, inv = inv})
        minetest.set_node({x=x, y=y, z=z}, {name="air"})
    end
    for i, d in ipairs(data) do
        local x=d.x+flagpos.x
        local y=d.y+flagpos.y
        local z=d.z+flagpos.z
        if minetest.get_node({x=x,y=y+1,z=z}).name ~= "air" and minetest.get_node({x=x,y=y,z=z}).name ~= "ctf_map:ind_glass" then
            local indata = false
            for __, nd in ipairs(data) do
                if indata == false and x == nd.x+flagpos.x and y == nd.y+flagpos.y - 1 and z == nd.z+flagpos.z then
                    indata = true
                end
            end
            if indata == false then
                local firstairy
                nodes = {}
                for i = y+1, y+21 do
                    if minetest.get_node({x=x,y=i,z=z}).name == "air" then
                        if firstairy == nil then
                            firsrtairy = i-1
                        end
                    else
                        table.insert(nodes,{pos = {x = x, y = i, z = z}, name = minetest.get_node({x=x,y=i,z=z}).name, param2 = minetest.get_node({x=x,y=i,z=z}).param2})
                        minetest.set_node({x=x,y=i,z=z}, {name = "air"})
                    end
                end
                for i = 1, #nodes do  
                    minetest.set_node({x=x,y=i+y+1,z=z}, {name = nodes[i].name, param2 = nodes[i].param2})
                end
            end
        end
        local nodename = blockdata[i].name
        if nodename == ("default:glass") then nodename = "default:meselamp" end
        minetest.set_node({x=x, y=y + 1, z=z}, {name=nodename, param2 = blockdata[i].param2})
        local meta = minetest.get_meta({x=x, y=y + 1, z=z})
        meta:from_table(blockdata[i].inv)
    end
end

local function updatehud(teammeta,teamname)
    for _, player in pairs(minetest.get_connected_players()) do
        local hud_label = "flag_pos:" .. teamname
        ctf_modebase.flag_huds.update_player(player)
    end
end

local function on_globalstep(dtime)
    mapmeta = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map]
    if mapmeta and mapmeta.name == "Martian Aliens" then
        if dtime == nil then dtime = 0 end
        clock = clock + dtime
        shortclock = shortclock + dtime
        if clock > 1 or clock == .5 then
            clock = clock - .5
            if move.red ~= -1 and move.red < 18 then
                moveplayers("red")
                moveship("red")
                move.red = move.red + 1
            end
            if move.red == 17 then
                updatehud(ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map].teams["red"],"red")
                createbeam("red")
                move.red = 18
            end
            if move.blue ~= -1 and move.blue < 18 then
                moveplayers("blue")
                moveship("blue")
                move.blue = move.blue + 1
            end
            if move.blue == 17 then
                updatehud(ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map].teams["blue"],"blue")
                createbeam("blue")
                move.blue = 18
            end
        end
        if shortclock > 0.1 or shortclock == 0.1 then
            if move.blue == 18 then
                activatebeam("blue")
            end
            if move.red == 18 then
                activatebeam("red")
            end
        end
    end
end

local function on_match()
    move = {red = -1, blue = -1}
    nodes = {}
    start()
end

local function on_take(taker, flag_team)
    flagposreset = false
    if flag_team == "red" and move.red == -1 then
        move.red = 0
    end
    if flag_team == "blue" and move.blue == -1 then
        move.blue = 0
    end
end

local function on_end()
    local mapmeta = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map]
    if mapmeta then
        local mapname = mapmeta.name
        local offset = mapmeta.offset
        if tostring(mapname) == "Martian Aliens" and flagposreset == false then
            mapmeta.teams["red"].flag_pos = {x=51+offset.x,y=22+offset.y,z=147+offset.z}
            mapmeta.teams["blue"].flag_pos = {x=51+offset.x,y=22+offset.y,z=23+offset.z}
            flagposreset = true
        end
    end
    for i, f in pairs(ctf_api.registered_on_flag_take) do
        if f == on_take then
            ctf_api.registered_on_flag_take[i] = nil
            break
        end
    end
    for i, f in pairs(ctf_api.registered_on_match_end) do
        if f == on_end then
            ctf_api.registered_on_match_end[i] = nil
            break
        end
    end
end

minetest.register_globalstep(on_globalstep, dtime)

ctf_api.register_on_new_match(function()
    local mapmeta = ctf_modebase.map_catalog.maps[ctf_modebase.map_catalog.current_map]
    if tostring(mapmeta.name) == "Martian Aliens" then
        on_match()

        ctf_api.register_on_flag_take(on_take, taker, flag_team)

        ctf_api.register_on_match_end(on_end)
    end
end)
