extends Node

# =========================================================
# 🔹 CONSTANTS & STATES
# =========================================================
const GameState = preload("res://Scripts/game_state.gd").GameState

# =========================================================
# 🔹 VARIABLES
# =========================================================
var game_mode: String = "cpu"
var current_state: int = GameState.START_MENU
var current_turn: int = 0
var current_chip: Node2D
var last_slot_result: Dictionary = {}
var selecting_player_index: int = 0
var selected_team_id_p1: String
var selected_team_id_p2: String
var chips: Array[Node2D] = []
var timer_started: bool = false

# =========================================================
# 🔹 NODE REFERENCES
# =========================================================
@onready var board_manager: Node = get_node("/root/MAIN/BoardManager")

# =========================================================
# 🔹 DEBUG
# =========================================================
@export var DEBUG_MODE: bool = true
@export var debug_score_p1: int = 0
@export var debug_score_p2: int = 0
@export var debug_force_dice: int = 0

# Tracks whether we are waiting for a blocking popup to end
var waiting_for_blocking_popup: bool = false

# =========================================================
# 🔹 READY — INITIAL SETUP
# =========================================================
func _ready():
	chips = [
		get_node("/root/MAIN/playerChipPink"),
		get_node("/root/MAIN/playerChipBlue")
	]
	chips[0].chip_owner = 0
	chips[1].chip_owner = 1
	current_chip = chips[current_turn]

	_initialize_teams_and_court()
	_initialize_team_signals()

	EventsBus.start_pressed.connect(_on_start_pressed)
	EventsBus.request_dice_roll.connect(_on_request_dice_roll)
	EventsBus.dice_roll_started.connect(_on_dice_roll_started)
	EventsBus.dice_rolled.connect(_on_dice_rolled)
	EventsBus.quiz_completed.connect(_on_quiz_completed)
	EventsBus.goal_scored.connect(_on_popup_animation_done)
	EventsBus.winner_declared.connect(_on_winner_declared)
	EventsBus.main_menu.connect(_on_main_menu)

	EventsBus.halftime_reached.connect(_on_halftime_reached)
	EventsBus.halftime_closed.connect(_on_halftime_closed)
	EventsBus.match_ended.connect(_on_match_ended)
	EventsBus.play_again_requested.connect(_on_play_again_pressed)
	EventsBus.popup_animation_done.connect(_on_popup_animation_done)
	EventsBus.grant_extra_turn.connect(_on_grant_extra_turn)

	_change_state(GameState.START_MENU)
	_highlight_active_player(current_turn)

func _on_grant_extra_turn(extra: bool) -> void:
	print("🎯 grant_extra_turn received:", extra)
	if extra:
		_change_state(GameState.AWAITING_ROLL)
	else:
		_next_turn()

# =========================================================
# 🔹 TEAMS & COURT
# =========================================================
func _initialize_teams_and_court():
	var teams = TeamsDB.get_teams()
	selected_team_id_p1 = teams[0]["id"]

	if game_mode == "cpu":
		var cpu_team = TeamsDB.get_cpu_team()
		selected_team_id_p2 = cpu_team["id"]
		EventsBus.cpu_team_assigned.emit(cpu_team)
	else:
		selected_team_id_p2 = teams[1]["id"]

	EventsBus.team_shield_updated.emit(0, TeamsDB.get_team_by_id(selected_team_id_p1)["shield_path"])
	EventsBus.team_shield_updated.emit(1, TeamsDB.get_team_by_id(selected_team_id_p2)["shield_path"])

	var court_default = CourtsDB.get_court_by_id("stadium")
	EventsBus.court_selected.emit(court_default)

func _initialize_team_signals():
	EventsBus.game_mode_selected.connect(_on_game_mode_selected)
	EventsBus.team_selected.connect(_on_team_selected)
	EventsBus.court_selected.connect(board_manager._on_court_selected)

	EventsBus.request_team_menu.connect(func(player_index):
		if game_mode == "cpu" and player_index == 1:
			print("⚠ CPU team cannot be changed in single-player.")
			return
		selecting_player_index = player_index
		EventsBus.show_team_menu.emit(player_index)
	)

func _on_game_mode_selected(mode: String):
	game_mode = mode
	EventsBus.game_mode_changed.emit(game_mode)

func _on_team_selected(player_index: int, team_id: String):
	if player_index == 0:
		selected_team_id_p1 = team_id
	else:
		selected_team_id_p2 = team_id
	EventsBus.team_shield_updated.emit(player_index, TeamsDB.get_team_by_id(team_id)["shield_path"])

# =========================================================
# 🔹 TIMER FLOW
# =========================================================
func _on_halftime_reached():
	print("⏱ Halftime reached")
	EventsBus.halftime_shown.emit(emit_stats())
	_change_state(GameState.SHOWING_HALFTIME)

func _on_halftime_closed():
	EventsBus.resume_timer.emit()
	print("⏱ Halftime closed → Resume game")
	_change_state(GameState.AWAITING_ROLL)

func _on_match_ended():
	print("⏱ Match ended at full time.")
	if chips[0].score == chips[1].score:
		print("⚡ Scores tied → Sudden Death")
		EventsBus.sudden_death_started.emit()
	else:
		print("🏆 Declaring winner at full time")
		EventsBus.winner_declared.emit(_get_winner_index(), emit_stats())

func _on_start_pressed():
	EventsBus.hud_start_requested.emit()
	print("🎮 Start Game")
	timer_started = false
	_change_state(GameState.AWAITING_ROLL)

func _on_play_again_pressed():
	EventsBus.hud_reset_requested.emit()
	print("🔄 GameManager → Play Again triggered")
	for chip in chips:
		chip.score = 0
		chip.chip_current_box = 0
		chip.return_to_start()
	EventsBus.score_updated.emit(0, chips[0].score)
	EventsBus.score_updated.emit(1, chips[1].score)
	if not timer_started:
		timer_started = true
		EventsBus.start_timer.emit()
	timer_started = false
	current_turn = 0
	current_chip = chips[current_turn]
	_highlight_active_player(current_turn)
	_change_state(GameState.AWAITING_ROLL)

# =========================================================
# 🔹 QUIZ COMPLETED
# =========================================================
func _on_quiz_completed(chip: Node2D, correct: bool):
	print("📥 GameManager → Quiz completed | Correct:", correct)
	var sd_manager = get_node_or_null("/root/MAIN/SuddenDeathManager")
	if sd_manager and sd_manager.is_active():
		if correct:
			EventsBus.goal_animation_requested.emit(chip.chip_owner)
		else:
			EventsBus.shame_animation_requested.emit(chip.chip_owner)
		return

	EventsBus.resume_timer.emit()
	questions_db.preload_next_question()

	if not last_slot_result.get("trigger_quiz", false):
		print("🚫 Skipping resolve_outcome — no quiz was triggered")
		return
	if last_slot_result.is_empty():
		push_warning("❌ last_slot_result is EMPTY at quiz completion")
		return

	await board_manager.resolve_outcome(chip, last_slot_result, correct)

	# If popup is blocking, wait; otherwise advance now
	if waiting_for_blocking_popup:
		print("⏸ Waiting for blocking popup...")
	else:
		_next_turn()

# =========================================================
# 🔹 DICE FLOW
# =========================================================
func _on_request_dice_roll():
	if current_state == GameState.AWAITING_ROLL:
		EventsBus.dice_roll_started.emit()
	else:
		print("⚠ Dice roll ignored — state:", current_state)

var dice_result_received: bool = false

func _on_dice_roll_started():
	dice_result_received = false
	if not timer_started:
		timer_started = true
		EventsBus.start_timer.emit()
	_change_state(GameState.ROLLING)
	if DEBUG_MODE and debug_force_dice > 0:
		await get_tree().process_frame
		print("DEBUG: Forcing dice result:", debug_force_dice)
		EventsBus.dice_rolled.emit(debug_force_dice)

func _on_dice_rolled(value: int):
	if dice_result_received:
		return
	dice_result_received = true
	if current_state != GameState.ROLLING:
		print("⚠ Dice roll ignored — state:", current_state)
		return

	print("DEBUG: Dice rolled event caught:", value)
	_change_state(GameState.MOVING_CHIP)
	current_chip = chips[current_turn]

	var result_data = calculate_overshoot_index(current_chip.chip_current_box, value)

	if result_data["is_overshoot"]:
		await current_chip.move_to_index(board_manager.get_final_slot_index())

		# 🔥 Show blast popup at goal on overshoot pass-through
		var blast_pos = board_manager.get_box_position(board_manager.get_final_slot_index())
		EventsBus.show_popup.emit("overshoot", blast_pos, false)

		await current_chip.move_to_index(result_data["overshoot_index"])
		current_chip.chip_current_box = result_data["overshoot_index"]

		# Proceed with normal slot logic after overshoot
		_change_state(GameState.RESOLVING_SLOT)
		last_slot_result = await board_manager.handle_chip_landed(current_chip)
		if last_slot_result.is_empty():
			return

		if last_slot_result.get("trigger_quiz", false):
			_on_quiz_requested(current_chip, last_slot_result.get("extra_info", {}).get("slot_data", {}))
		else:
			await board_manager.resolve_outcome(current_chip, last_slot_result, false)
			if waiting_for_blocking_popup:
				print("⏸ Waiting for blocking popup...")
			else:
				_next_turn()
		return  # 🔥 Prevents duplicate logic below

	else:
		await board_manager.move_chip_by(current_chip, value)

	_change_state(GameState.RESOLVING_SLOT)
	last_slot_result = await board_manager.handle_chip_landed(current_chip)
	if last_slot_result.is_empty():
		return

	if last_slot_result.get("trigger_quiz", false):
		_on_quiz_requested(current_chip, last_slot_result.get("extra_info", {}).get("slot_data", {}))
	else:
		await board_manager.resolve_outcome(current_chip, last_slot_result, false)
		if waiting_for_blocking_popup:
			print("⏸ Waiting for blocking popup...")
		else:
			_next_turn()

# =========================================================
# 🔹 QUIZ FLOW
# =========================================================
func _on_quiz_requested(chip: Node2D, slot_data: Dictionary):
	print("📝 Quiz requested")
	EventsBus.pause_timer.emit()
	EventsBus.quiz_requested.emit(chip, slot_data)
	_change_state(GameState.QUIZ_ACTIVE)

# =========================================================
# 🔹 GOAL / WINNER
# =========================================================
func _on_popup_animation_done():
	print("✅ GameManager: popup_animation_done received")
	print("🧾 last_slot_result contents:", last_slot_result)
	if waiting_for_blocking_popup:
		waiting_for_blocking_popup = false
		_next_turn()
		return

	if last_slot_result.get("extra_turn", false):
		print("🔁 Extra turn granted!")
		current_state = GameState.AWAITING_ROLL
		EventsBus.turn_updated.emit(current_turn)
		return

	var sd_manager = get_node_or_null("/root/MAIN/SuddenDeathManager")
	if sd_manager and sd_manager.is_active():
		EventsBus.request_next_quiz.emit()
	else:
		_next_turn()

func _on_winner_declared(winner_id: int, stats: Dictionary):
	print("HUD → Winner declared for Player", winner_id + 1)
	EventsBus.winner_popup_requested.emit(stats)

# =========================================================
# 🔹 TURN CONTROL
# =========================================================
func _next_turn():
	print("🔁 GameManager: _next_turn() called")
	current_turn = 1 - current_turn
	current_chip = chips[current_turn]
	_highlight_active_player(current_turn)
	_change_state(GameState.AWAITING_ROLL)

func _highlight_active_player(player_index: int):
	EventsBus.active_player_highlight_changed.emit(player_index)

# =========================================================
# 🔹 UTILITIES
# =========================================================
func _change_state(new_state: int):
	current_state = new_state

func _get_winner_index() -> int:
	if chips[0].score > chips[1].score:
		return 0
	elif chips[1].score > chips[0].score:
		return 1
	return -1

func emit_stats() -> Dictionary:
	return {
		"winner_index": _get_winner_index(),
		"teams": [
			{"name": chips[0].team_name, "shield": chips[0].team_shield, "score": chips[0].score},
			{"name": chips[1].team_name, "shield": chips[1].team_shield, "score": chips[1].score}
		]
	}

func _on_main_menu():
	print("🏟 Returning to Main Menu")
	_change_state(GameState.START_MENU)
	var hud_start = get_node_or_null("/root/MAIN/GameHud/HUD_Start")
	if hud_start:
		hud_start.visible = true

func calculate_overshoot_index(start_index: int, roll_value: int) -> Dictionary:
	var final_slot = board_manager.get_final_slot_index()
	var target_index = start_index + roll_value
	var overshoot_index = target_index
	var is_overshoot = false
	if target_index > final_slot:
		is_overshoot = true
		var overflow = target_index - final_slot
		overshoot_index = final_slot - overflow
	return {
		"is_overshoot": is_overshoot,
		"overshoot_index": overshoot_index
	}

# =========================================================
# 🔹 DEBUG CONTROLS
# =========================================================
func _input(event: InputEvent) -> void:
	if not DEBUG_MODE:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _force_dice_roll(1)
			KEY_2: _force_dice_roll(2)
			KEY_3: _force_dice_roll(3)
			KEY_4: _force_dice_roll(4)
			KEY_5: _force_dice_roll(5)
			KEY_6: _force_dice_roll(6)
		if event.keycode == KEY_Q: _adjust_score(0, +1)
		if event.keycode == KEY_A: _adjust_score(0, -1)
		if event.keycode == KEY_W: _adjust_score(1, +1)
		if event.keycode == KEY_S: _adjust_score(1, -1)

func _adjust_score(player_id: int, delta: int):
	print("🎯 DEBUG: Adjust P", player_id + 1, "score by", delta)
	chips[player_id].score += delta
	EventsBus.score_updated.emit(player_id, chips[player_id].score)

func _process(_delta: float) -> void:
	if not DEBUG_MODE:
		return
	if debug_score_p1 != chips[0].score:
		if abs(debug_score_p1 - chips[0].score) > 0.01:
			chips[0].score = debug_score_p1
			EventsBus.score_updated.emit(0, chips[0].score)
		else:
			debug_score_p1 = chips[0].score
	if debug_score_p2 != chips[1].score:
		if abs(debug_score_p2 - chips[1].score) > 0.01:
			chips[1].score = debug_score_p2
			EventsBus.score_updated.emit(1, chips[1].score)
		else:
			debug_score_p2 = chips[1].score

func _force_dice_roll(value: int):
	if current_state == GameState.AWAITING_ROLL:
		print("🎯 DEBUG: Force dice to", value)
		EventsBus.dice_roll_started.emit()
		await get_tree().process_frame
		EventsBus.dice_rolled.emit(value)
	else:
		print("⚠ DEBUG dice ignored — state:", current_state)
