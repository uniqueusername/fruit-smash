extends RigidBody2D

const BLINK_TIMER = 0.1
@export var ROLL_SPEED = 100
@export var LOW_HEALTH = 3

@onready var sprites = [$sprites/breach_sprite, $sprites/ex2_sprite]
var type: Constants.PowerupType
var should_roll = true
var low_health = false
var direction = 0
var blink_timer = BLINK_TIMER

func _process(delta):
	if low_health:
		if blink_timer <= 0:
			$sprites.visible = !$sprites.visible
			blink_timer = BLINK_TIMER
		else:
			blink_timer -= delta

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

func set_type(type_: Constants.PowerupType):
	type = type_
	sprites[type].visible = true
	
func get_type():
	return type

func _on_timer_timeout():
	queue_free()

func _on_low_health_timer_timeout():
	low_health = true
	
func _on_static_body_2d_body_entered(body):
	body.get_powerup(type)
	queue_free()
