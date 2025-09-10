extends Node

func report_error(raw_message: String) -> void:
	var translated = translate_error(raw_message)
	printerr("❌ Original: ", raw_message)
	print("🧠 Hint: ", translated)

func translate_error(raw: String) -> String:
	if raw.find("Invalid call to function 'connect' in base 'null instance'") != -1:
		return "You're trying to connect a signal on a variable that wasn't assigned. Check your @onready var path or initialization order."
	elif raw.find("Invalid get index") != -1 and raw.find("null instance") != -1:
		return "You tried to access a key or index from something that is null (not initialized)."
	elif raw.find("Nonexistent function") != -1:
		return "You're calling a function that doesn't exist on the node you're using."
	else:
		return "No translation available. Enable more cases in ErrorInterceptor."
