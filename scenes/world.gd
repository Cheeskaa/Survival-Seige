extends Node2D

@onready var current_map_container: Node2D = $CurrentMap
@onready var player: CharacterBody2D = $player

var starting_map = "res://scenes/test_map.tscn" 

func _ready() -> void:
	SceneManager.world_node = self
	# Use call_deferred to safely load the first map on startup
	call_deferred("load_map", starting_map, "")

func load_map(map_path: String, target_portal: String):
	# 1. Clear out the old map nodes safely using free/deferred operations
	for child in current_map_container.get_children():
		child.queue_free()
		
	# 2. Load and instance the new map scene
	var map_scene = load(map_path)
	if map_scene:
		var new_map = map_scene.instantiate()
		current_map_container.add_child(new_map)
		
		# 3. Position player at the designated target portal marker
		if target_portal != "":
			await get_tree().process_frame 
			var spawn_point = new_map.find_child(target_portal)
			if spawn_point:
				player.global_position = spawn_point.global_position
