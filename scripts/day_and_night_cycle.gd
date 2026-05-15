extends CanvasModulate

signal change_day_time(state)
enum DAY_STATE { DAY, SUNSET, NIGHT, SUNRISE }

# Hardcode state and energy so other scripts don't break
var current_state := DAY_STATE.NIGHT
var light_energy: float = 1.0 

func _ready() -> void:
	add_to_group("day_night_cycle")
	
	# Set the permanent dark color
	# 0.2 brightness matches your original 'NIGHT' logic
	var brightness: float = 0.2
	color = Color(brightness, brightness * 0.9, brightness * 0.8)
	
	# Emit the signal once so listeners know it is Night
	change_day_time.emit(current_state)

# Leave _process empty so the time never changes
func _process(_delta):
	pass
