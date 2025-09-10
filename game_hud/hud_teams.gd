extends Control
signal team_selected(team_id: String)

@onready var teams_grid: GridContainer = $ScrollContainer/MarginContainer/Grid
@onready var btn_close = $btn_close
@onready var player_title: Label = $PlayerTitle

@export var team_button_scene: PackedScene
var team_buttons: Array = []
var original_font_sizes: Dictionary = {}

var current_game_mode: String = "cpu"
var current_selecting_player_index: int = 0
var selected_team_p1: String = ""
var selected_team_p2: String = ""
var cpu_team_data: Dictionary = {}

func _ready():
	# 🔹 Keep game mode and selecting player index in sync
	EventsBus.game_mode_changed.connect(func(mode): current_game_mode = mode)
	EventsBus.selecting_player_changed.connect(func(index): current_selecting_player_index = index)
	EventsBus.team_selected.connect(_on_team_selected_external)
	EventsBus.cpu_team_assigned.connect(func(cpu_team):
		cpu_team_data = cpu_team
		selected_team_p2 = cpu_team_data["name"]
	)


	btn_close.pressed.connect(_on_close_pressed)
	btn_close.mouse_entered.connect(func(): _on_button_mouse_entered(btn_close))
	btn_close.mouse_exited.connect(func(): _on_button_mouse_exited(btn_close))
	hide()

func show_menu():
	_clear_buttons()
	var teams_list = TeamsDB.get_teams()

	# 🔹 Title update
	#match current_game_mode:
		#"cpu":
			#player_title.text = "Select Team for Player 1"
		#"pvp":
			#player_title.text = "Select Team for Player %d" % (current_selecting_player_index + 1)
		#_:
			#player_title.text = "Mode not ready — Demo selection"

	# 🔹 Create team buttons
	for team_data in teams_list:
		var margin = team_button_scene.instantiate()
		var btn = margin.get_node("team_button")
		var shield_icon = margin.get_node("shield_icon")

		btn.text = team_data["name"]
		if shield_icon and ResourceLoader.exists(team_data["shield_path"]):
			shield_icon.texture = load(team_data["shield_path"])

		btn.pressed.connect(func(): _emit_team(team_data["id"], team_data["name"]))
		btn.mouse_entered.connect(func(): _on_button_mouse_entered(btn))
		btn.mouse_exited.connect(func(): _on_button_mouse_exited(btn))

		teams_grid.add_child(margin)
		team_buttons.append(margin)

	show()

func _emit_team(team_id: String, team_name: String):
	var team_data = TeamsDB.get_team_by_id(team_id)
	if not team_data: 
		print("⚠ Invalid team ID selected:", team_id)
		return

	match current_game_mode:
		"pvp":
			if current_selecting_player_index == 0:
				selected_team_p1 = team_name
				EventsBus.team_shield_updated.emit(0, team_data["shield_path"])
				#EventsBus.selecting_player_changed.emit(1) # Switch to P2
			elif current_selecting_player_index == 1:
				selected_team_p2 = team_name
				EventsBus.team_shield_updated.emit(1, team_data["shield_path"])

		"cpu":
			if current_selecting_player_index == 0:
				selected_team_p1 = team_name
				EventsBus.team_shield_updated.emit(0, team_data["shield_path"])
				
				# 🔹 Always fetch CPU team fresh to avoid stale data
				var cpu_team = TeamsDB.get_cpu_team()
				selected_team_p2 = cpu_team["name"]
				EventsBus.team_shield_updated.emit(1, cpu_team["shield_path"])
				
				# ❌ Do NOT auto-close, let Close button handle it
				# hide()

		_:
			print("⚠ Game mode '%s' not implemented for team selection" % current_game_mode)

	EventsBus.team_selected.emit(team_id)


func _on_team_selected_external(team_id: String):
	var team_data = TeamsDB.get_team_by_id(team_id)
	if not team_data:
		return

	if current_game_mode == "pvp":
		if current_selecting_player_index == 0:
			selected_team_p1 = team_data["name"]
		else:
			selected_team_p2 = team_data["name"]

	elif current_game_mode == "cpu":
		selected_team_p1 = team_data["name"]

		# 🔹 Always fetch CPU team fresh from TeamsDB
		var cpu_team = TeamsDB.get_cpu_team()
		selected_team_p2 = cpu_team["name"]
		EventsBus.team_shield_updated.emit(1, cpu_team["shield_path"])


func _on_close_pressed():
	hide()

func _clear_buttons():
	for margin in team_buttons:
		if is_instance_valid(margin):
			margin.queue_free()
	team_buttons.clear()
	original_font_sizes.clear()

func _on_button_mouse_entered(btn):
	if not original_font_sizes.has(btn):
		original_font_sizes[btn] = btn.get_theme_font_size("font_size")
	btn.add_theme_font_size_override("font_size", original_font_sizes[btn] + 10)

func _on_button_mouse_exited(btn):
	if original_font_sizes.has(btn):
		btn.add_theme_font_size_override("font_size", original_font_sizes[btn])
