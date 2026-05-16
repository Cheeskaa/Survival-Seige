extends Node2D

@export var weapon_name: String = "Weapon"
@export var damage: float = 10.0
@export var attack_range: float = 80.0
@export var attack_speed: float = 3.0
@export var detection_range: float = 300.0

var player = null
var can_attack: bool = true
var nearest_enemy = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	player = get_parent()
	position = Vector2.ZERO

func _process(_delta: float) -> void:
	if not visible:
		return
	_find_nearest_enemy()
	_rotate_toward_target()
	if Input.is_action_pressed("attack") and can_attack:
		_do_attack()

func _find_nearest_enemy() -> void:
	var targets = []
	targets.append_array(get_tree().get_nodes_in_group("enemy"))
	targets.append_array(get_tree().get_nodes_in_group("animal"))
	var closest_dist = detection_range
	nearest_enemy = null
	for target in targets:  # ← was "enemies", now "target" matches "targets"
		if not is_instance_valid(target):
			continue
		var dist = global_position.distance_to(target.global_position)
		if dist < closest_dist:
			closest_dist = dist
			nearest_enemy = target

func _rotate_toward_target() -> void:
	if nearest_enemy != null:
		var direction = nearest_enemy.global_position - global_position
		rotation = direction.angle()
	else:
		var direction = get_global_mouse_position() - global_position
		rotation = direction.angle()

func try_attack() -> void:
	if not can_attack or not visible:
		return
	_do_attack()

func _do_attack() -> void:
	pass

func _start_cooldown() -> void:
	can_attack = false
	await get_tree().create_timer(1.0 / attack_speed).timeout
	can_attack = true
