extends CharacterBody2D

@export var speed: float = 60.0
@export var run_speed: float = 140.0
@export var roam_radius: float = 800.0
@export var flee_radius: float = 300.0
@export var flee_duration: float = 30.0
@export var max_health: int = 3
@export var respawn_time: float = 10.0
@export var meat_drop_scene: PackedScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

var spawn_position: Vector2
var target_position: Vector2
var is_idle: bool = true
var is_fleeing: bool = false
var is_hurt: bool = false
var is_dead: bool = false
var idle_timer: float = 0.0
var walk_timer: float = 0.0
var flee_timer: float = 0.0
var last_direction: String = "front"
var current_anim: String = ""
var player: Node2D = null
var current_health: int = 0

func _ready() -> void:
	add_to_group("animal")
	add_to_group("enemy")
	spawn_position = global_position
	target_position = global_position
	current_health = max_health
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("ERROR: player not found for deer!")
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	_start_idle()

func _physics_process(delta: float) -> void:
	if is_dead or is_hurt:
		return
	if player and not is_fleeing:
		var dist = global_position.distance_to(player.global_position)
		if dist < flee_radius:
			_start_fleeing()
			return
	if is_fleeing:
		flee_timer -= delta
		if flee_timer <= 0:
			_stop_fleeing()
			return
		_flee_from_player(delta)
		return
	if is_idle:
		idle_timer -= delta
		if idle_timer <= 0:
			_start_walking()
	else:
		walk_timer -= delta
		if walk_timer <= 0 or _reached_target():
			_start_idle()
			return
		_move_toward_target(delta)

func _move_toward_target(_delta: float) -> void:
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	_update_direction(direction)
	_play_anim("walk_" + last_direction)

func _flee_from_player(_delta: float) -> void:
	if player == null:
		return
	var flee_direction = (global_position - player.global_position).normalized()
	velocity = flee_direction * run_speed
	move_and_slide()
	_update_direction(flee_direction)
	_play_anim("run_" + last_direction)

func _update_direction(direction: Vector2) -> void:
	var new_direction: String
	if abs(direction.y) > abs(direction.x):
		new_direction = "front" if direction.y > 0 else "back"
	else:
		new_direction = "right" if direction.x > 0 else "left"
	if new_direction != last_direction:
		last_direction = new_direction

func _reached_target() -> bool:
	return global_position.distance_to(target_position) < 8.0

func _start_idle() -> void:
	is_idle = true
	velocity = Vector2.ZERO
	idle_timer = randf_range(2.0, 5.0)
	_play_anim("idle_" + last_direction)

func _start_walking() -> void:
	is_idle = false
	walk_timer = randf_range(2.0, 4.0)
	target_position = _get_random_target()
	_play_anim("walk_" + last_direction)

func _start_fleeing() -> void:
	is_fleeing = true
	is_idle = false
	flee_timer = flee_duration
	_play_anim("run_" + last_direction)

func _stop_fleeing() -> void:
	is_fleeing = false
	_start_idle()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if is_hurt or is_dead:
		return
	# Works with both player AttackHitbox and weapon attacks
	if area.is_in_group("player_hitbox") or area.get_parent().is_in_group("weapon"):
		take_damage(1)

func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		die()
	else:
		_play_hurt()

func _play_hurt() -> void:
	is_hurt = true
	velocity = Vector2.ZERO
	_play_anim("hurt_" + last_direction)
	await animated_sprite.animation_finished
	is_hurt = false
	if not is_dead:
		_start_fleeing()

func die() -> void:
	if is_dead:
		return
	is_dead = true
	is_hurt = false
	velocity = Vector2.ZERO
	_play_anim("death_" + last_direction)
	await animated_sprite.animation_finished
	_spawn_meat()
	_hide_deer()
	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _hide_deer() -> void:
	animated_sprite.visible = false
	hitbox.monitoring = false
	hitbox.monitorable = false
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = true

func _show_deer() -> void:
	animated_sprite.visible = true
	hitbox.monitoring = true
	hitbox.monitorable = true
	for child in get_children():
		if child is CollisionShape2D:
			child.disabled = false

func _respawn() -> void:
	global_position = spawn_position
	is_dead = false
	is_hurt = false
	is_fleeing = false
	current_health = max_health
	current_anim = ""
	_show_deer()
	_start_idle()

func _spawn_meat() -> void:
	if meat_drop_scene == null:
		print("ERROR: meat_drop_scene not assigned!")
		return
	var meat = meat_drop_scene.instantiate()
	var drop_pos = global_position
	get_parent().add_child(meat)
	meat.global_position = drop_pos

func _play_anim(anim_name: String) -> void:
	if current_anim != anim_name:
		current_anim = anim_name
		animated_sprite.play(anim_name)

func _get_random_target() -> Vector2:
	var angle = randf_range(0, TAU)
	var distance = randf_range(50.0, roam_radius)
	return spawn_position + Vector2(cos(angle), sin(angle)) * distance
