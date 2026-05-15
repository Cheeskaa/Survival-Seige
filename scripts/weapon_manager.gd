extends Node2D

# Preload all weapon scenes
const WEAPON_SCENES = {
	"BigSword": preload("res://scenes/BigSword.tscn"),
	"Lance": preload("res://scenes/lance.tscn"),
	"Stick": preload("res://scenes/stick.tscn"),
	"AxeTool": preload("res://scenes/axe_tool.tscn"),
	"Bow": preload("res://scenes/bow.tscn"),
	"MagicWand": preload("res://scenes/magic_wand.tscn")
}

var current_weapon = null
var current_weapon_name: String = ""

func equip_weapon(weapon_name: String) -> void:
	# Remove current weapon
	if current_weapon != null:
		current_weapon.queue_free()
		current_weapon = null
	
	# Equip new weapon if valid
	if WEAPON_SCENES.has(weapon_name):
		current_weapon = WEAPON_SCENES[weapon_name].instantiate()
		get_parent().add_child(current_weapon)
		current_weapon.position = Vector2(16, 0)
		current_weapon_name = weapon_name
		print("Equipped: ", weapon_name)
	else:
		print("No weapon: ", weapon_name)

func unequip() -> void:
	if current_weapon != null:
		current_weapon.queue_free()
		current_weapon = null
		current_weapon_name = ""

func attack() -> void:
	if current_weapon != null:
		current_weapon.try_attack()
