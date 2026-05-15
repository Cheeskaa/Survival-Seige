extends "res://scripts/base_weapon.gd"

@export var swing_duration: float = 0.2

func _do_attack() -> void:
	if nearest_enemy == null:
		return
	var dist = global_position.distance_to(nearest_enemy.global_position)
	if dist > attack_range:
		return
	
	# Swing animation — rotate back and forth
	var original_rot = rotation
	var tween = create_tween()
	tween.tween_property(self, "rotation", rotation - 0.8, swing_duration * 0.5)
	tween.tween_property(self, "rotation", rotation + 0.8, swing_duration)
	tween.tween_property(self, "rotation", original_rot, swing_duration * 0.5)
	
	# Deal damage
	if nearest_enemy.has_method("take_damage"):
		nearest_enemy.take_damage(damage)
	
	_start_cooldown()
