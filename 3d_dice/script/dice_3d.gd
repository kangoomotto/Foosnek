extends RigidBody3D

@onready var raycasts = $RayCasts.get_children()
@export_range(0.0, 10.0) var randomness_force := 5.0
@export_range(0.0, 10.0) var randomness_spin := 5.0

var can_click: bool = true
var start_position
var roll_strength = 250
var is_rolling = false

signal roll_finished(value: int)

func _ready():
	start_position = global_position
	input_ray_pickable = true  # Allow clicking

func roll():
	if not can_click:
		return
	can_click = false
	is_rolling = true
	sleeping = false
	freeze = false

	# Random start position
	transform.origin = start_position + Vector3(
		randf_range(-0.3, 0.3),
		5,
		randf_range(-0.3, 0.3)
	)

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	# Random orientation
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, TAU)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0, TAU)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, TAU)) * transform.basis

	# Impulse
	var throw_vector = Vector3(
		randf_range(-5, 5),
		5,
		randf_range(-15, 15)
	).normalized() * randf_range(roll_strength * 1.5, roll_strength * 2.5)
	apply_impulse(Vector3.ZERO, throw_vector)

	# Spin
	angular_velocity = Vector3(
		randf_range(-10, 10),
		randf_range(-20, 20),
		randf_range(-25, 50)
	)

func _physics_process(_delta):
	if is_rolling and linear_velocity.length() < 0.05 and angular_velocity.length() < 0.05:
		is_rolling = false
		for ray in raycasts:
			if ray.is_colliding():
				var result = ray.opposite_side

				# 🎯 Override result only at emission if debug mode active
				if EventsBus.DEBUG_MODE:
					print("🎯 DEBUG: Forcing dice roll to:", EventsBus.debug_force_dice)
					result = EventsBus.debug_force_dice

				print("🎲 Dice final result sent:", result)
				roll_finished.emit(result)
				EventsBus.dice_rolled.emit(result)
				can_click = true
				break
