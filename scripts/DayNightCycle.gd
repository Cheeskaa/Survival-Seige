extends CanvasModulate

@export var day_duration: float = 60.0
@export var day_color: Color = Color(1, 1, 1, 1)
@export var night_color: Color = Color(0.0, 0.226, 0.267, 1.0)

var time: float = 0.0

func _process(delta: float) -> void:
	time += delta
	var t = fmod(time, day_duration) / day_duration  # 0.0 to 1.0

	if t < 0.5:
		color = day_color
	else:
		var night_t = (t - 0.5) / 0.5
		color = day_color.lerp(night_color, night_t)
