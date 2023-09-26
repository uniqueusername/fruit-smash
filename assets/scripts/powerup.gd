extends RigidBody2D

@export var ROLL_SPEED = 100

@onready var sprites = [$breach_sprite, $ex2_sprite]
var type: Constants.PowerupType
var should_roll = true
var direction = 0

func _physics_process(delta):
	linear_velocity.x = direction
	if linear_velocity.x == 0: direction = -direction

	if should_roll and $raycasts/floor_raycast.is_colliding():
		roll_randomly()
		should_roll = false
		
	if !$raycasts/floor_raycast.is_colliding():
		should_roll = true
	else:
		if $raycasts/left_raycast.is_colliding():
			direction = ROLL_SPEED
		elif $raycasts/right_raycast.is_colliding():
			direction = -ROLL_SPEED

func roll_randomly():
	if randf() < 0.5:
		direction = -ROLL_SPEED
	else:
		direction = ROLL_SPEED

func set_type(type: Constants.PowerupType):
	self.type = type
	sprites[type].visible = true
	
func get_type():
	return type
