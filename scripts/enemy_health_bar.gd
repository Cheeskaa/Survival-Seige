extends Node2D

@onready var progress: TextureProgressBar = $Progress

var max_hp: float = 100.0
var current_hp: float = 100.0

func _ready() -> void:
	progress.max_value = max_hp
	progress.value = current_hp

func setup(max_health: float, current_health: float) -> void:
	max_hp = max_health
	current_hp = current_health
	progress.max_value = max_hp
	progress.value = current_hp

func take_damage(amount: float) -> void:
	current_hp -= amount
	current_hp = clamp(current_hp, 0, max_hp)
	progress.value = current_hp
