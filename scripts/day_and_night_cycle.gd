extends CanvasModulate

signal change_day_time(state)

enum DAY_STATE { DAY, SUNSET, NIGHT, SUNRISE }

var time := 0.0
var cycle_duration :=300.0
var current_state := DAY_STATE.DAY

func _process(delta):
	time = fmod(time + delta, cycle_duration)
	var t = time / cycle_duration

	update_lighting(t)

	var new_state = get_day_state(t)
	if new_state != current_state:
		current_state = new_state
		change_day_time.emit(current_state)

func get_day_state(t: float) -> DAY_STATE:
	if t < 0.4:
		return DAY_STATE.DAY        # 0:00 - 2:00 (2 minutes)
	elif t < 0.5:
		return DAY_STATE.SUNRISE     # 2:00 - 2:30 (30 seconds)
	elif t < 0.9:
		return DAY_STATE.NIGHT      # 2:30 - 4:30 (2 minutes)
	else:
		return DAY_STATE.SUNRISE    # 4:30 - 5:00 (30 seconds)

func update_lighting(t):
	var brightness: float

	if t < 0.4:
		brightness = 1.0
	elif t < 0.5:
		var sunset_t = (t - 0.4) / 0.1
		brightness = lerp(1.0, 0.2, sunset_t)
	elif t < 0.9:
		brightness = 0.2
	else:
		var sunrise_t = (t - 0.9) / 0.1
		brightness = lerp(0.2, 1.0, sunrise_t)

	color = Color(
		brightness,
		brightness * 0.9,
		brightness * 0.8
	)

func _ready() -> void:
	add_to_group("day_night_cycle")
