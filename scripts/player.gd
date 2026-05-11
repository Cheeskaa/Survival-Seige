extends CharacterBody2D

@onready var point_light_2d: PointLight2D = $PointLight2D
<<<<<<< Updated upstream
=======
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound
@onready var flashlight_sound: AudioStreamPlayer2D = $FlashlightSound
@onready var wood_scene = preload("res://scenes/wood_drop.tscn")
@onready var tilemap: TileMapLayer = get_parent().get_node("props") 

>>>>>>> Stashed changes
@export var speed: float = 400.0
@export var tree_respawn_time: float = 30.0 

var tree_health: Dictionary = {} 
var is_dead: bool = false
var is_attacking: bool = false
var cycle
var last_direction: String = "down"
<<<<<<< Updated upstream

func _ready() -> void:
	add_to_group("player")
	point_light_2d.enabled = false
=======

# This holds our items
var inventory: Dictionary = {}
signal inventory_changed(new_inventory: Dictionary)

func _ready() -> void:
	add_to_group("player")
	if point_light_2d:
		point_light_2d.enabled = false
		point_light_2d.energy = 1.0 
	attack_hitbox.monitoring = false
>>>>>>> Stashed changes
	await get_tree().process_frame
	cycle = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle == null:
		print("ERROR: day_night_cycle node not found!")
		return
	cycle.connect("change_day_time", _on_day_time_changed)
	_on_day_time_changed(cycle.current_state)

<<<<<<< Updated upstream
func _physics_process(delta: float) -> void:
	if is_dead:
		return
=======
# NEW: This allows the UI slots to tell the player "I moved an item"
func sync_ui_to_inventory(new_ui_data: Dictionary):
	inventory = new_ui_data
	# Tell ALL UI (Hotbar and Inventory) to refresh based on the new data
	inventory_changed.emit(inventory)

func _physics_process(_delta: float) -> void:
	if is_dead: return
>>>>>>> Stashed changes
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Vector2.ZERO
<<<<<<< Updated upstream
	if Input.is_action_pressed("walk_right"):
		direction.x += 1
	if Input.is_action_pressed("walk_left"):
		direction.x -= 1
	if Input.is_action_pressed("walk_down"):
		direction.y += 1
	if Input.is_action_pressed("walk_up"):
		direction.y -= 1
=======
	if Input.is_action_pressed("walk_right"): direction.x += 1
	if Input.is_action_pressed("walk_left"): direction.x -= 1
	if Input.is_action_pressed("walk_down"): direction.y += 1
	if Input.is_action_pressed("walk_up"): direction.y -= 1
	
>>>>>>> Stashed changes
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()
	_update_animation(direction)

func _unhandled_input(event: InputEvent) -> void:
<<<<<<< Updated upstream
	if event.is_action_pressed("attack"):
		attack()
=======
	if event.is_action_pressed("attack"): attack()
	if event.is_action_pressed("toggle_light"): toggle_flashlight()

func toggle_flashlight() -> void:
	if point_light_2d:
		point_light_2d.enabled = !point_light_2d.enabled
		if flashlight_sound: flashlight_sound.play()
>>>>>>> Stashed changes

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
	if is_dead or is_attacking: return
	is_attacking = true
<<<<<<< Updated upstream
	$AnimatedSprite2D.play("attack_" + last_direction)
	# Get the exact duration of the animation and use it as a timer
	var frames = $AnimatedSprite2D.sprite_frames
	var anim_name = "attack_" + last_direction
	var frame_count = frames.get_frame_count(anim_name)
	var fps = frames.get_animation_speed(anim_name)
	var duration = frame_count / fps
=======
	if attack_sound:
		attack_sound.pitch_scale = randf_range(0.9, 1.1) 
		attack_sound.play()
	$AnimatedSprite2D.play("attack_" + last_direction)
	_check_for_trees()
	await get_tree().create_timer(0.1).timeout
	attack_hitbox.monitoring = true
	var frames = $AnimatedSprite2D.sprite_frames
	var anim_name = "attack_" + last_direction
	var duration = (frames.get_frame_count(anim_name) / frames.get_animation_speed(anim_name)) - 0.1
>>>>>>> Stashed changes
	await get_tree().create_timer(duration).timeout
	is_attacking = false

<<<<<<< Updated upstream
=======
func _check_for_trees():
	if not tilemap: return
	var reach = 40.0
	var offset = Vector2.ZERO
	if last_direction == "down": offset.y = reach
	elif last_direction == "up": offset.y = -reach
	elif last_direction == "right": offset.x = reach
	elif last_direction == "left": offset.x = -reach
	var target_pos = global_position + offset
	var map_pos = tilemap.local_to_map(tilemap.to_local(target_pos))
	if tilemap.get_cell_source_id(map_pos) == 28:
		_damage_tree(map_pos)

func _damage_tree(pos: Vector2i):
	if not tree_health.has(pos): tree_health[pos] = 3
	tree_health[pos] -= 1
	if tree_health[pos] <= 0:
		tilemap.set_cell(pos, -1)
		tree_health.erase(pos)
		var wood = wood_scene.instantiate()
		get_parent().add_child(wood)
		wood.global_position = tilemap.to_global(tilemap.map_to_local(pos))
		_respawn_tree(pos)

func _respawn_tree(pos: Vector2i):
	await get_tree().create_timer(tree_respawn_time).timeout
	if tilemap:
		tilemap.set_cell(pos, 28, Vector2i(0, 0))

func collect_item(item_name: String) -> void:
	if inventory.has(item_name):
		inventory[item_name] += 1
	else:
		inventory[item_name] = 1
	inventory_changed.emit(inventory)

>>>>>>> Stashed changes
func die() -> void:
	if is_dead: return
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
