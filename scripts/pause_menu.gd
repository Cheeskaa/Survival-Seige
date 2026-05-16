extends Control

@onready var resume_button = $NinePatchRect/VBoxContainer/ResumeButton
@onready var options_button = $NinePatchRect/VBoxContainer/Options
@onready var exit_button = $NinePatchRect/VBoxContainer/ExitButton

func _ready():
	resume_button.pressed.connect(_on_resume)
	options_button.pressed.connect(_on_options)
	exit_button.pressed.connect(_on_exit)

func _on_resume():
	get_parent().resume()

func _on_options():
	var options_scene = load("res://scenes/options.tscn") 
	if options_scene:
		var options_instance = options_scene.instantiate()
		add_child(options_instance) # Spawns cleanly in front

func _on_exit():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
