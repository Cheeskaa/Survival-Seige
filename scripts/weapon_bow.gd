extends "res://scripts/base_weapon.gd"

const ARROW_SCENE = preload("res://scenes/arrow.tscn")
@export var arrow_speed: float = 600.0

func _ready() -> void:
	super._ready()
	attack_range = 400.0  # bow has long range
	detection_range = 400.0
	attack_speed = 2.0
	damage = 25.0

func _do_attack() -> void:
	var arrow = ARROW_SCENE.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = global_position
	# Use weapon rotation (already points at enemy or cursor)
	arrow.setup(rotation, arrow_speed, damage)
	_start_cooldown()
