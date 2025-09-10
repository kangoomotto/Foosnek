extends Control

# 🔹 Buttons
@onready var btn_game_mode: Button = $VBoxContainer/MC1/btn_game_mode
@onready var btn_team_select: Button = $VBoxContainer/MC2/btn_team_select
@onready var btn_court_select: Button = $VBoxContainer/MC3/btn_court_select
@onready var btn_start_game: Button = $VBoxContainer/MC4/btn_start_game
@onready var btn_about_us: Button = $VBoxContainer/MC5/btn_about_us

@onready var btn_exit: Button = $VBoxContainer/MC6/btn_exit

# 🔹 Panels
@onready var game_mode_panel: Control = $HUD_GameMode
@onready var team_panel: Control = $HUD_Teams
@onready var court_panel: Control = $HUD_Court
@onready var about_us_panel: Control = $HUD_About_Us

# 🔹 Reference BoardManager to update court
@onready var board_manager: Node = get_node("/root/MAIN/BoardManager")

func _ready():
	btn_game_mode.pressed.connect(func(): game_mode_panel.show_menu())
	btn_team_select.pressed.connect(func(): team_panel.show_menu())
	btn_court_select.pressed.connect(func(): court_panel.show_menu())
	btn_start_game.pressed.connect(func():
		EventsBus.start_pressed.emit()
		hide()
	)
	btn_about_us.pressed.connect(func(): about_us_panel.show_menu())
	btn_exit.pressed.connect(func(): get_tree().quit())
	
	EventsBus.game_mode_selected.connect(_update_game_mode_button)
	#EventsBus.team_selected.connect(_update_team_button)
	EventsBus.court_selected.connect(_update_court_button)
	EventsBus.request_team_menu.connect(func(player_index):
		team_panel.show_menu() # Uses current selecting_player_index
	)

func _update_game_mode_button(mode_id: String):
	var mode_data = GameModesDB.get_mode_by_id(mode_id)
	btn_game_mode.text = mode_data["name"]

func _update_team_button(team_id: String):
	var team_data = TeamsDB.get_team_by_id(team_id)
	btn_team_select.text = team_data["name"]

	
func _update_court_button(court_data: Dictionary):
	btn_court_select.text = court_data["name"]
