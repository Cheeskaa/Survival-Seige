extends "res://scripts/base_weapon.gd"

@export var jab_distance: float = 25.0
@export var jab_duration: float = 0.1

func _ready() -> void:
	super._ready()
	attack_range = 110.0
	attack_speed = 3.0
	damage = 15.0

func _do_attack() -> void:
	# Always jab regardless of enemy
	var forward = Vector2(cos(rotation), sin(rotation)) * jab_distance
	var tween = create_tween()
	tween.tween_property(sprite, "position", sprite.position + forward, jab_duration)
	tween.tween_property(sprite, "position", Vector2(12, 0), jab_duration)

	# Only deal damage if enemy is in range
	if nearest_enemy != null:
		var dist = global_position.distance_to(nearest_enemy.global_position)
		if dist <= attack_range:
			if nearest_enemy.has_method("take_damage"):
				nearest_enemy.take_damage(damage)

	_start_cooldown()
