extends CharacterBody2D

@export var speed: float = 100.0
@export var health: float = 100.0
@export var max_health: float = 100.0
@export var attack_damage: float = 10.0
@export var detection_range: float = 500.0
@export var attack_range: float = 60.0
@export var attack_cooldown: float = 1.5
@export var knockback_force: float = 200.0
@export var campfire_attack_damage: float = 3.0  # damage to campfire per hit
@export var player_priority_range: float = 400.0  # if player within this, chase player

var player = null
var campfire = null
var is_attacking: bool = false
var is_dead: bool = false
var can_attack: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO

enum STATE { IDLE, CHASE_PLAYER, ATTACK_PLAYER, CHASE_CAMPFIRE, ATTACK_CAMPFIRE }
var current_state = STATE.IDLE

var health_bar = null
const HEALTH_BAR_SCENE = preload("res://scenes/enemy_health_bar.tscn")

func _ready() -> void:
	add_to_group("enemy")
	$AttackHitbox.monitoring = false

	# Spawn health bar
	health_bar = HEALTH_BAR_SCENE.instantiate()
	add_child(health_bar)
	health_bar.position = Vector2(0, -20)
	health_bar.setup(max_health, health)

	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	campfire = get_tree().get_first_node_in_group("campfire")

	if player == null:
		print("ERROR: player not found in ", name)
	if campfire == null:
		print("Notice: no campfire found for ", name)

	$Hurtbox.area_entered.connect(_on_hurtbox_area_entered)

func _physics_process(_delta: float) -> void:
	if is_dead or player == null:
		return

	# Apply knockback
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.2)
		if knockback_velocity.length() < 5:
			knockback_velocity = Vector2.ZERO
		move_and_slide()
		return

	_update_state()

	match current_state:
		STATE.IDLE:
			_do_idle()
		STATE.CHASE_PLAYER:
			_do_chase(player)
		STATE.ATTACK_PLAYER:
			_do_attack_target(player, attack_damage)
		STATE.CHASE_CAMPFIRE:
			if campfire:
				_do_chase(campfire)
		STATE.ATTACK_CAMPFIRE:
			if campfire:
				_do_attack_campfire()

func _update_state() -> void:
	var dist_to_player = global_position.distance_to(player.global_position)

	# Player is close — always prioritize player
	if dist_to_player <= player_priority_range:
		if dist_to_player <= attack_range:
			current_state = STATE.ATTACK_PLAYER
		else:
			current_state = STATE.CHASE_PLAYER
		return

	# Player is far — go for campfire
	if campfire and is_instance_valid(campfire) and not campfire.is_dead:
		var dist_to_campfire = global_position.distance_to(campfire.global_position)
		if dist_to_campfire <= attack_range:
			current_state = STATE.ATTACK_CAMPFIRE
		else:
			current_state = STATE.CHASE_CAMPFIRE
		return

	# Nothing to do
	current_state = STATE.IDLE

func _do_idle() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	$AnimatedSprite2D.play(_get_idle_animation())

func _do_chase(target: Node2D) -> void:
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	$AnimatedSprite2D.play(_get_walk_animation())

func _do_attack_target(target: Node2D, damage: float) -> void:
	if is_attacking or not can_attack:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO
	move_and_slide()
	$AnimatedSprite2D.play(_get_attack_animation())

	# Wait a short time then deal damage — don't wait for animation_finished
	# because some animations loop and never finish
	await get_tree().create_timer(0.3).timeout
	$AttackHitbox.monitoring = true

	# Deal damage if still in range
	if target and is_instance_valid(target):
		var dist = global_position.distance_to(target.global_position)
		if dist <= attack_range:
			if target.has_method("take_damage"):
				target.take_damage(damage)
				print(name, " dealt ", damage, " damage to ", target.name)

	await get_tree().create_timer(0.2).timeout
	$AttackHitbox.monitoring = false

	is_attacking = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _do_attack_campfire() -> void:
	print("Trying to attack campfire")
	print("Campfire valid: ", is_instance_valid(campfire))
	if campfire:
		print("Campfire has take_damage: ", campfire.has_method("take_damage"))
		print("Distance to campfire: ", global_position.distance_to(campfire.global_position))
		print("Attack range: ", attack_range)
	_do_attack_target(campfire, campfire_attack_damage)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hitbox"):
		var damage = area.get_parent().attack_damage \
			if area.get_parent().get("attack_damage") != null else 10.0
		take_damage(damage)
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
	queue_free()

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
