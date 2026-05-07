extends Control

@onready var resume_button = $NinePatchRect/VBoxContainer/ResumeButton
@onready var exit_button = $NinePatchRect/VBoxContainer/ExitButton

func _ready():
	resume_button.pressed.connect(_on_resume)
	exit_button.pressed.connect(_on_exit)

func _on_resume():
	get_parent().resume()

func _on_exit():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")  # change to your actual path
