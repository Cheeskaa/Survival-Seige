extends HBoxContainer

# Map the item names to your actual image files
var icon_map = {
	"Raw Meat": preload("res://sprites/materials/Meat/Meat Resource/Meat Resource.png")
}

func _ready() -> void:
	# Find player and connect to the signal
	# We use the group "player" to find the character easily
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed(items: Dictionary) -> void:
	var slots = get_children() # Your Panel nodes (the brown boxes)
	var item_names = items.keys() # The list of items from the Dictionary

	# 1. Loop through all your UI slots
	for i in range(slots.size()):
		var slot = slots[i]
		
		# Clear previous icons in this slot so they don't stack on top of each other
		for child in slot.get_children():
			if child is TextureRect:
				child.queue_free()
		
		# Reset the number label
		var label = slot.get_node_or_null("CountLabel")
		if label:
			label.text = ""

		# 2. If we have an item for this slot, draw it
		if i < item_names.size():
			var item_name = item_names[i]
			var count = items[item_name]
			
			# Create and add the icon
			if icon_map.has(item_name):
				var tex_rect = TextureRect.new()
				tex_rect.texture = icon_map[item_name]
				
				# --- ALIGNMENT & SIZE FIX ---
				tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				
				# Set this to match your slot size (70x70 or 80x80)
				tex_rect.custom_minimum_size = Vector2(70, 70)
				
				# This magic line forces the icon to the dead center of the brown box
				tex_rect.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
				# ----------------------------
				
				slot.add_child(tex_rect)
			
			# Update the stack number if the player has more than 1 of that item
			if label and count > 1:
				label.text = str(count)
