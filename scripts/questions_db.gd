extends Node

var questions_by_category: Dictionary = {}
var remaining_questions: Dictionary = {} # 🔹 Pools per category
var cached_question: Dictionary = {}

func _ready():
	load_questions_from_json()
	reset_remaining_pools()
	preload_next_question()

# =========================================================
# 🔹 LOAD QUESTIONS
# =========================================================
func load_questions_from_json():
	var path = "res://data/global_questions.json"
	if not FileAccess.file_exists(path):
		push_error("❌ Missing question file at " + path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("❌ Failed to open " + path)
		return

	var content = file.get_as_text()
	var parsed: Dictionary = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("❌ Invalid JSON format in " + path)
		return

	var validated = {}
	for category in parsed.keys():
		validated[category] = []
		for q in parsed[category]:
			if not q.has("question") or not q.has("answers") or not q.has("answer_image"):
				continue
			if q["answers"].size() < 6:
				continue

			var img_path = "res://assets/images/question_cards/%s/%s" % [category, q["answer_image"]]
			if not ResourceLoader.exists(img_path):
				img_path = "res://assets/images/defaults/default_answer.png"
			q["answer_image"] = img_path
			q["category"] = category
			validated[category].append(q)

	questions_by_category = validated

# =========================================================
# 🔹 RESET POOLS
# =========================================================
func reset_remaining_pools():
	remaining_questions.clear()
	for category in questions_by_category.keys():
		remaining_questions[category] = questions_by_category[category].duplicate()

# =========================================================
# 🔹 SELECT NEW QUESTION (NO REPEAT UNTIL EMPTY)
# =========================================================
func preload_next_question():
	#print("\n🔄 [DEBUG] Preloading next question...")
	
	var all_categories = remaining_questions.keys()
	#print("   Categories available:", all_categories)

	if all_categories.is_empty():
		push_error("❌ No question categories loaded.")
		return

	# 🔹 Pick random category
	var random_category = all_categories[randi() % all_categories.size()]
	#print("   Selected category:", random_category)
	
	var pool = remaining_questions[random_category]
	#print("   Pool size before selection:", pool.size())

	# 🔄 Refill if pool is empty
	if pool.is_empty():
		#print("   Pool is empty, refilling from full list...")
		remaining_questions[random_category] = questions_by_category[random_category].duplicate()
		pool = remaining_questions[random_category]
		#print("   Pool refilled. New size:", pool.size())

	# 🎯 Pick question
	var q_index = randi() % pool.size()
	var question = pool[q_index]
	#print("   Picked question index:", q_index, "| Question text:", question.get("question", "???"))
	
	pool.remove_at(q_index) # 🔹 Remove so it won’t repeat until refill
	#print("   Pool size after removal:", pool.size())

	# 🔹 Shuffle answers
	var all_answers = question.get("answers", []).duplicate()
	var correct_answer = all_answers[0]
	var wrong_answers = all_answers.slice(1) # take all wrong answers
	wrong_answers.shuffle()
	var selected_wrong_answers = wrong_answers.slice(0, 3)
	var final_answers = [correct_answer] + selected_wrong_answers
	final_answers.shuffle()

	question["shuffled_answers"] = final_answers
	question["correct_index"] = final_answers.find(correct_answer)
	cached_question = question

	#print("   Shuffled answers:", final_answers)
	#print("   Correct answer index:", question["correct_index"])
