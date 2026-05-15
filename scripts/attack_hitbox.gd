extends Area2D

func _ready() -> void:
	monitoring = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			var damage = get_parent().attack_damage \
				if get_parent().get("attack_damage") != null else 10.0
			body.take_damage(damage)
