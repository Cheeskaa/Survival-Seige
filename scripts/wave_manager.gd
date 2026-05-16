extends Node

# Enemy scenes
const ENEMY_SCENES = [
	preload("res://scenes/characters/enemies/happyslime.tscn"),
	preload("res://scenes/characters/enemies/happyslime_blue.tscn"),
	preload("res://scenes/characters/enemies/happyslime_lava.tscn"),
	preload("res://scenes/characters/enemies/giant_slime.tscn"),
	preload("res://scenes/characters/enemies/small_slime.tscn"),
	preload("res://scenes/characters/enemies/giant_ghost.tscn"),
	preload("res://scenes/characters/enemies/small_ghost.tscn"),
]

# Boss spawns every 5 nights
const BOSS_SCENE = preload("res://scenes/characters/enemies/giant_bamboo_boss.tscn")

@export var base_enemy_count: int = 5     # first night enemy count
@export var enemies_per_night: int = 2    # increase per night
@export var spawn_radius: float = 350.0   # distance from player to spawn

var current_night: int = 0
var active_enemies: Array = []
var wave_active: bool = false
var cycle_node = null
var player = null

func _ready() -> void:
	await get_tree().process_frame
	cycle_node = get_tree().get_first_node_in_group("day_night_cycle")
	player = get_tree().get_first_node_in_group("player")

	if cycle_node == null:
		print("ERROR: day_night_cycle not found in wave_manager!")
		return

	cycle_node.change_day_time.connect(_on_day_time_changed)
	print("WaveManager ready!")

func _on_day_time_changed(state) -> void:
	if state == cycle_node.DAY_STATE.NIGHT:
		_start_wave()
	elif state == cycle_node.DAY_STATE.DAY:
		_on_day_started()

func _start_wave() -> void:
	if wave_active:
		return
	wave_active = true
	current_night += 1
	active_enemies.clear()

	# Calculate how many enemies this night
	var count = base_enemy_count + (current_night - 1) * enemies_per_night
	print("Night ", current_night, " started! Spawning ", count, " enemies")

	# Every 5 nights spawn a boss too
	if current_night % 5 == 0:
		_spawn_enemy(BOSS_SCENE)
		count -= 1  # replace one normal enemy with boss

	# Spawn random enemies
	for i in range(count):
		var random_scene = ENEMY_SCENES[randi() % ENEMY_SCENES.size()]
		_spawn_enemy(random_scene)

func _spawn_enemy(scene: PackedScene) -> void:
	if player == null:
		return

	var enemy = scene.instantiate()
	get_parent().add_child(enemy)

	# Spawn at random position around player
	var angle = randf() * TAU
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	enemy.global_position = player.global_position + offset

	# Track enemy
	active_enemies.append(enemy)
	enemy.tree_exited.connect(_on_enemy_removed)

	print("Spawned: ", enemy.name, " at ", enemy.global_position)

func _on_enemy_removed() -> void:
	# Clean up dead enemies from list
	active_enemies = active_enemies.filter(
		func(e): return is_instance_valid(e)
	)
	print("Enemies remaining: ", active_enemies.size())

func _on_day_started() -> void:
	wave_active = false
	print("Day started! Remaining enemies: ", active_enemies.size())
