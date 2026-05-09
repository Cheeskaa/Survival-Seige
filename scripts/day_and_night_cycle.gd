extends CanvasModulate

signal change_day_time(state)
enum DAY_STATE { DAY, SUNSET, NIGHT, SUNRISE }
var time := 0.0
var cycle_duration := 300.0
var current_state := DAY_STATE.DAY
var light_energy: float = 0.0  # ← added

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
		return DAY_STATE.DAY
	elif t < 0.5:
		return DAY_STATE.SUNRISE
	elif t < 0.9:
		return DAY_STATE.NIGHT
	else:
		return DAY_STATE.SUNRISE

func update_lighting(t):
	var brightness: float
	if t < 0.4:
		brightness = 1.0
		light_energy = 0.0          # ← day, light off
	elif t < 0.5:
		var sunset_t = (t - 0.4) / 0.1
		brightness = lerp(1.0, 0.2, sunset_t)
		light_energy = sunset_t     # ← 0 to 1 as sun sets
	elif t < 0.9:
		brightness = 0.2
		light_energy = 1.0          # ← full night, light fully on
	else:
		var sunrise_t = (t - 0.9) / 0.1
		brightness = lerp(0.2, 1.0, sunrise_t)
		light_energy = 1.0 - sunrise_t  # ← 1 to 0 as sun rises
	color = Color(brightness, brightness * 0.9, brightness * 0.8)

func _ready() -> void:
	add_to_group("day_night_cycle")
