extends Control

# Make sure this points to the GridContainer holding your slots
@onready var grid = $NinePatchRect/GridContainer

var icon_map = {
	"Raw Meat": preload("res://sprites/materials/Meat/Meat Resource/Meat Resource.png"),
	"Wood": preload("res://sprites/materials/Wood Resource.png"),
	"BigSword": preload("res://sprites/materials/Items/Weapons/BigSword/Sprite.png"),
	"Lance": preload("res://sprites/materials/Items/Weapons/Lance/Sprite.png"),
	"Stick": preload("res://sprites/materials/Items/Weapons/Stick/Sprite.png"),
	"AxeTool": preload("res://sprites/materials/Items/Weapons/AxeTool/Sprite.png"),
	"Bow": preload("res://sprites/materials/Items/Weapons/Bow/Sprite.png"),
	"MagicWand": preload("res://sprites/materials/Items/Weapons/MagicWand/Sprite.png"),
}

func _ready() -> void:
	# Wait for everything to be ready
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.inventory_changed.connect(update_slots)
		# Manually trigger first update with current inventory
		update_slots(player.inventory)
	else:
		print("ERROR: Player not found in inventory!")

func update_slots(items: Dictionary) -> void:
	if not grid: return
	
	var slots = grid.get_children() 
	var item_names = items.keys()

	for i in range(slots.size()):
		var slot = slots[i]
		
		# If we have an item for this slot index
		if i < item_names.size():
			var i_name = item_names[i]
			var i_count = items[i_name]
			var i_tex = icon_map.get(i_name)
			
			if slot.has_method("set_slot_data"):
				slot.set_slot_data(i_name, i_count, i_tex)
		else:
			# If no item, tell the slot to be empty
			if slot.has_method("set_slot_data"):
				slot.set_slot_data("", 0, null)
