minetest.register_node("ctf_map:desert_stone_with_iron", {
	description = ("Desert Iron Ore"),
	tiles = {"default_desert_cobble.png^default_mineral_iron.png"},
	groups = {cracky = 2},
	drop = "default:steel_ingot",
	--sounds = default.node_sound_stone_defaults(),
})