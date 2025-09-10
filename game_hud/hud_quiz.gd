extends Control

signal quiz_completed(correct: bool)

var current_chip: Node2D
var correct_index: int = -1
var can_close: bool = false
var last_is_correct: bool = false

@onready var answer_buttons := [
	$Answers/Row1/Answer_1,
	$Answers/Row1/Answer_2,
	$Answers/Row2/Answer_3,
	$Answers/Row2/Answer_4
]

@onready var label_question: Label = $label_question
@onready var answer_label: Label = $answer_label
@onready var answer_image: TextureRect = $answer_image
@onready var label_slot: Label = $label_slot
@onready var slot_badge: TextureRect = $slot_badge
@onready var feedback_label: Label = $feedback_label
@onready var feedback_label2: Label = $feedback_label2
@onready var strip_category: TextureRect = $strip_category
@onready var frame_category: TextureRect = $frame_image
@onready var bg_texture: TextureRect = $bg_texture
@onready var strip_slot: TextureRect = $strip_slot
@onready var strip_answer: TextureRect = $strip_answer

func _ready():
	# 🔹 Connect to EventsBus so we get the quiz request
	EventsBus.quiz_requested.connect(_on_quiz_requested)
	flash_buttons()
	start_flash_loop()
func _on_quiz_requested(chip: Node2D, slot_data: Dictionary) -> void:
	print("📺 HUD_Quiz → Quiz requested, showing panel")
	current_chip = chip
	display_question(slot_data)
	#visible = true  # 🔹 Make sure the panel is NOT visible, Only prepare the panel here

func display_question(slot_data: Dictionary):
	_reset_quiz_visuals()

	var question_data = questions_db.cached_question
	correct_index = question_data.get("correct_index", -1)
	label_question.text = question_data.get("question", "")
	answer_label.text = question_data.get("shuffled_answers", [])[correct_index] if correct_index >= 0 else ""

	var answers = question_data.get("shuffled_answers", [])
	for i in answer_buttons.size():
		var btn = answer_buttons[i]
		btn.text = answers[i]
		for c in btn.pressed.get_connections():
			btn.pressed.disconnect(c.callable)
		btn.pressed.connect(func(): _on_answer_selected(i))

	_load_question_visuals(question_data, slot_data)

func _load_question_visuals(question_data: Dictionary, slot_data: Dictionary):
	var answer_path = question_data.get("answer_image", "")
	answer_image.texture = load(answer_path) if ResourceLoader.exists(answer_path) else preload("res://assets/images/defaults/default_answer.png")

	var category = question_data.get("category", "").to_lower()
	var strip_path = "res://assets/images/question_cards/%s/strip_trivia.png" % category
	strip_category.texture = load(strip_path) if ResourceLoader.exists(strip_path) else preload("res://assets/images/defaults/default_strip_trivia.png")

	var frame_path = "res://assets/images/question_cards/%s/question_frame.png" % category
	frame_category.texture = load(frame_path) if ResourceLoader.exists(frame_path) else preload("res://assets/images/defaults/default_frame.png")

	var bg_path = "res://assets/images/question_cards/%s/question_bg.png" % category
	bg_texture.texture = load(bg_path) if ResourceLoader.exists(bg_path) else preload("res://assets/images/defaults/default_question_bg.png")

	var slot_type = slot_data.get("type", "GENERIC").to_lower()
	label_slot.text = slot_data.get("label", slot_type.capitalize())
	var image_pool = slot_data.get("image_pool", [])
	slot_badge.texture = load(image_pool[0]) if image_pool.size() > 0 and ResourceLoader.exists(image_pool[0]) else preload("res://assets/images/defaults/default_slot.png")

func _on_answer_selected(index: int):
	last_is_correct = index == correct_index
	show_feedback(last_is_correct)
	can_close = true

func show_feedback(correct: bool):
	$Answers.visible = false
	label_question.visible = false
	feedback_label.visible = true
	feedback_label2.visible = true
	answer_label.visible = true
	strip_answer.visible = true
	answer_image.visible = true
	feedback_label.text = "¡Correcto!" if correct else "¡Incorrecto!"

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and can_close:
		visible = false
		if current_chip:
			EventsBus.quiz_completed.emit(current_chip, last_is_correct)
		else:
			push_warning("⚠ quiz_completed emitted without chip reference")

func _reset_quiz_visuals():
	$Answers.visible = true
	label_question.visible = true
	feedback_label.visible = false
	feedback_label2.visible = false
	answer_label.visible = false
	strip_answer.visible = false
	answer_image.visible = false
	answer_image.modulate = Color(1, 1, 1)
	can_close = false

func start_flash_loop():
	await get_tree().create_timer(4.0).timeout
	while true:
		flash_buttons()
		await get_tree().create_timer(4.0).timeout

func flash_buttons():
	for button in answer_buttons:
		var original = button.modulate
		var tween = create_tween()
		tween.tween_property(button, "modulate", Color(2, 2, 2, 1.0), 0.2)
		tween.tween_property(button, "modulate", original, 0.5)
