extends "res://scripts/base_weapon.gd"

const MAGIC_SCENE = preload("res://scenes/magic_projectile.tscn")
@export var projectile_speed: float = 500.0

func _ready() -> void:
	super._ready()
	attack_range = 350.0
	detection_range = 350.0
	attack_speed = 3.0
	damage = 18.0

func _do_attack() -> void:
	var projectile = MAGIC_SCENE.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	# Use weapon rotation (already points at enemy or cursor)
	projectile.setup(rotation, projectile_speed, damage)
	_start_cooldown()
