extends Area2D

var speed: float = 500.0
var damage: float = 20.0
var direction: Vector2 = Vector2.RIGHT

func setup(angle: float, proj_speed: float, proj_damage: float) -> void:
	speed = proj_speed
	damage = proj_damage
	rotation = angle
	direction = Vector2(cos(angle), sin(angle))
	$AnimatedSprite2D.play("magic")

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(3.0).timeout
	queue_free()
