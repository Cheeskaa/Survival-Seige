extends Node

@onready var day_label: Label = $"../DayLabel"
@onready var timer_label: Label = $"../TimerLabel"

var day_count: int = 1
var cycle_node = null

const CYCLE_DURATION = 240.0
const NIGHT_START = 0.5

func _ready() -> void:
	await get_tree().process_frame
	cycle_node = get_tree().get_first_node_in_group("day_night_cycle")
	if cycle_node == null:
		print("ERROR: day_night_cycle not found!")
		return
	# Set day count to 1 immediately on start
	day_label.text = "Day " + str(day_count)
	cycle_node.change_day_time.connect(_on_day_time_changed)

func _process(_delta: float) -> void:
	if cycle_node == null:
		return

	var t = cycle_node.time / cycle_node.cycle_duration
	var state = cycle_node.current_state

	if state == cycle_node.DAY_STATE.DAY:
		var time_left = (NIGHT_START - t) * CYCLE_DURATION
		timer_label.text = "Night in: " + _format_time(time_left)
	else:
		var time_left = (1.0 - t) * CYCLE_DURATION
		timer_label.text = "Day in: " + _format_time(time_left)

func _format_time(seconds: float) -> String:
	var secs = max(0, int(seconds))
	var mins = secs / 60
	var remaining_secs = secs % 60
	return str(mins) + ":" + "%02d" % remaining_secs

func _on_day_time_changed(state) -> void:
	# Only increment when a NEW day starts, not the first one
	if state == cycle_node.DAY_STATE.DAY:
		day_count += 1
		day_label.text = "Day " + str(day_count)
