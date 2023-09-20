extends CharacterBody2D

# constants
@export var JUMP_VELOCITY = -370.0
@export var ACCEL_SPEED = 25
@export var MAX_SPEED = 260
@export var DECEL_SPEED = 10
@export var AIR_SPEED = 0.4
@export var COYOTE_TIME = 0.1
@export var HOOK_LENGTH = 100
@export var CHAIN_PULL = 35
@export var HOOK_GRAV = 0.5
@export var HOOK_VERT_FORCE = 1.5
@export var HOOK_HORIZ_FORCE = 1.0

const ROTATE_SPEED = 0.001
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")

# variables
var jumping = false
var gravity = GRAVITY
var coyote_timer 
var spawn_pos
var sticky_ray
var hook
var hook_ray
var target

func _ready():
	coyote_timer = COYOTE_TIME
	spawn_pos = position
	sticky_ray = $sticky_ray
	hook_ray = $hook_ray
	hook = $chain
	target = $target

func _physics_process(delta):
	# add gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		
		# subtract from coyote timer if falling off something
		if not jumping:
			coyote_timer -= delta
	
	# collect inputs
	var x_input = Vector2.ZERO
	var aim_input = Vector2.ZERO
	var jump_input = false
	var jump_released = false
	var hook_cast = false
	var hook_released = false
	
	if get_meta("mnk_enabled"):
		# mnk controls
		x_input = Input.get_axis("ui_left", "ui_right")
		aim_input = get_local_mouse_position()
		jump_input = Input.is_action_just_pressed("ui_up")
		jump_released = Input.is_action_just_released("ui_up")
		hook_cast = Input.is_action_just_pressed("mnk_hook")
		hook_released = Input.is_action_just_released("mnk_hook")

	else:
		# controller controls
		match get_meta("controller_id"):
			0:
				x_input = Input.get_axis("p1_move_left", "p1_move_right")
				aim_input = Input.get_vector("p1_aim_left", "p1_aim_right", "p1_aim_up", "p1_aim_down")
				jump_input = Input.is_action_just_pressed("p1_jump")
				jump_released = Input.is_action_just_released("p1_jump")
				hook_cast = Input.is_action_just_pressed("p1_hook")
				hook_released = Input.is_action_just_released("p1_hook")
			1:
				x_input = Input.get_axis("p2_move_left", "p2_move_right")
				aim_input = Input.get_vector("p1_aim_left", "p1_aim_right", "p1_aim_up", "p1_aim_down")
				jump_input = Input.is_action_just_pressed("p2_jump")
				jump_released = Input.is_action_just_released("p2_jump")
				hook_cast = Input.is_action_just_pressed("p2_hook")
				hook_released = Input.is_action_just_released("p2_hook")
	
	aim_input = HOOK_LENGTH / aim_input.length() * aim_input
	hook_ray.set_target_position(aim_input)
	target.rotation = hook_ray.get_target_position().angle() + PI/2
	$reticle.rotation = hook_ray.get_target_position().angle() + PI/2
	target.position = hook_ray.get_target_position() * 0.98
	$reticle.position = hook_ray.get_target_position()

	
	# reset coyote timer when we land
	if is_on_floor():
		jumping = false
		coyote_timer = COYOTE_TIME
	
	# apply inputs
	if x_input:
		if sticky_ray.is_colliding():
			velocity.x = move_toward(velocity.x, x_input * MAX_SPEED, ACCEL_SPEED)
		else:
			velocity.x = move_toward(velocity.x, x_input * MAX_SPEED, AIR_SPEED * ACCEL_SPEED)
	else:
		if sticky_ray.is_colliding():
			velocity.x = move_toward(velocity.x, 0, DECEL_SPEED)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_SPEED * DECEL_SPEED)
		
	var chain_velocity := Vector2()
	if hook.hooked:
		chain_velocity = to_local(hook.tip).normalized() * CHAIN_PULL
		chain_velocity.y *= HOOK_VERT_FORCE
		chain_velocity.x *= HOOK_HORIZ_FORCE
		# nerf certain inputs if we are hooked
		gravity = GRAVITY * HOOK_GRAV
	else:
		chain_velocity = Vector2(0,0)
		gravity = GRAVITY
	velocity += chain_velocity

	# SPIN >:3
	$Sprite2D.rotation += velocity.x * ROTATE_SPEED

	# jump (and coyote jump!)
	# and sticky jump (make sure we are falling)
	if ((jump_input and is_on_floor())
		or (jump_input and not is_on_floor()
			and coyote_timer > 0 and not jumping)
		or (jump_input and sticky_ray.is_colliding()
			and velocity.y > 0)):
		velocity.y = JUMP_VELOCITY
		jumping = true
		
	# variable height jump ?
	'''if (jump_released
		and not is_on_floor()
		and velocity.y < 0):
		velocity.y = 0'''
		
	# cast hook
	if (hook_cast and aim_input.length() > 0.05 and
		hook_ray.is_colliding()):
		hook.shoot(aim_input)
	if hook_released:
		hook.release()

	move_and_slide()
	
func _process(delta):
	if get_meta("mnk_enabled"):
		if Input.is_action_just_pressed("mnk_reset"):
			position = spawn_pos
			
	else:
		match get_meta("controller_id"):
			0:
				if Input.is_action_just_pressed("p1_reset"):
					position = spawn_pos
			1:
				if Input.is_action_just_pressed("p2_reset"):
					position = spawn_pos
