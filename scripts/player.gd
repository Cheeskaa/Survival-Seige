extends CharacterBody2D

@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound
# NEW: Flashlight sound reference
@onready var flashlight_sound: AudioStreamPlayer2D = $FlashlightSound
@onready var wood_scene = preload("res://scenes/wood_drop.tscn") # Make sure this path is correct!
@onready var tilemap: TileMapLayer = get_parent().get_node("props") # Path to your trees

var tree_health: Dictionary = {} # Stores HP for each tile: {Vector2i: int}

@export var speed: float = 400.0
var is_dead: bool = false
var is_attacking: bool = false
var cycle
var last_direction: String = "down"
signal inventory_changed(new_inventory: Dictionary)
var inventory: Dictionary = {}

func _ready() -> void:
	add_to_group("player")
	
	if point_light_2d:
		# Start with light OFF but with full energy for when we turn it on
		point_light_2d.enabled = false
		point_light_2d.energy = 1.0 
	else:
		print("WARNING: PointLight2D node not found.")

	attack_hitbox.monitoring = false
	await get_tree().process_frame
	cycle = get_tree().get_first_node_in_group("day_night_cycle")

func _process(_delta: float) -> void:
	# REMOVED: Automatic light energy sync so you have total control
	pass

func _physics_process(_delta: float) -> void:
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
	
	# NEW: Manual Toggle Logic
	if event.is_action_pressed("toggle_light"):
		toggle_flashlight()

func toggle_flashlight() -> void:
	if point_light_2d:
		# Toggle the light state
		point_light_2d.enabled = !point_light_2d.enabled
		
		# Play the click sound
		if flashlight_sound:
			flashlight_sound.play()
		
		print("Flashlight: ", "ON" if point_light_2d.enabled else "OFF")

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
	
	if attack_sound:
		attack_sound.pitch_scale = randf_range(0.9, 1.1) 
		attack_sound.play()
	
	$AnimatedSprite2D.play("attack_" + last_direction)
	
	# NEW: Wood Cutting Logic
	_check_for_trees()
	
	await get_tree().create_timer(0.1).timeout
	attack_hitbox.monitoring = true
	
	var frames = $AnimatedSprite2D.sprite_frames
	var anim_name = "attack_" + last_direction
	var frame_count = frames.get_frame_count(anim_name)
	var fps = frames.get_animation_speed(anim_name)
	var duration = (frame_count / fps) - 0.1
	
	await get_tree().create_timer(duration).timeout
	attack_hitbox.monitoring = false
	is_attacking = false

# --- NEW FUNCTION FOR TREES ---
func _check_for_trees():
	if not tilemap: return

	# 1. Get position in front of player based on direction
	var reach = 40.0
	var offset = Vector2.ZERO
	if last_direction == "down": offset.y = reach
	elif last_direction == "up": offset.y = -reach
	elif last_direction == "right": offset.x = reach
	elif last_direction == "left": offset.x = -reach
	
	var target_pos = global_position + offset
	
	# 2. Convert world position to tile map coordinates
	var map_pos = tilemap.local_to_map(tilemap.to_local(target_pos))
	
	# 3. Check if the tile ID is 28 (Tree)
	if tilemap.get_cell_source_id(map_pos) == 28:
		_damage_tree(map_pos)

func _damage_tree(pos: Vector2i):
	# Initialize health if first time hitting this tile
	if not tree_health.has(pos):
		tree_health[pos] = 3
	
	tree_health[pos] -= 1
	print("Tree HP: ", tree_health[pos])
	
	if tree_health[pos] <= 0:
		# Remove tree tile
		tilemap.set_cell(pos, -1)
		tree_health.erase(pos)
		
		# Spawn wood drop
		var wood = wood_scene.instantiate()
		get_parent().add_child(wood)
		wood.global_position = tilemap.map_to_local(pos)

func collect_item(item_name: String) -> void:
	if inventory.has(item_name):
		inventory[item_name] += 1
	else:
		inventory[item_name] = 1
	
	inventory_changed.emit(inventory)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	queue_free()
