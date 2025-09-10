extends Control

# =========================================================
# 🔹 SIGNALS
# =========================================================
signal play_again_pressed
signal main_menu_pressed

# =========================================================
# 🔹 NODE REFERENCES
# =========================================================
@onready var shield1: TextureRect = $GridContainer/Shield1
@onready var shield2: TextureRect = $GridContainer/Shield2
@onready var name1: Label = $GridContainer/Name1
@onready var name2: Label = $GridContainer/Name2
@onready var score1: Label = $GridContainer/Score1
@onready var score2: Label = $GridContainer/Score2
@onready var winner_label: Label = $WinnerOrDraw
@onready var btn_play_again: Button = $btn_replay  # renamed for clarity (play again)
@onready var btn_main_menu: Button = $btn_main_menu  # add this in scene for explicit main menu

# =========================================================
# 🔹 READY
# =========================================================
func _ready() -> void:
	visible = false

	if btn_play_again:
		btn_play_again.pressed.connect(_on_play_again_pressed)

	if btn_main_menu:
		btn_main_menu.pressed.connect(_on_main_menu_pressed)

func _on_main_menu_pressed() -> void:
	print("HUD_Winner → Main Menu pressed")
	EventsBus.main_menu.emit()

# =========================================================
# 🔹 SHOW POPUP
# =========================================================
func show_popup(stats: Dictionary) -> void:
	update_panel(stats)
	visible = true
	print("🏆 HUD_Winner → Popup shown with stats:", stats)
	# Ensure replay button is connected (Sudden Death path might skip _ready())
	if btn_play_again and not btn_play_again.pressed.is_connected(_on_play_again_pressed):
		btn_play_again.pressed.connect(_on_play_again_pressed)
		
	#EventsBus.play_again_requested.emit()
func _on_play_again_pressed() -> void:
	print("HUD_Winner → Play Again pressed")
	EventsBus.play_again_requested.emit()
# =========================================================
# 🔹 UPDATE PANEL DATA
# =========================================================
func update_panel(stats: Dictionary) -> void:
	var winner_index: int = stats.get("winner_index", -1)
	var teams: Array = stats.get("teams", [])

	# Winner or Draw label
	if winner_index == -1:
		winner_label.text = "Draw"
	else:
		winner_label.text = "Winner"

	# Arrange display order
	if teams.size() >= 2:
		if winner_index == 0:
			_set_team_data_top(teams[0])
			_set_team_data_bottom(teams[1])
		elif winner_index == 1:
			_set_team_data_top(teams[1])
			_set_team_data_bottom(teams[0])
		else: # Draw
			_set_team_data_top(teams[0])
			_set_team_data_bottom(teams[1])

# =========================================================
# 🔹 HELPER — TEAM DATA
# =========================================================
func _set_team_data_top(team_data: Dictionary) -> void:
	_set_team_display(shield1, name1, score1, team_data)

func _set_team_data_bottom(team_data: Dictionary) -> void:
	_set_team_display(shield2, name2, score2, team_data)

func _set_team_display(shield_node: TextureRect, name_node: Label, score_node: Label, team_data: Dictionary) -> void:
	if shield_node:
		_set_shield_texture(shield_node, team_data.get("shield", ""))
	if name_node:
		name_node.text = team_data.get("name", "Unknown")
	if score_node:
		score_node.text = str(team_data.get("score", 0))

# =========================================================
# 🔹 SHIELD LOADER
# =========================================================
func _set_shield_texture(node: TextureRect, shield_source) -> void:
	if shield_source is String and ResourceLoader.exists(shield_source):
		node.texture = load(shield_source)
	elif shield_source is Texture2D:
		node.texture = shield_source
	else:
		node.texture = null
