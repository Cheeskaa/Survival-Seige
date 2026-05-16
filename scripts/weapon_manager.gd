extends Node2D

const WEAPON_SCENES = {
	"BigSword": preload("res://scenes/BigSword.tscn"),
	"Lance": preload("res://scenes/lance.tscn"),
	"Stick": preload("res://scenes/stick.tscn"),
	"AxeTool": preload("res://scenes/axe_tool.tscn"),
	"Bow": preload("res://scenes/bow.tscn"),
	"MagicWand": preload("res://scenes/magic_wand.tscn"),
	"Raw Meat": preload("res://scenes/meat_item.tscn")
}

const CONSUMABLES = ["Raw Meat"]

var current_weapon = null
var current_weapon_name: String = ""

func equip_weapon(weapon_name: String) -> void:
	if current_weapon != null:
		current_weapon.queue_free()
		current_weapon = null

	if WEAPON_SCENES.has(weapon_name):
		current_weapon = WEAPON_SCENES[weapon_name].instantiate()
		# Add as child of PLAYER not weapon manager
		get_parent().add_child(current_weapon)
		# Center on player
		current_weapon.position = Vector2.ZERO
		current_weapon_name = weapon_name
		print("Equipped: ", weapon_name)
	else:
		print("No weapon scene for: ", weapon_name)

func unequip() -> void:
	if current_weapon != null:
		current_weapon.queue_free()
		current_weapon = null
		current_weapon_name = ""

func attack() -> void:
	if current_weapon == null:
		return
	# If consumable, use it instead of attacking
	if current_weapon_name in CONSUMABLES:
		if current_weapon.has_method("try_eat"):
			current_weapon.try_eat()
	else:
		current_weapon.try_attack()

func is_consumable() -> bool:
	return current_weapon_name in CONSUMABLES
