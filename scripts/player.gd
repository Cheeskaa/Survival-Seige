extends CharacterBody2D

# --- Node Variables (Assigned Safely in _ready) ---
var player_health_ui: Node2D = null
var tilemap: TileMapLayer = null

@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound
@onready var flashlight_sound: AudioStreamPlayer2D = $FlashlightSound
@onready var wood_scene = preload("res://scenes/wood_drop.tscn")
@onready var hurtbox: Area2D = $Hurtbox
@onready var weapon_manager: Node2D = $WeaponManager

# --- Stats ---
@export var speed: float = 400.0
@export var tree_respawn_time: float = 30.0
@export var attack_damage: float = 10.0
@export var max_health: float = 100.0

# --- State Variables ---
var health: float = 100.0
var tree_health: Dictionary = {}
var is_dead: bool = false
var is_attacking: bool = false
var cycle = null
var last_direction: String = "down"
var knockback_velocity: Vector2 = Vector2.ZERO
var is_hurt: bool = false
var hotbar_items: Array = []
var selected_slot: int = 0

var inventory: Dictionary = {}
signal inventory_changed(new_inventory: Dictionary)

func _ready() -> void:
	add_to_group("player")
	
	# SAFE NODE FETCHING: Prevents crashes on map changes
	player_health_ui = get_node_or_null("../CanvasLayer/PlayerHealthUI")
	
	if get_parent() and get_parent().has_node("props"):
		tilemap = get_parent().get_node("props")

	if point_light_2d:
		point_light_2d.enabled = false
		point_light_2d.energy = 1.0
		
	attack_hitbox.monitoring = false
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	await get_tree().process_frame
	inventory["BigSword"] = 1
	inventory["Bow"] = 1
	weapon_manager.equip_weapon("BigSword")
	# SAFE DAY/NIGHT CYCLE FINDING
	if is_inside_tree() and get_tree() != null:
		cycle = get_tree().get_first_node_in_group("day_night_cycle")
		if cycle != null:
			cycle.change_day_time.connect(_on_day_time_changed)
			_on_day_time_changed(cycle.current_state)
		else:
			print("Notice: day_night_cycle node not present in this map.")

func _on_day_time_changed(state) -> void:
	if point_light_2d and cycle:
		point_light_2d.enabled = (state == cycle.DAY_STATE.NIGHT)

func sync_ui_to_inventory(new_ui_data: Dictionary):
	inventory = new_ui_data
	inventory_changed.emit(inventory)

func _physics_process(_delta: float) -> void:
	if is_dead: return

	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.2)
		if knockback_velocity.length() < 5:
			knockback_velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var direction = Vector2.ZERO
	if Input.is_action_pressed("walk_right"): direction.x += 1
	if Input.is_action_pressed("walk_left"): direction.x -= 1
	if Input.is_action_pressed("walk_down"): direction.y += 1
	if Input.is_action_pressed("walk_up"): direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()
	_update_animation(direction)

func _unhandled_input(event: InputEvent) -> void:
	for i in range(1, 6):
		if event.is_action_pressed("slot_" + str(i)):
			_select_slot(i - 1)
	
	if event.is_action_pressed("attack"):
		if weapon_manager.current_weapon != null:
			weapon_manager.attack()
		else:
			attack()

func _select_slot(index: int) -> void:
	selected_slot = index
	var items = inventory.keys()
	if index < items.size():
		var item = items[index]
		weapon_manager.equip_weapon(item)
	else:
		weapon_manager.unequip()
	inventory_changed.emit(inventory)

func toggle_flashlight() -> void:
	if point_light_2d:
		point_light_2d.enabled = !point_light_2d.enabled
		if flashlight_sound: flashlight_sound.play()

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
	if attack_sound:
		attack_sound.pitch_scale = randf_range(0.9, 1.1)
		attack_sound.play()
	$AnimatedSprite2D.play("attack_" + last_direction)
	
	_check_for_ores()
	_check_for_trees()
	
	await get_tree().create_timer(0.1).timeout
	attack_hitbox.monitoring = true
	var frames = $AnimatedSprite2D.sprite_frames
	var anim_name = "attack_" + last_direction
	var duration = (frames.get_frame_count(anim_name) / frames.get_animation_speed(anim_name)) - 0.1
	await get_tree().create_timer(duration).timeout
	attack_hitbox.monitoring = false
	is_attacking = false

func _check_for_ores() -> void:
	var reach = 50.0 
	var offset = Vector2.ZERO
	if last_direction == "down": offset.y = reach
	elif last_direction == "up": offset.y = -reach
	elif last_direction == "right": offset.x = reach
	elif last_direction == "left": offset.x = -reach
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position + offset
	query.collision_mask = 1 
	
	var results = space_state.intersect_point(query)
	for result in results:
		var hit_obj = result.collider
		if hit_obj.has_method("hit"):
			hit_obj.hit()
			return

func take_damage(amount: float) -> void:
	if is_dead or is_hurt: return
	health -= amount
	health = clamp(health, 0.0, max_health)
	print("Player took damage: ", amount, " | HP remaining: ", health)
	
	if player_health_ui:
		player_health_ui.take_damage(int(amount))
		
	_play_hurt()
	if health <= 0: die()

func _play_hurt() -> void:
	is_hurt = true
	for i in range(3):
		$AnimatedSprite2D.modulate = Color(1, 0, 0, 1)
		await get_tree().create_timer(0.1).timeout
		$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
		await get_tree().create_timer(0.1).timeout
	is_hurt = false

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_hitbox"):
		var damage = area.get_parent().attack_damage if area.get_parent().get("attack_damage") != null else 10.0
		take_damage(damage)
		var knockback_dir = (global_position - area.get_parent().global_position).normalized()
		knockback_velocity = knockback_dir * 300.0

func _check_for_trees_with_axe(hits_required: int) -> void:
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
		_damage_tree_with_hits(map_pos, hits_required)

func _damage_tree_with_hits(pos: Vector2i, hits_required: int) -> void:
	if not tilemap: return
	if not tree_health.has(pos):
		tree_health[pos] = hits_required
	tree_health[pos] -= 1
	if tree_health[pos] <= 0:
		tilemap.set_cell(pos, -1)
		tree_health.erase(pos)
		var wood = wood_scene.instantiate()
		get_parent().add_child(wood)
		wood.global_position = tilemap.to_global(tilemap.map_to_local(pos))
		_respawn_tree(pos)

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
	if not tilemap: return
	if not tree_health.has(pos): 
		tree_health[pos] = 5 
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

func die() -> void:
	if is_dead: return
	is_dead = true
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
	$AnimatedSprite2D.play("die")
	await $AnimatedSprite2D.animation_finished
	queue_free()
