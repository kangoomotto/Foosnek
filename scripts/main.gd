extends Node

@onready var dice_viewport_container = $DiceViewportContainer
@onready var dice = $DiceViewportContainer/DiceViewport/Dice_Box/Dice

func _ready():
	#print("✅ MAIN READY — Dice initialized:", dice)
	#print_node_tree(get_tree().root, 0)
	#_print_scene_tree(get_tree().root, 0)
	print_directory_structure("res://")
	pass
	
	# Dice is only visual; control is handled by GameManager
func set_dice_visibility(visible: bool) -> void:
	dice_viewport_container.visible = visible

func move_display():
	await get_tree().process_frame  # ⏳ Let window fully initialize
	DisplayServer.window_set_current_screen(2)
	DisplayServer.window_set_position(Vector2(3000, 0))
	
	var count = DisplayServer.get_screen_count()
	print("🖥️ Screen count:", count)
	for i in count:
		var size = DisplayServer.screen_get_size(i)
		var pos = DisplayServer.screen_get_position(i)
		print("Screen %d: size=%s, position=%s" % [i, size, pos])
		
func print_node_tree(node: Node, indent: int) -> void:
	var prefix = "├── " if indent > 0 else ""
	var indentation = "    ".repeat(indent)
	var line = "%s%s (%s)" % [indentation + prefix, node.name, node.get_class()]
	print(line)

	for child in node.get_children():
		if child is Node:
			print_node_tree(child, indent + 1)

func _print_scene_tree(node: Node, indent: int = 0):
	print("  ".repeat(indent) + node.name)  # Print node with indentation
	for child in node.get_children():
		_print_scene_tree(child, indent + 1)

func print_directory_structure(path: String = "res://", indent_level: int = 0) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		print("❌ Failed to open directory:", path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue

		var full_path = path + "/" + file_name
		var indent = "  ".repeat(indent_level)

		if dir.current_is_dir():
			print(indent + "📁 " + file_name)
			print_directory_structure(full_path, indent_level + 1)
		else:
			if not file_name.ends_with(".import"):
				print(indent + "📄 " + file_name)

		file_name = dir.get_next()

	dir.list_dir_end()
