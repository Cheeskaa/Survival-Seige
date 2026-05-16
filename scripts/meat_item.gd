extends Node2D

const MEAT_TEXTURE = preload("res://sprites/materials/Meat/Meat Resource/Meat Resource.png")

@export var heal_amount: float = 20.0

@onready var sprite: Sprite2D = $Sprite2D

var player = null

func _ready() -> void:
	player = get_parent()
	if sprite:
		sprite.texture = MEAT_TEXTURE
		sprite.position = Vector2(12, 0)

func try_eat() -> void:
	if player == null:
		return
	if not player.inventory.has("Raw Meat"):
		return
	if player.inventory["Raw Meat"] <= 0:
		return
	if player.health >= player.max_health:
		print("Already at full health!")
		return
	_eat()

func _eat() -> void:
	# Remove 1 meat from inventory
	player.inventory["Raw Meat"] -= 1
	if player.inventory["Raw Meat"] <= 0:
		player.inventory.erase("Raw Meat")
		# Unequip since no more meat
		player.weapon_manager.unequip()

	# Heal player
	player.health = clamp(player.health + heal_amount, 0.0, player.max_health)
	print("Player ate Raw Meat! HP: ", player.health)

	# Update health UI
	if player.player_health_ui:
		player.player_health_ui.heal(int(heal_amount))

	# Emit inventory changed to update hotbar
	player.inventory_changed.emit(player.inventory)

	# Eating animation — flash green
	if player.has_node("AnimatedSprite2D"):
		player.get_node("AnimatedSprite2D").modulate = Color(0.5, 1.0, 0.5, 1)
		await get_tree().create_timer(0.3).timeout
		player.get_node("AnimatedSprite2D").modulate = Color(1, 1, 1, 1)
