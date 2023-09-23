extends CharacterBody2D

# constants
@export var JUMP_VELOCITY = -370.0
@export var ACCEL_SPEED = 25
@export var MAX_SPEED = 260
@export var DECEL_SPEED = 10
@export var AIR_SPEED = 0.4
@export var COYOTE_TIME = 0.1
@export var HOOK_LENGTH = 250
@export var CHAIN_PULL = 25
@export var HOOK_GRAV = 1
@export var HOOK_VERT_FORCE = 1.5
@export var HOOK_HORIZ_FORCE = 1.0
@export var RECOIL = 1.0
@export var METER_SENSITIVITY = 0.01 # how much it affects movement
@export var METER_RATE = 0.01 # how fast it changes
@export var MAX_STOCK = 3
@export var INVUL_TIMER = 1.5
@export var SELF_DMG_MULT = 0
@export var MAX_METER_DIFF = 50

const ROTATE_SPEED = 0.001
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var settings = get_node("/root/Settings")

# variables
signal meter_changed
signal stock_changed
signal dead
var recoil = false
var jumping = false
var invulnerable = false
var invul_timer = INVUL_TIMER
var gravity = GRAVITY
var coyote_timer = COYOTE_TIME
var spawn_pos
var meter = 0
var stock = MAX_STOCK
@onready var sticky_ray = $sticky_ray
@onready var hook = $chain
@onready var hook_ray = $hook_ray
@onready var gun = $gun

func _ready():
	spawn_pos = position
	meter_changed.emit(0)
	stock_changed.emit(MAX_STOCK)

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
	var hook_cast = false
	var hook_released = false
	var laser_shot = false
	var laser_cancelled = false
	
	if get_meta("mnk_enabled"):
		# mnk controls
		x_input = Input.get_axis("ui_left", "ui_right")
		aim_input = get_local_mouse_position()
		jump_input = Input.is_action_just_pressed("ui_up")
		hook_cast = Input.is_action_just_pressed("mnk_hook")
		hook_released = Input.is_action_just_released("mnk_hook")
		laser_shot = Input.is_action_just_pressed("mnk_shoot")
		laser_cancelled = Input.is_action_just_released("mnk_shoot")

	else:
		# controller controls
		match get_meta("controller_id"):
			0:
				x_input = Input.get_axis("p1_move_left", "p1_move_right")
				aim_input = Input.get_vector("p1_aim_left", "p1_aim_right", "p1_aim_up", "p1_aim_down")
				jump_input = Input.is_action_just_pressed("p1_jump")
				hook_cast = Input.is_action_just_pressed("p1_hook")
				hook_released = Input.is_action_just_released("p1_hook")
				laser_shot = Input.is_action_just_pressed("p1_shoot")
				laser_cancelled = Input.is_action_just_released("p1_shoot")
			1:
				x_input = Input.get_axis("p2_move_left", "p2_move_right")
				aim_input = Input.get_vector("p2_aim_left", "p2_aim_right", "p2_aim_up", "p2_aim_down")
				jump_input = Input.is_action_just_pressed("p2_jump")
				hook_cast = Input.is_action_just_pressed("p2_hook")
				hook_released = Input.is_action_just_released("p2_hook")
				laser_shot = Input.is_action_just_pressed("p2_shoot")
				laser_cancelled = Input.is_action_just_released("p2_shoot")
	
	aim_input = HOOK_LENGTH / aim_input.length() * aim_input
	hook_ray.set_target_position(aim_input)
	gun.rotation = aim_input.angle() - PI/2
	$target.rotation = hook_ray.get_target_position().angle() + PI/2
	$reticle.rotation = hook_ray.get_target_position().angle() + PI/2
	$target.position = hook_ray.get_target_position() * 0.98
	$reticle.position = hook_ray.get_target_position()
	
	# reset coyote timer when we land
	if is_on_floor():
		jumping = false
		coyote_timer = COYOTE_TIME
		
	# do recoil
	if recoil:
		velocity -= RECOIL * aim_input
		recoil = false
	
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
		
	# cast hook
	if (hook_cast and aim_input.length() > 0.05 and
		hook_ray.is_colliding()):
		hook.shoot(aim_input)
	if hook_released:
		hook.release()
		
	if laser_shot and aim_input.length() > 0.05:
		$gun.shoot()
		$reticle.visible = false
		$target.visible = false
	if laser_cancelled:
		$gun.cancel()
		
	if not $gun.is_charging():
		$reticle.visible = true
		$target.visible = true

	move_and_slide()
	
	if (settings.particles and 
		get_slide_collision_count() > 0 and 
		get_slide_collision(0)):
		if get_slide_collision(0).get_remainder().length() > 5:
			$GPUParticles2D.emitting = true
	
func  _process(delta):
	if stock == 0:
		dead.emit()
		
	if invul_timer <= 0:
		invulnerable = false
	else:
		invul_timer -= delta
		$Sprite2D.visible = int(round(20*invul_timer)) % 2 == 0
#	if get_meta("mnk_enabled"):
#		if Input.is_action_just_pressed("mnk_reset"):
#			reset()
#
#	else:
#		match get_meta("controller_id"):
#			0:
#				if Input.is_action_just_pressed("p1_reset"):
#					reset()
#			1:
#				if Input.is_action_just_pressed("p2_reset"):
#					reset()
					
func force_release():
	hook.release()

func _on_gun_fired():
	recoil = true

func explode(explosion_dir, self_dmg = false):
	if not invulnerable:
		set_velocity(velocity + (METER_SENSITIVITY * meter + 1) * explosion_dir)
		var meter_diff = int(METER_RATE * explosion_dir.length())
		if self_dmg: meter_diff *= SELF_DMG_MULT
		if meter_diff > MAX_METER_DIFF: meter_diff = MAX_METER_DIFF
		meter += meter_diff
		meter_changed.emit(meter)

func reset():
	position = spawn_pos
	velocity = Vector2()
	$Sprite2D.rotation = 0
	stock -= 1
	meter = 0
	stock_changed.emit(stock)
	meter_changed.emit(meter)
	invulnerable = true
	invul_timer = INVUL_TIMER

func _on_blast_body_entered(body):
	if body == self:
		reset()
