extends Area2D

var speed: float = 600.0
var damage: float = 15.0
var direction: Vector2 = Vector2.RIGHT

func setup(angle: float, arrow_speed: float, arrow_damage: float) -> void:
	speed = arrow_speed
	damage = arrow_damage
	rotation = angle
	direction = Vector2(cos(angle), sin(angle))

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Auto destroy after 3 seconds
	await get_tree().create_timer(3.0).timeout
	queue_free()
