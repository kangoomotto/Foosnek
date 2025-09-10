extends Node

var scores := [0, 0]
var round_results := [null, null]
var current_turn := 0
var active := false
var watchdog_timer: Timer

@onready var chip_p1: Node2D = get_node("/root/MAIN/playerChipPink")
@onready var chip_p2: Node2D = get_node("/root/MAIN/playerChipBlue")

func _ready():
	#print("DEBUG: SuddenDeathManager ready, connecting signals")
	EventsBus.sudden_death_started.connect(_on_sudden_death_started)
	EventsBus.sudden_death_start.connect(_on_sudden_death_start_button)
	EventsBus.quiz_completed.connect(_on_quiz_completed)

	# Create watchdog timer
	watchdog_timer = Timer.new()
	watchdog_timer.one_shot = true
	add_child(watchdog_timer)

func is_active() -> bool:
	return active

func _on_sudden_death_start_button():
	#print("⚡ SuddenDeathManager → Start pressed, sudden death active")
	active = true
	scores = [0, 0]
	round_results = [null, null]
	current_turn = 0
	_emit_scores()
	_request_quiz()  # ✅ First quiz now triggered here
# =========================================================
# 🔹 START SUDDEN DEATH
# =========================================================
func _on_sudden_death_started():
	#print("⚡ SuddenDeathManager → Waiting for player to press StartButton")
	active = false  # stays paused until button is pressed
	scores = [0, 0]
	round_results = [null, null]
	current_turn = 0
	_emit_scores()

	# ❌ Removed this line:
	# _request_quiz()

# =========================================================
# 🔹 QUIZ FLOW
# =========================================================
func _request_quiz():
	if not active:
		return

	var chip = chip_p1 if current_turn == 0 else chip_p2
	#print("📝 SuddenDeathManager → Request quiz for Player", current_turn + 1)

	# 🔹 Use delayed quiz to prevent panel overlap and restore animation sync
	EventsBus.quiz_delayed_requested.emit(chip, {"type": "suddendeath"})
	_start_watchdog("quiz_requested timeout for Player " + str(current_turn + 1))

func _on_quiz_completed(chip: Node2D, correct: bool):
	if not active:
		return
	if chip.chip_owner != current_turn:
		return

	_stop_watchdog()
	#print("📥 SuddenDeathManager → P", current_turn + 1, "answered:", correct)
	round_results[current_turn] = correct

	# ✅ Load next question for the next quiz
	questions_db.preload_next_question()


	if correct:
		scores[current_turn] += 1
		EventsBus.sudden_death_score_updated.emit(current_turn, scores[current_turn])

	if current_turn == 0:
		current_turn = 1
		_request_quiz()
	else:
		_evaluate_round()

# =========================================================
# 🔹 EVALUATE ROUND
# =========================================================
func _evaluate_round():
	var p1 = round_results[0]
	var p2 = round_results[1]
	#print("⚡ SuddenDeathManager → Round results:", p1, "|", p2)

	if p1 != p2:
		var winner = 0 if p1 else 1
		print("🏆 SuddenDeathManager → Winner is Player", winner + 1)
		active = false
		EventsBus.winner_declared.emit(winner, _emit_stats())
		_start_watchdog("winner_declared timeout after deciding winner")
	else:
		print("⚡ SuddenDeathManager → Tie, next round")
		round_results = [null, null]
		current_turn = 0
		_request_quiz()

# =========================================================
# 🔹 WATCHDOG HELPERS
# =========================================================
func _start_watchdog(reason: String):
	#watchdog_timer.stop()
	#watchdog_timer.wait_time = 5.0
	#watchdog_timer.start()
	#watchdog_timer.timeout.connect(func():
		#print("⚠ Watchdog Warning → SuddenDeathManager stalled:", reason)
	#)
	return

func _stop_watchdog():
	#watchdog_timer.stop()
	return

# =========================================================
# 🔹 UTILITIES
# =========================================================
func _emit_scores():
	for i in range(2):
		EventsBus.sudden_death_score_updated.emit(i, scores[i])

func _emit_stats() -> Dictionary:
	return {
		"winner_index": 0 if scores[0] > scores[1] else 1,
		"teams": [
			{"name": chip_p1.team_name, "shield": chip_p1.team_shield, "score": scores[0]},
			{"name": chip_p2.team_name, "shield": chip_p2.team_shield, "score": scores[1]}
		]
	}
