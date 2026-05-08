extends CharacterBody2D

@onready var point_light_2d: PointLight2D = $PointLight2D
@export var speed: float = 400.0
var is_dead: bool = false
var is_attacking: bool = false
var cycle
var last_direction: String = "down"

func _ready() -> void:
	add_to_group("player")
	point_light_2d.enabled = false
	await get_tree().process_frame
	cycle = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle == null:
		print("ERROR: day_night_cycle node not found!")
		return
	cycle.connect("change_day_time", _on_day_time_changed)
	_on_day_time_changed(cycle.current_state)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Vector2.ZERO
	if Input.is_action_pressed("walk_right"):
		direction.x += 1
	if Input.is_action_pressed("walk_left"):
		direction.x -= 1
	if Input.is_action_pressed("walk_down"):
		direction.y += 1
	if Input.is_action_pressed("walk_up"):
		direction.y -= 1
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()
	_update_animation(direction)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		attack()

func _update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		$AnimatedSprite2D.play("idle")
	elif direction.y > 0:
		last_direction = "down"
		$AnimatedSprite2D.play("walk_down")
	elif direction.y < 0:
		last_direction = "up"
		$AnimatedSprite2D.play("walk_up")
	elif direction.x > 0:
		last_direction = "right"
		$AnimatedSprite2D.play("walk_right")
	elif direction.x < 0:
		last_direction = "left"
		$AnimatedSprite2D.play("walk_left")

func attack() -> void:
	if is_dead or is_attacking:
		return
	is_attacking = true
	$AnimatedSprite2D.play("attack_" + last_direction)
	# Get the exact duration of the animation and use it as a timer
	var frames = $AnimatedSprite2D.sprite_frames
	var anim_name = "attack_" + last_direction
	var frame_count = frames.get_frame_count(anim_name)
	var fps = frames.get_animation_speed(anim_name)
	var duration = frame_count / fps
	await get_tree().create_timer(duration).timeout
	is_attacking = false

func die() -> void:
	if is_dead:
		return
	is_dead = true
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	queue_free()

func _on_day_time_changed(state) -> void:
	print("State changed to: ", state)
	print("Night value is: ", cycle.DAY_STATE.NIGHT)
	if state == cycle.DAY_STATE.NIGHT:
		point_light_2d.enabled = true
		print("Light ON")
	else:
		point_light_2d.enabled = false
		print("Light OFF")
