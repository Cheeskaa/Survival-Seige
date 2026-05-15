extends CharacterBody2D

@export var speed: float = 100.0
@export var health: float = 100.0
@export var max_health: float = 100.0
@export var attack_damage: float = 10.0
@export var detection_range: float = 500.0
@export var attack_range: float = 60.0
@export var attack_cooldown: float = 1.5
@export var knockback_force: float = 200.0
@export var health_bar_scale: float = 1.0
@export var health_bar_offset: float = -20.0 

var player = null
var is_attacking: bool = false
var is_dead: bool = false
var can_attack: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO
var health_bar = null
const HEALTH_BAR_SCENE = preload("res://scenes/enemy_health_bar.tscn")

enum STATE { IDLE, CHASE, ATTACK }
var current_state = STATE.IDLE

func _ready() -> void:
	add_to_group("enemy")
	# AttackHitbox starts OFF — only turns on during attack
	$AttackHitbox.monitoring = false
	
	health_bar = HEALTH_BAR_SCENE.instantiate()
	add_child(health_bar)
	health_bar.position = Vector2(0, health_bar_offset)
	health_bar.scale = Vector2(health_bar_scale, health_bar_scale)  # ← scale it
	health_bar.setup(max_health, health)
	
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("ERROR: player not found in ", name)
	else:
		print(name, " is ready. Player found!")
	$Hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(_delta: float) -> void:
	if is_dead or player == null:
		return

	# Apply knockback and slow it down over time
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.2)
		if knockback_velocity.length() < 5:
			knockback_velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance = global_position.distance_to(player.global_position)
	if distance <= attack_range:
		current_state = STATE.ATTACK
	elif distance <= detection_range:
		current_state = STATE.CHASE
	else:
		current_state = STATE.IDLE

	match current_state:
		STATE.IDLE: _do_idle()
		STATE.CHASE: _do_chase()
		STATE.ATTACK: _do_attack()

func _do_idle() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	$AnimatedSprite2D.play(_get_idle_animation())

func _do_chase() -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	$AnimatedSprite2D.play(_get_walk_animation())

func _do_attack() -> void:
	if is_attacking or not can_attack:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO
	move_and_slide()
	$AnimatedSprite2D.play(_get_attack_animation())

	# Turn hitbox ON during attack animation only
	await get_tree().create_timer(0.1).timeout
	$AttackHitbox.monitoring = true
	await $AnimatedSprite2D.animation_finished
	$AttackHitbox.monitoring = false

	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var damage = area.get_parent().attack_damage \
			if area.get_parent().get("attack_damage") != null else 10.0
		take_damage(damage)
		# Knockback away from player
		var knockback_dir = (global_position - area.get_parent().global_position).normalized()
		apply_knockback(knockback_dir)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	print(name, " took damage: ", amount, " | HP remaining: ", health)
	if health_bar:
		health_bar.take_damage(amount)
	if health <= 0:
		_die()
	else:
		_play_hit()

func apply_knockback(direction: Vector2) -> void:
	knockback_velocity = direction * knockback_force

func _play_hit() -> void:
	$AnimatedSprite2D.play(_get_hit_animation())
	await $AnimatedSprite2D.animation_finished

func _die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	$AttackHitbox.monitoring = false
	$AnimatedSprite2D.play(_get_die_animation())
	await $AnimatedSprite2D.animation_finished
	queue_free()  # removes enemy from scene after death animation

func _get_idle_animation() -> String:
	return "idle"
func _get_walk_animation() -> String:
	return "walk"
func _get_attack_animation() -> String:
	return "attack"
func _get_hit_animation() -> String:
	return "hit"
func _get_die_animation() -> String:
	return "die"
