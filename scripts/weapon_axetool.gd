extends "res://scripts/base_weapon.gd"

@export var swing_duration: float = 0.2
@export var tree_hits_required: int = 3

func _ready() -> void:
	super._ready()
	attack_range = 75.0
	attack_speed = 2.5
	damage = 15.0

func _do_attack() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "rotation", -0.8, swing_duration * 0.3)
	tween.tween_property(sprite, "rotation", 0.8, swing_duration * 0.7)
	tween.tween_property(sprite, "rotation", 0.0, swing_duration * 0.3)

	if nearest_enemy != null:
		var dist = global_position.distance_to(nearest_enemy.global_position)
		if dist <= attack_range:
			if nearest_enemy.has_method("take_damage"):
				nearest_enemy.take_damage(damage)

	_check_trees_by_rotation()
	_start_cooldown()

func _check_trees_by_rotation() -> void:
	if player == null:
		print("ERROR: player is null")
		return

	# Access tilemap directly — no parent check needed
	var tilemap = player.get("tilemap")
	if tilemap == null:
		print("ERROR: tilemap is null on player")
		return

	var reach = 48.0
	var aim_direction = Vector2(cos(rotation), sin(rotation))
	var target_pos = player.global_position + aim_direction * reach
	var map_pos = tilemap.local_to_map(tilemap.to_local(target_pos))
	var cell_id = tilemap.get_cell_source_id(map_pos)

	print("Axe aimed at map_pos: ", map_pos, " | cell_id: ", cell_id)

	if cell_id == 28:
		player._damage_tree_with_hits(map_pos, tree_hits_required)
