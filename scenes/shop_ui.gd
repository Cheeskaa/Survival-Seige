extends Control

func _ready():
	# Hide the shop when the game starts
	visible = false

func _input(event):
	# Check if the "open_shop" (Q) key was pressed
	if event.is_action_pressed("open_shop"):
		# Toggle visibility (if it's on, turn it off. if it's off, turn it on)
		visible = !visible
		
		# Optional: Pause the game when shop is open
		# get_tree().paused = visible
