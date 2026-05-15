extends "res://scripts/base_enemy.gd"

func _get_idle_animation() -> String:
	return "idle"
func _get_walk_animation() -> String:
	return "walk"
func _get_attack_animation() -> String:
	return "attack"
func _get_hit_animation() -> String:
	return "hurt"
func _get_die_animation() -> String:
	return "death"
