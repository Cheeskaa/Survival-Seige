extends "res://scripts/base_weapon.gd"

@export var swing_duration: float = 0.15

func _ready() -> void:
	super._ready()
	attack_range = 90.0
	attack_speed = 3.0
	damage = 20.0

func _do_attack() -> void:
	# Always swing regardless of enemy
	var tween = create_tween()
	tween.tween_property(sprite, "rotation", -1.0, swing_duration * 0.3)
	tween.tween_property(sprite, "rotation", 1.0, swing_duration * 0.7)
	tween.tween_property(sprite, "rotation", 0.0, swing_duration * 0.3)

	# Only deal damage if enemy is in range
	if nearest_enemy != null:
		var dist = global_position.distance_to(nearest_enemy.global_position)
		if dist <= attack_range:
			if nearest_enemy.has_method("take_damage"):
				nearest_enemy.take_damage(damage)

	_start_cooldown()
