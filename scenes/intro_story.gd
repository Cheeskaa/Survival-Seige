extends Control

@onready var top_lid = $TopLid
@onready var bottom_lid = $BottomLid
@onready var label = $Label
@onready var anim_player = $AnimationPlayer
@onready var sfx_player = $AudioStreamPlayer # Rename your node to this
var is_blinking = false
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
	# 1. FORCE INITIAL STATE (Total Blackout)
	top_lid.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	bottom_lid.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	top_lid.size.y = size.y / 2
	bottom_lid.size.y = size.y / 2
	top_lid.position = Vector2(0, 0)
	bottom_lid.position = Vector2(0, size.y / 2)
	
	label.z_index = 10 # Keep text on top
	
	if anim_player.has_animation("WakeUp"):
		anim_player.play("WakeUp")
	
	# Start the irregular blinking loop
	start_struggle_loop()

func start_struggle_loop():
	# Loop continues until the scene changes to gameplay
	while true:
		# Random delay between blinks (0.8s to 3.5s)
		var wait_time = rng.randf_range(0.8, 3.5)
		await get_tree().create_timer(wait_time).timeout
		
		# Pick a random "blink strength"
		# 0 = Micro-flutter (barely opens)
		# 1 = Half-glance (struggling)
		# 2 = Wide-stare (then exhaustion hits)
		var blink_type = rng.randi_range(0, 2)
		
		match blink_type:
			0: await play_flutter()
			1: await play_struggle_open(40, 15, 0.4)
			2: await play_struggle_open(110, 30, 1.2)

func play_flutter():
	is_blinking = true
	var tween = create_tween().set_parallel(true)
	# Very quick, shallow twitch
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
	
	# Open slowly as if the lids are heavy (TRANS_SINE)
	tween.tween_property(top_lid, "position:y", -top_dist, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(bottom_lid, "position:y", (size.y / 2) + bot_dist, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Hold the eyes open for a moment of "realization"
	await get_tree().create_timer(duration * 0.5).timeout
	
	var close = create_tween().set_parallel(true)
	# Snap shut fast from exhaustion (TRANS_EXPO)
	close.tween_property(top_lid, "position:y", 0, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	close.tween_property(bottom_lid, "position:y", size.y / 2, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	await close.finished
	is_blinking = false

func start_gameplay():
	get_tree().change_scene_to_file("res://scenes/testscene2.tscn")
