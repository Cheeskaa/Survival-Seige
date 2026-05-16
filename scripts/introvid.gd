extends Node

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var skip_button: Button = $CanvasLayer/Button
# Renamed for clarity:
@onready var background_music: AudioStreamPlayer2D = $background 

func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)
	video_player.finished.connect(_on_video_finished)
	
	# Start the music when the cutscene starts
	if background_music:
		background_music.play()

func _on_skip_pressed() -> void:
	_go_to_next_scene()

func _on_video_finished() -> void:
	_go_to_next_scene()

func _go_to_next_scene() -> void:
	# Stop the music before leaving the scene (optional but good practice)
	if background_music:
		background_music.stop()
		
	get_tree().change_scene_to_file("res://scenes/World.tscn")
