extends Node

# Materials player has
var inventory = {
	"copper": 0,
	"diamond": 0,
	"emerald": 0,
	"wood": 10
}

# The costs for the shop
var recipes = {
	"BigSword": {"wood": 1, "copper": 4},
	"magic wand": {"wood": 2, "emerald": 2, "diamond": 2},
	"stick": {"wood": 1},
	"walls": {"wood": 4}
}

func can_afford(item_name: String) -> bool:
	if not recipes.has(item_name): return false
	var cost = recipes[item_name]
	for mat in cost:
		if not inventory.has(mat) or inventory[mat] < cost[mat]:
			return false
	return true

func try_to_craft(item_name: String):
	if can_afford(item_name):
		var cost = recipes[item_name]
		for mat in cost:
			inventory[mat] -= cost[mat]
		print("Crafted: ", item_name)
		# Here you would trigger the player to actually receive the item
