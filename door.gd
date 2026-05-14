extends Area2D

class_name Door

@export var destination_level_tag: String
@export var destination_door: String
@export var spawn_direction: String = "up" 

@onready var spawn: Marker2D = $Spawn

func _on_body_entered(body: Node2D) -> void:
	# Instead of checking for a specific 'Player' class, 
	# we check if the body belongs to the 'player' group.
	if body.is_in_group("player"):
		teleport_player(body)

func teleport_player(_player: Node2D) -> void:
	# Logic for level switching goes here
	pass
