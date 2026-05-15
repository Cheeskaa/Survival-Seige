extends CanvasModulate

signal change_day_time(state)

enum DAY_STATE { DAY, NIGHT }

var time := 0.0
var cycle_duration := 240.0  # 4 min total (2 min day + 2 min night)
var current_state := DAY_STATE.DAY

func _ready() -> void:
	add_to_group("day_night_cycle")
	color = Color(1, 1, 1, 1)

func _process(delta: float) -> void:
	time = fmod(time + delta, cycle_duration)
	var t = time / cycle_duration
	update_lighting(t)
	var new_state = get_day_state(t)
	if new_state != current_state:
		current_state = new_state
		change_day_time.emit(current_state)

func get_day_state(t: float) -> DAY_STATE:
	if t < 0.5:
		return DAY_STATE.DAY    # 0:00 - 2:00
	else:
		return DAY_STATE.NIGHT  # 2:00 - 4:00

func update_lighting(t: float) -> void:
	var brightness: float
	if t < 0.4:
		brightness = 1.0           # full day
	elif t < 0.5:
		var fade_t = (t - 0.4) / 0.1
		brightness = lerp(1.0, 0.2, fade_t)  # quick fade to night
	elif t < 0.9:
		brightness = 0.2           # full night
	else:
		var fade_t = (t - 0.9) / 0.1
		brightness = lerp(0.2, 1.0, fade_t)  # quick fade to day
	color = Color(brightness, brightness * 0.9, brightness * 0.8)
