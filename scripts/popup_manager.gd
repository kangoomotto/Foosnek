extends Node

const PopupBaseScene := preload("res://game_hud/scenes/PopupBase.tscn")

# ✅ Popup queue system to prevent overlaps
var _popup_queue: Array = []
var _popup_active: bool = false

func _ready() -> void:
	EventsBus.show_popup.connect(show_popup)
	EventsBus.popup_animation_done.connect(_on_popup_done)

func show_popup(slot_type: String, position: Vector2, is_correct: bool = true) -> void:
	# ✅ Ignore empty types
	if slot_type == "" or slot_type == null:
		push_warning("⚠ popup_manager: Empty slot_type ignored")
		return

	# Queue the popup request
	_popup_queue.append({
		"slot_type": slot_type,
		"position": position,
		"is_correct": is_correct
	})

	# Try to process immediately if no active popup
	if not _popup_active:
		_process_next_popup()

func _process_next_popup() -> void:
	if _popup_queue.is_empty():
		_popup_active = false
		return

	_popup_active = true
	var req = _popup_queue.pop_front()

	var popup := PopupBaseScene.instantiate()
	popup.global_position = req.position
	popup.z_index = 999

	var extra_info := { "is_correct": req.is_correct }

	EventsBus.popup_ready.emit(popup)
	await popup.ready
	popup.start(req.slot_type, req.position, extra_info)

func _on_popup_done() -> void:
	_popup_active = false
	# Process next in queue
	_process_next_popup()
