extends "res://scripts/base_weapon.gd"

const MAGIC_SCENE = preload("res://scenes/magic_projectile.tscn")
@export var projectile_speed: float = 500.0

func _do_attack() -> void:
	if nearest_enemy == null:
		return
	
	# Spawn magic projectile
	var projectile = MAGIC_SCENE.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.setup(rotation, projectile_speed, damage)
	
	_start_cooldown()
