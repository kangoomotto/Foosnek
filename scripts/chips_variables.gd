extends Sprite2D

var chip_current_box: int = 0
var score: int = 0
var chip_owner: int = 0   # 0 = Player 1, 1 = Player 2
var score_sudden_death: int = 0
var team_name: String = ""
var team_shield: Texture

@onready var board_manager = get_node("/root/MAIN/BoardManager")
signal move_finished

# =========================================================
# 🔹 MOVE CHIP
# =========================================================
func move_to_index(target_index: int, duration := 0.3) -> void:
	while chip_current_box < target_index:
		chip_current_box += 1
		await move_to_box(chip_current_box, duration)
	while chip_current_box > target_index:
		chip_current_box -= 1
		await move_to_box(chip_current_box, duration)

func move_to_box(index: int, duration := 0.3) -> void:
	var target_position = board_manager.get_box_position(index)
	var tween := create_tween()
	tween.tween_property(self, "position", target_position, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func jump_to_index(index: int) -> void:
	var target_pos = board_manager.get_box_position(index)
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	chip_current_box = index
	move_finished.emit()
# =========================================================
# 🔹 RETURN TO START
# =========================================================
func return_to_start(reason := "default") -> void:
	if reason == "punish":
		for i in range(chip_current_box - 1, -1, -1):
			await move_to_index(i, 0.1)  # fast hop
	else:
		await jump_to_index(0)  # smooth jump
	chip_current_box = 0
	move_finished.emit()
