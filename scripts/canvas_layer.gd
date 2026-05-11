extends CanvasLayer

@onready var inventory_ui = $Inventory
@onready var hotbar_ui = $Hotbar # Ensure this matches your Hotbar node name
@onready var pause_menu = $PauseMenu

var inventory_open = false
var paused = false

func _ready():
	inventory_ui.visible = false
	pause_menu.visible = false
	
	# 1. Connect to the player to receive inventory updates
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.inventory_changed.connect(_on_player_inventory_changed)

# 2. This function runs every time you pick up an item
func _on_player_inventory_changed(items: Dictionary):
	# Tell the Hotbar to update its icons
	if hotbar_ui and hotbar_ui.has_method("update_slots"):
		hotbar_ui.update_slots(items)
	
	# Tell the Big Inventory to update its icons
	if inventory_ui and inventory_ui.has_method("update_slots"):
		inventory_ui.update_slots(items)

func _unhandled_input(event):
	# Toggle Inventory
	if event.is_action_pressed("inventory"):
		inventory_open = !inventory_open
		inventory_ui.visible = inventory_open
		get_tree().paused = inventory_open

	# Pause / Close Inventory
	if event.is_action_pressed("ui_cancel"):
		if inventory_open:
			inventory_open = false
			inventory_ui.visible = false
			get_tree().paused = false
		else:
			paused = !paused
			pause_menu.visible = paused
			get_tree().paused = paused

func resume():
	paused = false
	pause_menu.visible = false
	get_tree().paused = false
