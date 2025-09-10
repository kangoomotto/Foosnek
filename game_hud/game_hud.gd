extends CanvasLayer

# =========================================================
# 🔹 SIGNALS TO GAME MANAGER
# =========================================================
signal halftime_closed
signal goal_animation_done
signal quiz_completed(chip: Node2D, correct: bool)

# =========================================================
# 🔹 NODES
# =========================================================
@onready var hud_quiz: Control = $HUD_Quiz
@onready var hud_halftime: Control = $HUD_Halftime
@onready var hud_score: Control = $HUD_Score
@onready var hud_timer: Control = $HUD_Score/HBoxContainer/HUD_Timer
@onready var hud_winner: Control = $HUD_Winner
@onready var sudden_death_panel: Control = $HUD_Sudden_Death_Panel
@onready var popup_layer: Node = $HUD_PopupLayer

# =========================================================
# 🔹 STATE
# =========================================================
signal shield_clicked(player_index: int)
var active_chip: Node2D

# =========================================================
# 🔹 READY
# =========================================================
func _ready():
	_start_hud_state()

	# 🔹 Connect popup system
	EventsBus.popup_ready.connect(_on_popup_ready)

	# 🔹 Quiz display
	EventsBus.quiz_requested.connect(_on_quiz_requested)
	EventsBus.quiz_delayed_requested.connect(func(chip, slot_data):
		active_chip = chip
		hud_quiz.current_chip = chip
		hud_quiz.display_question(slot_data)
		hud_quiz.visible = true
	)

	# 🔹 Score + Events
	EventsBus.score_updated.connect(_on_score_updated)
	EventsBus.goal_scored.connect(_on_goal_scored)
	EventsBus.halftime_shown.connect(_on_halftime_shown)
	EventsBus.winner_declared.connect(_on_winner_declared)

	# 🔹 Sudden death & HUD flow
	EventsBus.sudden_death_started.connect(_on_sudden_death_started)
	EventsBus.sudden_death_score_updated.connect(_on_sudden_death_score_updated)
	EventsBus.hud_reset_requested.connect(_restart_hud_state)
	EventsBus.hud_start_requested.connect(_start_hud_state)

	# 🔹 Team shield click-to-select
	EventsBus.team_shield_updated.connect(_on_team_shield_updated)

	$HUD_Score/HBoxContainer/Shield_1.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shield_clicked.emit(0)
	)

	$HUD_Score/HBoxContainer/Shield_2.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shield_clicked.emit(1)
	)

	shield_clicked.connect(func(player_index):
		EventsBus.selecting_player_changed.emit(player_index)
		EventsBus.request_team_menu.emit(player_index)
	)

	# 🔹 Highlight active player
	EventsBus.active_player_highlight_changed.connect(func(player_index: int):
		var h1 = hud_score.get_node("HBoxContainer/Shield_1/Highlight_1")
		var h2 = hud_score.get_node("HBoxContainer/Shield_2/Highlight_2")
		h1.visible = (player_index == 0)
		h2.visible = (player_index == 1)
	)

# =========================================================
# 🔹 POPUP SYSTEM
# =========================================================
func _on_popup_ready(popup: Node) -> void:
	#print("📦 HUD → Received popup_ready, adding to popup_layer")
	popup_layer.add_child(popup)
	await get_tree().process_frame
	popup.start(popup.slot_type, popup.global_position, popup.extra_info)



# =========================================================
# 🔹 INIT / RESET HUD
# =========================================================
func _restart_hud_state():
	#print("restart hud state")
	$HUD_Start.visible = false
	_reset_panels()

func _start_hud_state():
	#print("start hud state")
	$HUD_Start.visible = true
	_reset_panels()

func _reset_panels():
	$HUD_Score.visible = true
	$HUD_Winner.visible = false
	$HUD_Halftime.visible = false
	$HUD_Quiz.visible = false
	$HUD_Sudden_Death_Panel.visible = false

# =========================================================
# 🔹 SCORE UPDATES
# =========================================================
func _on_score_updated(player_id: int, new_score: int):
	var left_label = hud_score.get_node("HBoxContainer/ScoreLabel_Left")
	var right_label = hud_score.get_node("HBoxContainer/ScoreLabel_Right")
	if player_id == 0:
		left_label.text = str(new_score)
	elif player_id == 1:
		right_label.text = str(new_score)

# =========================================================
# 🔹 TEAM SHIELD TEXTURE
# =========================================================
func _on_team_shield_updated(player_index: int, shield_path: String):
	var texture: Texture2D = null
	if ResourceLoader.exists(shield_path):
		texture = load(shield_path)

	if player_index == 0:
		hud_score.get_node("HBoxContainer/Shield_1").texture = texture
	else:
		hud_score.get_node("HBoxContainer/Shield_2").texture = texture

# =========================================================
# 🔹 QUIZ
# =========================================================
func _on_quiz_requested(chip: Node2D, slot_data: Dictionary):
	active_chip = chip
	hud_quiz.current_chip = chip
	hud_quiz.display_question(slot_data)
	hud_quiz.visible = true

	if not hud_quiz.quiz_completed.is_connected(_on_quiz_completed):
		hud_quiz.quiz_completed.connect(_on_quiz_completed)
	else:
		print("⚠️ Quiz panel already connected to quiz_completed")

func _on_quiz_completed(last_is_correct: bool) -> void:
	print("📤 HUD → Quiz completed | Correct:", last_is_correct)
	if active_chip:
		EventsBus.quiz_completed.emit(active_chip, last_is_correct)
	else:
		push_warning("⚠ quiz_completed emitted without chip reference")

# =========================================================
# 🔹 GOAL → replaced with POPUP
# =========================================================
func _on_goal_scored(player_id: int):
	# NOTE: No longer uses hud_goal. Uses popup system via BoardManager.
	print("⚽ GOAL scored by player:", player_id)

# =========================================================
# 🔹 HALFTIME
# =========================================================
func _on_halftime_shown(stats: Dictionary):
	hud_halftime.update_panel(stats)
	hud_halftime.show_popup()
	hud_halftime.halftime_closed.connect(func(): halftime_closed.emit())

# =========================================================
# 🔹 WINNER
# =========================================================
func _on_winner_declared(winner_id: int, stats: Dictionary):
	print("HUD → Winner declared for Player", winner_id + 1)
	$HUD_Sudden_Death_Panel.visible = false
	hud_winner.show_popup(stats)

# =========================================================
# 🔹 SUDDEN DEATH
# =========================================================
func _on_sudden_death_started():
	print("HUD → Sudden Death Started")
	if sudden_death_panel:
		sudden_death_panel.visible = true
		sudden_death_panel.get_node("Container/HBox1/Score1").text = "0"
		sudden_death_panel.get_node("Container/HBox1/Score2").text = "0"

		var btn = sudden_death_panel.get_node("StartButton")
		btn.visible = true
		btn.disabled = false
		for c in btn.pressed.get_connections():
			btn.pressed.disconnect(c.callable)
		btn.pressed.connect(func():
			btn.disabled = true
			btn.visible = false
			EventsBus.sudden_death_start.emit()
			print("✅ Sudden Death Start emitted")
		)
	else:
		push_warning("⚠ Sudden Death Panel missing")

func _on_sudden_death_score_updated(player_id: int, score: int):
	if sudden_death_panel:
		if player_id == 0:
			sudden_death_panel.get_node("Container/HBox1/Score1").text = str(score)
		else:
			sudden_death_panel.get_node("Container/HBox1/Score2").text = str(score)
