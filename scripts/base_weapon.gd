extends Node2D

# Override these in each weapon script
@export var weapon_name: String = "Weapon"
@export var damage: float = 10.0
@export var attack_range: float = 80.0
@export var attack_speed: float = 1.0  # attacks per second
@export var detection_range: float = 300.0

var player = null
var can_attack: bool = true
var nearest_enemy = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	player = get_parent()

func _process(_delta: float) -> void:
	if not visible:
		return
	_find_nearest_enemy()
	_rotate_toward_enemy()

func _find_nearest_enemy() -> void:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest_dist = detection_range
	nearest_enemy = null
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest_dist = dist
			nearest_enemy = enemy

func _rotate_toward_enemy() -> void:
	if nearest_enemy != null:
		var direction = nearest_enemy.global_position - global_position
		rotation = direction.angle()
	else:
		# Follow cursor when no enemy nearby
		var cursor_pos = get_global_mouse_position()
		var direction = cursor_pos - global_position
		rotation = direction.angle()

func try_attack() -> void:
	if not can_attack or not visible:
		return
	if nearest_enemy == null:
		return
	_do_attack()

func _do_attack() -> void:
	pass  # override in each weapon

func _start_cooldown() -> void:
	can_attack = false
	await get_tree().create_timer(1.0 / attack_speed).timeout
	can_attack = true
