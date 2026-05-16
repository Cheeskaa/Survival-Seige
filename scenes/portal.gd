extends Area2D

@export_file("*.tscn") var target_map_path: String # Select map file via Inspector
@export var target_portal_name: String = ""       # Marker2D name on target map

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if target_map_path != "":
			# FIX: Defer the travel action to safely exit physics tracking loops
			SceneManager.call_deferred("travel_to", target_map_path, target_portal_name)
