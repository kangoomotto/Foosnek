extends Panel

signal shield_clicked(player_index: int)

@onready var shield_1: TextureRect = $HBoxContainer/Shield_1
@onready var shield_2: TextureRect = $HBoxContainer/Shield_2
@onready var highlight_1: Node = $HBoxContainer/Shield_1/Highlight_1
@onready var highlight_2: Node = $HBoxContainer/Shield_2/Highlight_2

var current_game_mode: String = "cpu"
var current_selecting_player_index: int = 0

func _ready():
	# Listen to mode changes
	EventsBus.game_mode_changed.connect(_on_game_mode_changed)
	
	# Listen for selecting player changes
	EventsBus.selecting_player_changed.connect(_on_selecting_player_changed)

	# Connect shield clicks
	shield_1.gui_input.connect(_on_shield1_input)
	shield_2.gui_input.connect(_on_shield2_input)

	# Shield clicked signal
	shield_clicked.connect(_on_shield_clicked)

	# Default: focus Team 1 at startup
	current_selecting_player_index = 0
	
	_disable_shield2_click()
	_update_highlights()


# =========================================================
# 🔹 MODE CHANGED
# =========================================================
func _on_game_mode_changed(mode: String) -> void:
	current_game_mode = mode

	# Lock to P1 in CPU mode
	if current_game_mode == "cpu":
		current_selecting_player_index = 0
		EventsBus.selecting_player_changed.emit(0)
		_disable_shield2_click()
	else:
		_enable_shield2_click()

	_update_highlights()


# =========================================================
# 🔹 PLAYER SELECTION CHANGED
# =========================================================
func _on_selecting_player_changed(index: int) -> void:
	current_selecting_player_index = index
	_update_highlights()


# =========================================================
# 🔹 SHIELD INPUT
# =========================================================
func _on_shield1_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		shield_clicked.emit(0)

func _on_shield2_input(event: InputEvent) -> void:
	if current_game_mode == "pvp":  # Shield 2 active only in PvP
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shield_clicked.emit(1)


# =========================================================
# 🔹 SHIELD CLICK HANDLER
# =========================================================
func _on_shield_clicked(player_index: int) -> void:
	# Switch active selection ONLY if player clicked the other shield
	current_selecting_player_index = player_index
	EventsBus.selecting_player_changed.emit(player_index)
	EventsBus.request_team_menu.emit(player_index)
	_update_highlights()


# =========================================================
# 🔹 HIGHLIGHTS
# =========================================================
func _update_highlights():
	highlight_1.visible = (current_selecting_player_index == 0)
	highlight_2.visible = (current_selecting_player_index == 1)


# =========================================================
# 🔹 CLICK LOCKS
# =========================================================
func _disable_shield2_click():
	shield_2.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _enable_shield2_click():
	shield_2.mouse_filter = Control.MOUSE_FILTER_STOP


# =========================================================
# 🔹 UPDATE SHIELDS TEXTURE
# =========================================================
func update_shields(shield_left: Texture2D, shield_right: Texture2D) -> void:
	if shield_1:
		shield_1.texture = shield_left
	if shield_2:
		shield_2.texture = shield_right
