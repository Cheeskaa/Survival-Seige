extends CanvasLayer

@onready var inventory = $Inventory
@onready var pause_menu = $PauseMenu
var inventory_open = false
var paused = false

func _ready():
	inventory.visible = false
	pause_menu.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("inventory"):
		inventory_open = !inventory_open
		inventory.visible = inventory_open
		get_tree().paused = inventory_open

	if event.is_action_pressed("ui_cancel"):
		if inventory_open:
			inventory_open = false
			inventory.visible = false
			get_tree().paused = false
		else:
			paused = !paused
			pause_menu.visible = paused
			get_tree().paused = paused

func resume():
	paused = false
	pause_menu.visible = false
	get_tree().paused = false
