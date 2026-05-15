extends "res://scripts/base_weapon.gd"

const ARROW_SCENE = preload("res://scenes/arrow.tscn")
@export var arrow_speed: float = 600.0

func _do_attack() -> void:
	if nearest_enemy == null:
		return
	
	# Spawn arrow
	var arrow = ARROW_SCENE.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.global_position = global_position
	arrow.setup(rotation, arrow_speed, damage)
	
	_start_cooldown()
