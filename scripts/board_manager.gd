extends Node

# =========================================================
# 🔹 Board Manager — handles slot logic and outcomes
# =========================================================
@export var board_theme: String = "default"
var board_layout: Dictionary
const FINAL_SLOT_INDEX := 25

# Node references
@onready var GameHud: CanvasLayer = get_node("/root/MAIN/GameHud")
@onready var GameManager: Node = get_node("/root/MAIN/GameManager")
@onready var board_bg: TextureRect = get_node("/root/MAIN/BoardLayout")

func _ready():
	_load_board_layout(board_theme)
	EventsBus.court_selected.connect(_on_court_selected)
	EventsBus.request_goal_jump.connect(_on_request_goal_jump)

func _on_request_goal_jump(chip: Node2D) -> void:
	go_to_goal(chip, "slot_jump")

# =========================================================
# 🔹 Board Layout
# =========================================================
func _load_board_layout(theme: String):
	var layout_path = "res://Scripts/board_layout_%s.gd" % theme
	if not ResourceLoader.exists(layout_path):
		push_error("❌ Board layout file missing for theme: %s" % theme)
		board_layout = {}
		return

	var layout_script = load(layout_path)
	if layout_script:
		var layout_instance = layout_script.new()
		if "layout" in layout_instance:
			board_layout = layout_instance.layout
		else:
			push_error("❌ Layout variable missing in board layout script: %s" % theme)
			board_layout = {}
	else:
		push_error("❌ Failed to load board layout script: %s" % theme)
		board_layout = {}

func _on_court_selected(court_data: Dictionary):
	if ResourceLoader.exists(court_data["bg"]):
		board_bg.texture = load(court_data["bg"])

func set_board_layout(theme: String):
	board_theme = theme
	_load_board_layout(theme)

# =========================================================
# 🔹 Handle Chip Landing
# =========================================================
func handle_chip_landed(chip: Node2D) -> Dictionary:
	if board_layout.is_empty():
		push_error("❌ handle_chip_landed() aborted — board_layout is empty. Check _load_board_layout().")
		return {}

	var box_name = "Box_%02d" % chip.chip_current_box
	if not board_layout.has(box_name):
		push_error("❌ Slot not found in layout: " + box_name)
		return {}

	var data = board_layout[box_name]
	var result := {
		"trigger_quiz": data.get("on_land", {}).get("trigger_quiz", false),
		"extra_info": {
			"box_name": box_name,
			"type": data.get("type", "unknown"),
			"slot_data": data
		}
	}

	var on_land = data.get("on_land", {})
	if on_land.has("move_to"):
		var target_index = int(on_land["move_to"])
		if target_index != chip.chip_current_box:
			await chip.jump_to_index(target_index)
			chip.chip_current_box = target_index
			return await handle_chip_landed(chip)

	if not result.trigger_quiz:
		# No quiz, go straight to outcome
		await resolve_outcome(chip, result, true)  # Assume correct for non-quiz

	return result

# =========================================================
# 🔹 Resolve Outcome (Data-Driven)
# =========================================================
func resolve_outcome(chip: Node2D, result: Dictionary, last_is_correct: bool) -> void:
	print("📦 resolve_outcome called with is_correct =", last_is_correct)

	# 🔹 Determine which outcome dictionary to use
	var slot_data: Dictionary = result.extra_info.get("slot_data", {})
	var outcome_key := "on_land"
	if result.get("trigger_quiz", false):
		outcome_key = "on_correct" if last_is_correct else "on_wrong"

	var outcome: Dictionary = slot_data.get(outcome_key, {})

	# 🔹 Update score if needed
	if outcome.get("reset_score", false):
		chip.score = 0
		EventsBus.score_updated.emit(chip.chip_owner, chip.score)

	if outcome.has("score"):
		var delta := int(outcome["score"])
		chip.score = max(chip.score + delta, 0)
		EventsBus.score_updated.emit(chip.chip_owner, chip.score)

	# =========================================================
	# ✅ Popup logic: only fire if outcome has visual consequence or explicitly requests it
	# =========================================================
	var popup_keys = ["score", "reset_score", "return_to_start", "jump_to_goal"]
	var should_popup = outcome.get("visual_feedback", false)
	for key in popup_keys:
		if outcome.has(key):
			should_popup = true
			break

	if should_popup and result.extra_info.has("type"):
		var slot_type = result.extra_info["type"]
		var chip_position = chip.global_position
		EventsBus.show_popup.emit(slot_type, chip_position, last_is_correct)

	# =========================================================
	# 🔹 MOVEMENT & ANIMATIONS
	# =========================================================
	if outcome.get("return_to_start", false) and not outcome.get("jump_to_goal", false):
		var reason := "punish" if outcome_key == "on_wrong" else "default"
		await chip.return_to_start(reason)
		chip.chip_current_box = 0

	elif outcome.get("jump_to_goal", false):
		await _go_to_goal(chip)
		if chip:
			EventsBus.goal_scored.emit(chip.chip_owner)

	elif outcome.has("move_to"):
		var target: int = int(outcome["move_to"])
		await chip.jump_to_index(target)
		chip.chip_current_box = target

	# =========================================================
	# 🔹 Fixed extra_turn logic
	# =========================================================
	var grant_turn := false
	if outcome.get("extra_turn", false):
		if outcome_key == "on_correct":
			grant_turn = true
		elif outcome_key == "on_wrong":
			grant_turn = outcome.get("extra_turn", false)
	EventsBus.grant_extra_turn.emit(grant_turn)

	# 🔹 Update last_slot_result for GameManager
	var final_result := {
		"slot_type": result.extra_info.get("type", ""),
		"extra_turn": grant_turn,
		"is_correct": last_is_correct,
	}
	EventsBus.outcome_finished.emit(final_result)
	GameManager.last_slot_result = result


# =========================================================
# 🔹 Goal Helper
# =========================================================
func go_to_goal(chip: Node2D, reason: String = "direct") -> void:
	var goal_index := FINAL_SLOT_INDEX
	match reason:
		"direct": await chip.move_to_box(goal_index)
		"interpolate": await chip.jump_to_index(goal_index)
		"bounce": await chip.move_to_overshoot(goal_index)

	chip.chip_current_box = goal_index
	await chip.return_to_start()

# =========================================================
# 🔹 Movement Helpers
# =========================================================
func get_final_slot_index() -> int:
	return FINAL_SLOT_INDEX

func move_chip_by(chip: Node2D, steps: int) -> void:
	var target_index = clamp(chip.chip_current_box + steps, 0, FINAL_SLOT_INDEX)
	await chip.move_to_index(target_index)
	chip.chip_current_box = target_index

func get_box_position(index: int) -> Vector2:
	var box_path = "/root/MAIN/BoardLayout/Box_%02d" % index
	var box_node = get_node_or_null(box_path)
	if box_node:
		return box_node.global_position
	else:
		push_error("❌ Could not find visual box node: %s" % box_path)
		return Vector2.ZERO

func _go_to_goal(chip: Node2D, reason: String = "direct") -> void:
	var goal_index := FINAL_SLOT_INDEX
	match reason:
		"direct": await chip.move_to_box(goal_index)
		"interpolate": await chip.jump_to_index(goal_index)
		"bounce": await chip.move_to_overshoot(goal_index)

	chip.chip_current_box = goal_index
	await chip.return_to_start()
