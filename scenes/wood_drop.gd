extends Area2D

@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# 1. Add item to player inventory
		body.collect_item("Wood")
		
		# 2. Make the meat invisible and stop it from being picked up again
		set_deferred("monitoring", false)
		visible = false
		
		# 3. Play the sound
		if pickup_sound:
			pickup_sound.play()
			# 4. Wait for the sound to end before removing the node
			await pickup_sound.finished
		
		queue_free()
