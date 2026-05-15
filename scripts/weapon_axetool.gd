extends "res://scripts/base_weapon.gd"

@export var swing_duration: float = 0.3
@export var tree_hits_required: int = 3  # less than default 5

func _do_attack() -> void:
	if nearest_enemy == null and not _check_tree_nearby():
		return
	
	# Swing animation
	var original_rot = rotation
	var tween = create_tween()
	tween.tween_property(self, "rotation", rotation - 0.8, swing_duration * 0.5)
	tween.tween_property(self, "rotation", rotation + 0.8, swing_duration)
	tween.tween_property(self, "rotation", original_rot, swing_duration * 0.5)
	
	# Hit enemy if in range
	if nearest_enemy != null:
		var dist = global_position.distance_to(nearest_enemy.global_position)
		if dist <= attack_range:
			if nearest_enemy.has_method("take_damage"):
				nearest_enemy.take_damage(damage)
	
	# Also check for trees
	player._check_for_trees_with_axe(tree_hits_required)
	
	_start_cooldown()

func _check_tree_nearby() -> bool:
	return player.has_method("_check_for_trees_with_axe")
