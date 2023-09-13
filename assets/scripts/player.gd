extends CharacterBody2D

@export var JUMP_VELOCITY = -400.0
@export var ACCEL_SPEED = 100
@export var MAX_SPEED = 300
@export var DECEL_SPEED = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# collect inputs
	var x_input = Vector2.ZERO

	if get_meta("mnk_enabled"):
		x_input = Input.get_axis("ui_left", "ui_right")
	else:
		match get_meta("controller_id"):
			0:
				x_input = Input.get_axis("p1_move_left", "p1_move_right")
			1:
				x_input = Input.get_axis("p2_move_left", "p2_move_right")
	
	# apply inputs
	if x_input:
		velocity.x = move_toward(velocity.x, x_input * MAX_SPEED, ACCEL_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL_SPEED)

	# Handle Jump.
	'''if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY'''

	move_and_slide()
