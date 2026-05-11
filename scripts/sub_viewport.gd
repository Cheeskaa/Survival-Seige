extends SubViewport

@onready var player: CharacterBody2D = $"../../../player"

@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	world_2d = get_tree().root.world_2d

func _physics_process(_delta: float) -> void:
	$Camera2D.position = player.position
