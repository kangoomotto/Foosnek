extends Control

# =========================================================
# 🔹 NODE REFERENCES
# =========================================================
@onready var time_label: Label = $TimeLabel

# =========================================================
# 🔹 VARIABLES
# =========================================================
var current_time: float = 0.0
var running: bool = false

# Game config
const HALF_TIME_MINUTES := 45

const FULL_TIME_MINUTES := 90
const GAME_SPEED := 10.0  # adjust for ~5 min real time

var halftime_emitted: bool = false
var match_end_emitted: bool = false

# =========================================================
# 🔹 READY 
# =========================================================
func _ready():
	# ✅ Connect MatchTimer to EventsBus (RESTORE_MATCH_TIMER_SIGNAL_FLOW)
	# ⚠️ These signals allow GameManager & QuizUI to control the timer
	EventsBus.start_timer.connect(start_timer)
	EventsBus.pause_timer.connect(stop_timer)
	EventsBus.resume_timer.connect(resume_timer)

	_update_label()

# =========================================================
# 🔹 TIMER CONTROL
# =========================================================
func start_timer():
	# Called by EventsBus.start_timer
	current_time = 0
	running = true
	halftime_emitted = false
	match_end_emitted = false
	_update_label()

func stop_timer():
	# Called by EventsBus.pause_timer
	running = false

func reset_timer():
	current_time = 0
	halftime_emitted = false
	match_end_emitted = false
	_update_label()

func resume_timer():
	# Called by EventsBus.resume_timer
	running = true

# =========================================================
# 🔹 PROCESS LOOP
# =========================================================
func _process(delta: float):
	if not running:
		return

	# Advance time
	current_time += GAME_SPEED * delta
	_update_label()

	var minutes = int(current_time / 60)
	var seconds = int(current_time) % 60
	# ✅ Emit timer updates for debug or HUD
	EventsBus.timer_tick.emit(minutes, seconds)

	# Halftime reached
	if not halftime_emitted and minutes >= HALF_TIME_MINUTES:
		halftime_emitted = true
		stop_timer()
		# ✅ Trigger halftime signal for GameManager
		EventsBus.halftime_reached.emit()

	# Match End
	if not match_end_emitted and minutes >= FULL_TIME_MINUTES:
		match_end_emitted = true
		stop_timer()
		# ✅ Trigger full-time signal for GameManager
		EventsBus.match_ended.emit()

# =========================================================
# 🔹 DISPLAY
# =========================================================
func _update_label():
	var minutes = int(current_time / 60)
	var seconds = int(current_time) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
