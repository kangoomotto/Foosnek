extends Area3D

@export var dice_ref: Node

func _ready():
	#print("ClickArea ready & pickable")
	#print("Script path:", self.get_script())
	if not dice_ref:
		dice_ref = get_node("../Dice")
	input_ray_pickable = true
	
	input_ray_pickable = true
	set_process_input(true)
	#print("ClickArea ready & pickable")
	
#func _input_event(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
#func _input_event(camera, event, pos, normal, shape_idx):
	#if event is InputEventMouseButton and event.pressed:
		#print("🖱 ClickArea pressed — emitting request_dice_roll")
		#EventsBus.request_dice_roll.emit()
		#print("📤 request_dice_roll emit() called")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		#print("🖱 UnhandledInput — emitting request_dice_roll")
		EventsBus.request_dice_roll.emit()
