extends Node2D

@export var ore_scene: PackedScene 
@export var respawn_time: float = 10.0

func _ready():
	$RespawnTimer.timeout.connect(spawn_ore)
	spawn_ore()

func spawn_ore():
	if ore_scene:
		var new_ore = ore_scene.instantiate()
		add_child(new_ore)
		new_ore.position = Vector2.ZERO
		new_ore.tree_exited.connect(_on_ore_destroyed)

func _on_ore_destroyed():
	# SAFE TREE CHECK: Stop script instantly if changing scenes
	if not is_inside_tree(): 
		return
		
	await get_tree().process_frame
	
	# Verify again after the brief frame wait
	if is_inside_tree() and get_child_count() <= 1:
		$RespawnTimer.start(respawn_time)
		print("Ore destroyed! Spawner timer started.")
