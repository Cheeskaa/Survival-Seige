extends "res://scripts/base_weapon.gd"

@export var jab_distance: float = 20.0
@export var jab_duration: float = 0.15

func _do_attack() -> void:
	if nearest_enemy == null:
		return
	var dist = global_position.distance_to(nearest_enemy.global_position)
	if dist > attack_range:
		return
	
	# Jab animation — move forward and back
	var forward = Vector2(cos(rotation), sin(rotation)) * jab_distance
	var tween = create_tween()
	tween.tween_property(self, "position", position + forward, jab_duration)
	tween.tween_property(self, "position", position, jab_duration)
	
	# Deal damage
	if nearest_enemy.has_method("take_damage"):
		nearest_enemy.take_damage(damage)
	
	_start_cooldown()
