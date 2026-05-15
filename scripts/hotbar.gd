extends Control

@onready var hbox = $HBoxContainer 

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
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.inventory_changed.connect(update_slots)

func update_slots(items: Dictionary) -> void:
	if not hbox: return
	var player = get_tree().get_first_node_in_group("player")
	var selected = player.selected_slot if player else 0
	
	var slots = hbox.get_children() 
	var item_names = items.keys()

	for i in range(slots.size()):
		var slot = slots[i]
		if i < item_names.size():
			var i_name = item_names[i]
			var i_count = items[i_name]
			var i_tex = icon_map.get(i_name)
			if slot.has_method("set_slot_data"):
				slot.set_slot_data(i_name, i_count, i_tex)
		else:
			if slot.has_method("set_slot_data"):
				slot.set_slot_data("", 0, null)
		
		if slot.has_method("set_selected"):
			slot.set_selected(i == selected)
		else:
			slot.modulate = Color(1, 1, 0) if i == selected else Color(1, 1, 1)
