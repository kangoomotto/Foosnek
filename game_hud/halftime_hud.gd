extends Panel

# =========================================================
# 🔹 SIGNALS
# =========================================================
signal halftime_closed

# =========================================================
# 🔹 NODE REFERENCES
# =========================================================
@onready var shield1: TextureRect = $GridContainer/Shield1
@onready var shield2: TextureRect = $GridContainer/Shield2
@onready var name1: Label = $GridContainer/Name1
@onready var name2: Label = $GridContainer/Name2
@onready var score1: Label = $GridContainer/Score1
@onready var score2: Label = $GridContainer/Score2

# =========================================================
# 🔹 READY
# =========================================================
func _ready() -> void:
	visible = false

# =========================================================
# 🔹 UPDATE PANEL DATA
# =========================================================
func update_panel(stats: Dictionary) -> void:
	var teams: Array = stats.get("teams", [])
	if teams.size() >= 2:
		# Player 1
		name1.text = teams[0].get("name", "Unknown")
		score1.text = str(teams[0].get("score", 0))
		_set_shield_texture(shield1, teams[0].get("shield", ""))

		# Player 2
		name2.text = teams[1].get("name", "Unknown")
		score2.text = str(teams[1].get("score", 0))
		_set_shield_texture(shield2, teams[1].get("shield", ""))

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

# =========================================================
# 🔹 SHOW POPUP
# =========================================================
func show_popup() -> void:
	visible = true
	print("⏸ HUD_Halftime → Popup shown")

# =========================================================
# 🔹 INPUT CLOSE
# =========================================================
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		visible = false
		print("▶ HUD_Halftime → Closing panel and resuming game")
		EventsBus.halftime_closed.emit()
