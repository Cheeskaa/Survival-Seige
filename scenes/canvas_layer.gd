extends CanvasLayer

@onready var inventory = $Inventory

var inventory_open = false

func _ready():
	inventory.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("inventory"):
		inventory_open = !inventory_open
		inventory.visible = inventory_open
		get_tree().paused = inventory_open
