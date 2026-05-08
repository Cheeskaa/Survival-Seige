extends Node2D

func _on_video_stream_player_finished():
	start_gameplay()

func start_gameplay():
	get_tree().change_scene_to_file("res://scenes/test_map.tscn")

func _input(event):
	if event.is_action_pressed("ui_accept"): # "ui_accept" is usually Space or Enter
		start_gameplay()
