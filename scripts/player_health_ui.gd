extends Node2D

const MAX_HP = 100
var current_hp = MAX_HP

@onready var hearts = [
	$Heart1,
	$Heart2,
	$Heart3,
	$Heart4,
	$Heart5
]

const FRAME_EMPTY         = 0
const FRAME_QUARTER       = 16
const FRAME_HALF          = 32
const FRAME_THREE_QUARTER = 48
const FRAME_FULL          = 64

const HP_PER_HEART = 20
const HP_PER_STAGE = 5

func _ready() -> void:
	update_hearts()

func update_hearts() -> void:
	for i in range(hearts.size()):
		var heart_index = (hearts.size() - 1) - i
		var hp_min = heart_index * HP_PER_HEART
		var heart_hp = clamp(current_hp - hp_min, 0, HP_PER_HEART)

		var x_offset = FRAME_EMPTY
		if heart_hp >= HP_PER_HEART:
			x_offset = FRAME_FULL
		elif heart_hp >= HP_PER_HEART * 0.75:
			x_offset = FRAME_THREE_QUARTER
		elif heart_hp >= HP_PER_HEART * 0.5:
			x_offset = FRAME_HALF
		elif heart_hp > 0:
			x_offset = FRAME_QUARTER
		else:
			x_offset = FRAME_EMPTY

		hearts[i].region_rect = Rect2(x_offset, 0, 16, 16)

func take_damage(amount: int) -> void:
	current_hp -= amount
	current_hp = clamp(current_hp, 0, MAX_HP)
	update_hearts()
	if current_hp <= 0:
		get_tree().get_first_node_in_group("player").die()

func heal(amount: int) -> void:
	current_hp += amount
	current_hp = clamp(current_hp, 0, MAX_HP)
	update_hearts()
