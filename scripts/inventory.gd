extends Control

@onready var grid = $NinePatchRect/GridContainer

var icon_map = {
	"Raw Meat": preload("res://sprites/materials/Meat/Meat Resource/Meat Resource.png"),
	"Wood": preload("res://sprites/materials/Wood Resource.png") # ADD THIS LINE
}

func update_slots(items: Dictionary) -> void:
	# KEY FIX: Get children from the GridContainer, not the root!
	var slots = grid.get_children() 
	var item_names = items.keys()

	for i in range(slots.size()):
		var slot = slots[i]
		
		# Clear old icons
		for child in slot.get_children():
			if child is TextureRect:
				child.queue_free()
		
		var label = slot.get_node_or_null("CountLabel")
		if label:
			label.text = ""

		# Draw item
		if i < item_names.size():
			var item_name = item_names[i]
			var count = items[item_name]
			_draw_item(slot, item_name, count)

func _draw_item(slot, item_name, amount):
	var icon = TextureRect.new()
	if icon_map.has(item_name):
		var tex_rect = TextureRect.new()
		tex_rect.texture = icon_map[item_name]
			
		# 1. Prevent the icon from being massive or tiny
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
		# 2. Set the size to be slightly smaller than the brown box 
		tex_rect.custom_minimum_size = Vector2(50, 50) 
			
		# 3. Add it to the slot FIRST
		slot.add_child(tex_rect)
			
		# 4. THE MAGIC LINE: Force it to the dead center of the slot
		# This ignores any weird margins or offsets
		tex_rect.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(60, 60)
	
	# This adds it INSIDE the box
	slot.add_child(icon)
	
	# Centering fix
	icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	if slot.has_node("CountLabel") and amount > 1:
		slot.get_node("CountLabel").text = str(amount)
