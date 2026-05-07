extends Control

@onready var top_lid = $TopLid
@onready var bottom_lid = $BottomLid
@onready var label = $Label
@onready var anim_player = $AnimationPlayer
@onready var sfx_player = $AudioStreamPlayer
var is_blinking = false
var story_finished = false
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	top_lid.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	bottom_lid.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	top_lid.size.y = size.y / 2
	bottom_lid.size.y = size.y / 2
	top_lid.position = Vector2(0, 0)
	bottom_lid.position = Vector2(0, size.y / 2)
	label.z_index = 10

	if anim_player.has_animation("WakeUp"):
		anim_player.play("WakeUp")
		# When WakeUp animation finishes, end the story
		anim_player.animation_finished.connect(_on_animation_finished)

	start_struggle_loop()

func _on_animation_finished(anim_name: String):
	if anim_name == "WakeUp":
		story_finished = true
		start_gameplay()

func start_struggle_loop():
	while not story_finished:
		var wait_time = rng.randf_range(0.8, 3.5)
		await get_tree().create_timer(wait_time).timeout
		if story_finished:
			break
		var blink_type = rng.randi_range(0, 2)
		match blink_type:
			0: await play_flutter()
			1: await play_struggle_open(40, 15, 0.4)
			2: await play_struggle_open(110, 30, 1.2)

func play_flutter():
	is_blinking = true
	var tween = create_tween().set_parallel(true)
	tween.tween_property(top_lid, "position:y", -15, 0.08).set_trans(Tween.TRANS_SINE)
	tween.tween_property(bottom_lid, "position:y", (size.y / 2) + 5, 0.08).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(0.1).timeout
	var close = create_tween().set_parallel(true)
	close.tween_property(top_lid, "position:y", 0, 0.05)
	close.tween_property(bottom_lid, "position:y", size.y / 2, 0.05)
	is_blinking = false

func play_struggle_open(top_dist, bot_dist, duration):
	is_blinking = true
	var tween = create_tween().set_parallel(true)
	tween.tween_property(top_lid, "position:y", -top_dist, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(bottom_lid, "position:y", (size.y / 2) + bot_dist, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(duration * 0.5).timeout
	var close = create_tween().set_parallel(true)
	close.tween_property(top_lid, "position:y", 0, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	close.tween_property(bottom_lid, "position:y", size.y / 2, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await close.finished
	is_blinking = false

func start_gameplay():
	get_tree().change_scene_to_file("res://scenes/test_map.tscn")
