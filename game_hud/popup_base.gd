extends TextureRect

@onready var particles: GPUParticles2D = $PopupParticles
@export var auto_hide_delay := 2.0

const POPUP_DIR := "res://assets/images/popup_cards/"
const SFX_DIR := "res://assets/audio/popup_sfx/"

var slot_type: String = ""
var sfx_player := AudioStreamPlayer.new()
var extra_info: Dictionary = {}

func start(slot_type: String, global_pos: Vector2, extra_info: Dictionary = {}) -> void:
	self.slot_type = slot_type
	self.extra_info = extra_info

	var parent := get_parent()
	if parent is CanvasItem:
		position = parent.to_local(global_pos)
	else:
		push_warning("❌ PopupBase: Cannot convert position — parent is not a CanvasItem.")

	add_child(sfx_player)
	_set_random_visual(slot_type)
	_play_random_sfx(slot_type)
	_show_popup()

func _show_popup() -> void:
	print("📦 PopupBase: Showing popup for slot_type =", slot_type)
	particles.emitting = true
	show()

	# ✅ Emit immediately for non-blocking popups
	var blocking = extra_info.get("blocking", false)
	if not blocking:
		EventsBus.popup_animation_done.emit()

	# Timer only controls visual lifespan now
	await get_tree().create_timer(auto_hide_delay).timeout
	queue_free()

func _set_random_visual(slot_type: String) -> void:
	if slot_type.is_empty():
		push_warning("⚠️ _set_random_visual: slot_type is empty")
		return

	var files: PackedStringArray = DirAccess.get_files_at(POPUP_DIR)
	var matching := []
	for file in files:
		if file.begins_with(slot_type.to_lower() + "_") and file.ends_with(".png"):
			matching.append(file)

	if matching.size() > 0:
		var selected = matching.pick_random()
		var image_path = POPUP_DIR + selected
		texture = load(image_path)
	else:
		push_warning("⚠️ No matching images found for slot_type: " + slot_type)

func _play_random_sfx(slot_type: String) -> void:
	var files = DirAccess.get_files_at(SFX_DIR)
	var matching := []
	for f in files:
		if f.ends_with(".wav") and f.get_basename().match(slot_type.to_lower() + "_%02d"):
			matching.append(f)

	if matching.size() > 0:
		var selected = matching.pick_random()
		var stream = load(SFX_DIR + selected)
		if stream:
			sfx_player.stream = stream
			sfx_player.play()
