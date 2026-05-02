extends CharacterBody2D

@onready var point_light_2d: PointLight2D = $PointLight2D
@export var speed: float = 400.0
var is_attacking: bool = false
var is_dead: bool = false
var cycle

func _physics_process(delta: float) -> void:
	if is_attacking or is_dead:
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

func _update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		$AnimatedSprite2D.play("idle")
	elif direction.y > 0:
		$AnimatedSprite2D.play("walk_down")
	elif direction.y < 0:
		$AnimatedSprite2D.play("walk_up")
	elif direction.x > 0:
		$AnimatedSprite2D.play("walk_right")
	elif direction.x < 0:
		$AnimatedSprite2D.play("walk_left")

func attack() -> void:
	if is_dead or is_attacking:
		return
	is_attacking = true
	$AnimatedSprite2D.play("attack")
	await $AnimatedSprite2D.animation_finished
	is_attacking = false

func die() -> void:
	if is_dead:
		return
	is_dead = true
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	queue_free()

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

func _on_day_time_changed(state) -> void:
	print("State changed to: ", state)
	print("Night value is: ", cycle.DAY_STATE.NIGHT)
	if state == cycle.DAY_STATE.NIGHT:
		point_light_2d.enabled = true
		print("Light ON")
	else:
		point_light_2d.enabled = false
		print("Light OFF")
