extends CharacterBody2D

@export var speed: float = 50.0        # Slow roam
@export var charge_speed: float = 180.0 # Fast attack
@export var roam_radius: float = 500.0
@export var aggro_radius: float = 250.0 # Detection range
@export var max_health: int = 5
@export var damage_amount: int = 1
@export var respawn_time: float = 15.0
@export var meat_drop_scene: PackedScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

var spawn_position: Vector2
var target_position: Vector2
var is_idle: bool = true
var is_attacking_player: bool = false
var is_hurt: bool = false
var is_dead: bool = false

var idle_timer: float = 0.0
var walk_timer: float = 0.0
var last_direction: String = "front"
var current_anim: String = ""
var player: Node2D = null
var current_health: int = 0

func _ready() -> void:
	add_to_group("enemy")
	spawn_position = global_position
	target_position = global_position
	current_health = max_health
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	_start_idle()

func _physics_process(delta: float) -> void:
	if is_dead or is_hurt:
		return

	if player:
		var dist = global_position.distance_to(player.global_position)
		
		# If player is close, start charging
		if dist < aggro_radius:
			is_attacking_player = true
		elif dist > aggro_radius * 2: # Stop if player runs far away
			is_attacking_player = false

	if is_attacking_player and player:
		_charge_at_player(delta)
	elif is_idle:
		idle_timer -= delta
		if idle_timer <= 0: _start_walking()
	else:
		walk_timer -= delta
		if walk_timer <= 0 or _reached_target(): 
			_start_idle()
		else:
			_move_toward_target(delta)

func _move_toward_target(_delta: float) -> void:
	var direction = (target_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	_update_direction(direction)
	_play_anim("walk_" + last_direction)

func _charge_at_player(_delta: float) -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * charge_speed
	
	# Check for contact damage
	var collision = move_and_collide(velocity * _delta)
	if collision:
		var collider = collision.get_collider()
		if collider.has_method("take_damage") and collider.is_in_group("player"):
			collider.take_damage(damage_amount)
	
	_update_direction(direction)
	_play_anim("run_" + last_direction)

func _update_direction(direction: Vector2) -> void:
	if abs(direction.y) > abs(direction.x):
		last_direction = "front" if direction.y > 0 else "back"
	else:
		last_direction = "right" if direction.x > 0 else "left"

func _reached_target() -> bool:
	return global_position.distance_to(target_position) < 8.0

func _start_idle() -> void:
	is_idle = true
	velocity = Vector2.ZERO
	idle_timer = randf_range(2.0, 4.0)
	_play_anim("idle_" + last_direction)

func _start_walking() -> void:
	is_idle = false
	walk_timer = randf_range(2.0, 5.0)
	target_position = _get_random_target()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "AttackHitbox" and not is_hurt and not is_dead:
		if player and player.get("is_attacking") == true:
			is_attacking_player = true # Anger the boar if hit
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

func die() -> void:
	if is_dead: return
	is_dead = true
	velocity = Vector2.ZERO
	_play_anim("death_" + last_direction)
	await animated_sprite.animation_finished
	_spawn_meat()
	_hide_boar()
	await get_tree().create_timer(respawn_time).timeout
	_respawn()

func _hide_boar() -> void:
	visible = false
	set_physics_process(false)
	hitbox.monitoring = false

func _respawn() -> void:
	global_position = spawn_position
	visible = true
	set_physics_process(true)
	hitbox.monitoring = true
	is_dead = false
	is_attacking_player = false
	current_health = max_health
	_start_idle()

func _spawn_meat() -> void:
	if meat_drop_scene:
		var meat = meat_drop_scene.instantiate()
		get_parent().add_child(meat)
		meat.global_position = global_position

func _play_anim(anim_name: String) -> void:
	if current_anim != anim_name:
		current_anim = anim_name
		animated_sprite.play(anim_name)

func _get_random_target() -> Vector2:
	var angle = randf_range(0, TAU)
	return spawn_position + Vector2(cos(angle), sin(angle)) * randf_range(50, roam_radius)
