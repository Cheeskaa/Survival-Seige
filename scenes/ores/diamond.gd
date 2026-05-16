extends StaticBody2D

@export var gem_type: String = "diamond" # Matches your crafting dictionary
@export var health: int = 3
@export var gem_scene: PackedScene # Drag Gem.tscn here in the Inspector

func hit():
	health -= 1
	
	# Shake/Flash effect
	modulate = Color(10, 10, 10)
	await get_tree().create_timer(0.05).timeout
	modulate = Color(1, 1, 1)

	if health <= 0:
		var drop = gem_scene.instantiate()
		drop.gem_type = gem_type
		
		# Spawns the gem safely on the main map
		get_tree().current_scene.add_child(drop)
		drop.global_position = global_position
		
		queue_free()
