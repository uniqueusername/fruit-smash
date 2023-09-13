extends CharacterBody2D

# constants
@export var JUMP_VELOCITY = -400.0
@export var ACCEL_SPEED = 100
@export var MAX_SPEED = 300
@export var DECEL_SPEED = 100
@export var AIR_SPEED = 0.85

const ROTATE_SPEED = 0.001

# variables
var jumping = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# collect inputs
	var x_input = Vector2.ZERO
	var jump_input = false
	if get_meta("mnk_enabled"):
		# mnk controls
		x_input = Input.get_axis("ui_left", "ui_right")
		jump_input = Input.is_action_just_pressed("ui_up")
	else:
		# controller controls
		match get_meta("controller_id"):
			0:
				x_input = Input.get_axis("p1_move_left", "p1_move_right")
				jump_input = Input.is_action_just_pressed("p1_jump")
			1:
				x_input = Input.get_axis("p2_move_left", "p2_move_right")
				jump_input = Input.is_action_just_pressed("p2_jump")
				
		if jump_input and !is_on_floor():
			jumping = true
	
	if is_on_floor():
		jumping = false
	
	# apply inputs
	if x_input:
		if jumping:
			velocity.x = move_toward(velocity.x, x_input * MAX_SPEED, ACCEL_SPEED)
		else:
			velocity.x = move_toward(velocity.x, x_input * MAX_SPEED, AIR_SPEED * ACCEL_SPEED)
	else:
		if jumping:
			velocity.x = move_toward(velocity.x, 0, DECEL_SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_SPEED * DECEL_SPEED)

	$Sprite2D.rotation += velocity.x * ROTATE_SPEED

	if jump_input and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	
