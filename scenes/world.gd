extends Node2D

@onready var current_map_container: Node2D = $CurrentMap
@onready var day_music: AudioStreamPlayer2D = $DayMusic
@onready var night_music: AudioStreamPlayer2D = $NightMusic

# Safe fetch: Try finding lowercase or uppercase player node
var player: CharacterBody2D = null
var starting_map = "res://scenes/test_map.tscn" 

func _ready() -> void:
	SceneManager.world_node = self
	
	# Fallback node assignment to catch typos
	if has_node("Player"):
		player = $Player
	elif has_node("player"):
		player = get_node("player")
	else:
		print("ERROR: Could not find a node named 'Player' or 'player' inside World.tscn!")
		
	call_deferred("load_map", starting_map, "")
	
	# Connect music to the day/night cycle setup
	call_deferred("setup_music")

func setup_music() -> void:
	if has_node("DayAndNightCycle"):
		var cycle = $DayAndNightCycle
		# Connect to your cycle signal
		cycle.change_day_time.connect(_on_day_time_changed)
		
		# Start playing both tracks silently so they stay synced in the background
		day_music.volume_db = -80
		night_music.volume_db = -80
		day_music.play()
		night_music.play()
		
		# Run an initial check to see if it is currently day or night
		_on_day_time_changed(cycle.current_state)

func _on_day_time_changed(state) -> void:
	# Access the state enum values from your cycle node safely
	var cycle = $DayAndNightCycle
	
	# Create a tween to cross-fade the audio tracks smoothly over 2 seconds
	var tween = create_tween().set_parallel(true)
	
	if state == cycle.DAY_STATE.NIGHT:
		# Fade out morning music, fade in thrilling night music
		tween.tween_property(day_music, "volume_db", -80.0, 2.0)
		tween.tween_property(night_music, "volume_db", 0.0, 2.0)
		print("Music Switching: Playing Night Tracks")
	else:
		# Fade out night music, fade in peaceful morning music
		tween.tween_property(day_music, "volume_db", 0.0, 2.0)
		tween.tween_property(night_music, "volume_db", -80.0, 2.0)
		print("Music Switching: Playing Day Tracks")

func load_map(map_path: String, target_portal: String):
	for child in current_map_container.get_children():
		child.queue_free()
		
	var map_scene = load(map_path)
	if map_scene:
		var new_map = map_scene.instantiate()
		current_map_container.add_child(new_map)
		
		if target_portal != "":
			await get_tree().process_frame 
			var spawn_point = new_map.find_child(target_portal)
			
			if spawn_point and player:
				player.global_position = spawn_point.global_position
			else:
				if player == null:
					print("Spawning failed: Player instance is missing from the World container.")
