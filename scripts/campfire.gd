extends Area2D

@export var max_health: float = 100.0
@export var regen_rate: float = 3.0       # HP per second
@export var regen_delay: float = 3.0      # seconds after last hit before regen

var health: float = 100.0
var time_since_last_hit: float = 0.0
var is_dead: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_light: PointLight2D = $PointLight2D
@onready var health_bar = $EnemyHealthBar

func _ready() -> void:
	add_to_group("campfire")
	animated_sprite.play("burn")
	health_bar.setup(max_health, health)
	
	# Light flicker effect
	point_light.enabled = true

func _process(delta: float) -> void:
	if is_dead:
		return
	
	# Count time since last hit
	time_since_last_hit += delta
	
	# Regenerate health after delay
	if time_since_last_hit >= regen_delay and health < max_health:
		health += regen_rate * delta
		health = clamp(health, 0.0, max_health)
		health_bar.setup(max_health, health)
	
	# Flicker light slightly
	point_light.energy = 1.5 + sin(Time.get_ticks_msec() * 0.005) * 0.2

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	health = clamp(health, 0.0, max_health)
	time_since_last_hit = 0.0  # reset regen timer
	health_bar.take_damage(amount)
	print("Campfire HP: ", health)
	
	if health <= 0:
		_die()

func _die() -> void:
	is_dead = true
	point_light.enabled = false
	animated_sprite.stop()
	print("CAMPFIRE DESTROYED - GAME OVER")
	# We will add game over popup later
	var days = 1
	var day_ui = get_tree().get_first_node_in_group("day_night_ui")
	if day_ui:
		days = day_ui.day_count
	
	# Show game over screen
	await get_tree().process_frame
	get_tree().paused = true
	
	var game_over = get_tree().get_first_node_in_group("game_over_screen")
	if game_over:
		game_over.visible = true
		game_over.setup(days)
