extends Control

@onready var hbox = $HBoxContainer 

var icon_map = {
	"Raw Meat": preload("res://sprites/materials/Meat/Meat Resource/Meat Resource.png"),
	"Wood": preload("res://sprites/materials/Wood Resource.png") # ADD THIS LINE
}

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed(items: Dictionary) -> void:
	if not hbox:
		return
		
	var slots = hbox.get_children() 
	var item_names = items.keys()

	for i in range(slots.size()):
		var slot = slots[i]
		
		# 1. Clear old icons
		for child in slot.get_children():
			if child is TextureRect:
				child.queue_free()
		
		var label = slot.get_node_or_null("CountLabel")
		if label: 
			label.text = ""

		# 2. Draw the new item
		if i < item_names.size():
			var item_name = item_names[i]
			var count = items[item_name]
			
			if icon_map.has(item_name):
				var tex_rect = TextureRect.new()
				tex_rect.texture = icon_map[item_name]
				tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				tex_rect.custom_minimum_size = Vector2(50, 50) 
				
				slot.add_child(tex_rect)
				tex_rect.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
				
				# --- NEW STUFF BELOW ---
				
				# 3. Update the label if we have more than 1 item
				if label and count > 1:
					label.text = str(count)
					# This moves the label to the front so the meat doesn't hide it
					slot.move_child(label, -1)
