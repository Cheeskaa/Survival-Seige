extends Control

@onready var grid = $NinePatchRect/GridContainer

var icon_map = {
	"Raw Meat": preload("res://sprites/materials/Meat/Meat Resource/Meat Resource.png"),
	"Wood": preload("res://sprites/materials/Wood Resource.png")
}

func update_slots(items: Dictionary) -> void:
	if not grid: return
	
	var slots = grid.get_children() 
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
			# Clear empty slots
			if slot.has_method("set_slot_data"):
				slot.set_slot_data("", 0, null)
