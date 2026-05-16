extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/Options
@onready var exit_button = $VBoxContainer/Exit

func _ready():
	start_button.pressed.connect(_on_start)
	options_button.pressed.connect(_on_options)
	exit_button.pressed.connect(_on_exit)

func _on_start():
	get_tree().change_scene_to_file("res://scenes/introvid.tscn")  

func _on_options():
	var options_scene = load("res://scenes/options.tscn") 
	if options_scene:
		var options_instance = options_scene.instantiate()
		add_child(options_instance) # Spawns cleanly in front

func _on_exit():
	get_tree().quit()
