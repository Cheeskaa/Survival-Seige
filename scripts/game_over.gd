extends Control

@onready var title_label: Label = $NinePatchRect/VBoxContainer/TitleLabel
@onready var days_label: Label = $NinePatchRect/VBoxContainer/DaysLabel
@onready var high_score_label: Label = $NinePatchRect/VBoxContainer/HighScoreLabel
@onready var restart_button: Button = $NinePatchRect/VBoxContainer/RestartButton
@onready var quit_button: Button = $NinePatchRect/VBoxContainer/QuitButton

const SAVE_FILE = "user://save_data.cfg"

func _ready() -> void:
	restart_button.pressed.connect(_on_restart)
	quit_button.pressed.connect(_on_quit)

func setup(days_survived: int) -> void:
	days_label.text = "Days Survived: " + str(days_survived)
	
	# Load and update high score
	var best = _load_high_score()
	if days_survived > best:
		best = days_survived
		_save_high_score(best)
		high_score_label.text = "New Best: " + str(best) + " days!"
	else:
		high_score_label.text = "Best: " + str(best) + " days"

func _load_high_score() -> int:
	var config = ConfigFile.new()
	var err = config.load(SAVE_FILE)
	if err != OK:
		return 0
	return config.get_value("scores", "best_days", 0)

func _save_high_score(days: int) -> void:
	var config = ConfigFile.new()
	config.set_value("scores", "best_days", days)
	config.save(SAVE_FILE)

func _on_restart() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/test_map.tscn")

func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start_menu.tscn")
