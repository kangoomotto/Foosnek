extends Node3D

@onready var dice: Node = $Dice
@onready var result_label: Label = $Result/Result_Label

func _ready():
	result_label.text = "Roll the dice!"
	result_label.visible = true

	if dice:
		
		if not dice.is_connected("roll_finished", Callable(self, "_on_dice_roll_finished")):
			dice.connect("roll_finished", Callable(self, "_on_dice_roll_finished"))
			
	# DiceBox.gd
	EventsBus.dice_roll_started.connect(func():
		roll_dice()
	)
	

func roll_dice():
	if dice and dice.has_method("roll"):
		dice.roll()

func _on_dice_roll_finished(value: int):
	result_label.text = str(value)
	EventsBus.dice_rolled.emit(value)
