extends CharacterBody2D

@export var speed: float = 100.0
@export var health: float = 100.0
@export var attack_damage: float = 10.0
@export var detection_range: float = 500.0  # when it starts chasing
@export var attack_range: float = 60.0      # when it attacks

var player: CharacterBody2D = null
var is_attacking: bool = false
var is_dead: bool = false

enum STATE { IDLE, CHASE, ATTACK, HIT, DEAD }
var current_state = STATE.IDLE

func _ready() -> void:
	await get_tree().process_frame
	# Find player in scene
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("ERROR: Player not found! Did you add it to the player group?")
	else:
		print("Player found! Slime is ready.")

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= attack_range:
		current_state = STATE.ATTACK
	elif distance <= detection_range:
		current_state = STATE.CHASE
	else:
		current_state = STATE.IDLE

	match current_state:
		STATE.IDLE:
			_do_idle()
		STATE.CHASE:
			_do_chase()
		STATE.ATTACK:
			_do_attack()

func _do_idle() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	$AnimatedSprite2D.play("idle")

func _do_chase() -> void:
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	$AnimatedSprite2D.play("jump")  # slime uses jump as move animation

func _do_attack() -> void:
	if is_attacking:
		return
	is_attacking = true
	velocity = Vector2.ZERO
	move_and_slide()
	$AnimatedSprite2D.play("jump")  # use jump as attack since no attack anim
	await $AnimatedSprite2D.animation_finished

	# Deal damage to player
	if player and global_position.distance_to(player.global_position) <= attack_range:
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)

	is_attacking = false

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0:
		_die()
	else:
		_play_hit()

func _play_hit() -> void:
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	is_attacking = false  # reset so it can act again

func _die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	queue_free()
