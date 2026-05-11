extends Panel

var item_name: String = ""
var quantity: int = 0
var icon_texture: Texture2D = null

@onready var icon_rect: TextureRect = $Icon
@onready var count_label: Label = $CountLabel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_update_ui()

func set_slot_data(new_name: String, new_qty: int, new_tex: Texture2D) -> void:
	item_name = new_name
	quantity = new_qty
	icon_texture = new_tex
	_update_ui()

func _update_ui() -> void:
	if icon_rect:
		icon_rect.texture = icon_texture
		icon_rect.visible = (item_name != "")
	if count_label:
		if quantity > 1:
			count_label.text = str(quantity)
			count_label.visible = true
		else:
			count_label.visible = false

# --- DRAG AND DROP ---

func _get_drag_data(_at_position: Vector2):
	if item_name == "": return null
	var preview = TextureRect.new()
	preview.texture = icon_texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.custom_minimum_size = Vector2(50, 50)
	
	var preview_container = Control.new()
	preview_container.add_child(preview)
	preview.position = -preview.custom_minimum_size / 2
	set_drag_preview(preview_container)
	return self

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Control and data.has_method("set_slot_data")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	# 1. Visual Swap
	var temp_name = item_name
	var temp_qty = quantity
	var temp_tex = icon_texture
	
	set_slot_data(data.item_name, data.quantity, data.icon_texture)
	data.set_slot_data(temp_name, temp_qty, temp_tex)
	
	# 2. Sync to Player
	# We find all slots in the current menu to rebuild the player's dictionary
	_sync_all_slots_to_player()

func _sync_all_slots_to_player():
	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	
	# We look at the parent container (GridContainer or HBoxContainer)
	var parent_node = get_parent()
	var new_inventory = {}
	
	for slot in parent_node.get_children():
		if slot.item_name != "":
			# Add to dictionary. 
			# Note: If you have multiple slots with the same item, 
			# dictionaries can be tricky. This works for unique items!
			new_inventory[slot.item_name] = slot.quantity
			
	player.sync_ui_to_inventory(new_inventory)
