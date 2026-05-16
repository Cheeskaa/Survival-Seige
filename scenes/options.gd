extends Control

@onready var volume_slider: HSlider = $NinePatchRect/VBoxContainer/HSlider
@onready var mute_button: CheckBox = $NinePatchRect/VBoxContainer/CheckBox
@onready var x_button: TextureRect = $TextureRect

var master_bus_index: int

func _ready() -> void:
	# 1. System Overrides (Pause & Ordering)
	process_mode = PROCESS_MODE_ALWAYS
	top_level = true
	z_index = 100 
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	# FIX: Force UI containers to let mouse clicks pass through to the slider and buttons!
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	$NinePatchRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$NinePatchRect/VBoxContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Enable mouse clicks specifically for the X button image
	x_button.mouse_filter = Control.MOUSE_FILTER_STOP

	# 2. Setup Audio Config
	master_bus_index = AudioServer.get_bus_index("Master")
	
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01 # Smoother sliding
	
	# 3. Sync UI to Current Audio State
	var current_vol = db_to_linear(AudioServer.get_bus_volume_db(master_bus_index))
	volume_slider.value = current_vol
	mute_button.button_pressed = AudioServer.is_bus_mute(master_bus_index)
	
	# 4. Connect Signals via Code
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	mute_button.toggled.connect(_on_mute_button_toggled)
	x_button.gui_input.connect(_on_x_button_gui_input)

# Close Menu on Click
func _on_x_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			queue_free()

# Handle Slider Volume Change
func _on_volume_slider_value_changed(value: float) -> void:
	# Convert slider scale (0.0 to 1.0) to audio Decibels safely
	var db_volume = linear_to_db(value)
	AudioServer.set_bus_volume_db(master_bus_index, db_volume)
	
	# Automatically unmute if player drags the slider up
	if value > 0.01 and AudioServer.is_bus_mute(master_bus_index):
		AudioServer.set_bus_mute(master_bus_index, false)
		mute_button.button_pressed = false

# Handle Mute Checkbox Toggled
func _on_mute_button_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(master_bus_index, toggled_on)
