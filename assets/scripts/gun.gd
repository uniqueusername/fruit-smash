extends Node2D

@export var ROCKET_SPEED = 5
@export var CHARGE_TIME = 0.5
@export var COOLDOWN = 0
@onready var LASER_LENGTH = $RayCast2D.target_position.y
const TRAIL_TIME = 0.5
const CHARGE_WIDTH = 4
const FIRE_WIDTH = 6

var projectile = load("res://scenes/objects/projectile.tscn")
var fire_sprite = load("res://scenes/objects/fire_sprite.tscn")
var explosion = load("res://scenes/objects/explosion.tscn")
var particles = load("res://scenes/objects/explosion_particles.tscn")
@onready var settings = get_node("/root/Settings")

signal fired
var charge = 0
var cooldown = 0
var charging = false
var firing = false

func _ready():
	$charge_sprite.visible = false
	$RayCast2D.add_exception(get_parent())

func _process(delta):
	cooldown -= delta
	if cooldown < 0: cooldown = 0
	var laser_length = LASER_LENGTH
	if $RayCast2D.is_colliding():
		if get_parent().has_powerup(Constants.PowerupType.BREACH):
			laser_length = LASER_LENGTH
		else:
			laser_length = global_position.distance_to($RayCast2D.get_collision_point())
	
	if charging:
		if charge < CHARGE_TIME:
			$charge_sprite.visible = int(round(20*charge)) % 2 == 0
			$charge_sprite.region_rect = Rect2(
				CHARGE_WIDTH/2.0, 0,
				lerpf($charge_sprite.region_rect.size.x, CHARGE_WIDTH, 0.001 / CHARGE_TIME),
				laser_length
			)
			charge += delta
		else:
			# reset charge state
			$charge_sprite.visible = false
			charging = false
			charge = 0
			
			# fire
			if cooldown == 0: firing = true
	
	if firing:
		cooldown = COOLDOWN
		draw_laser(laser_length)
		spawn_explosion()
		fired.emit()
		firing = false
		
		match get_parent().get_meta("controller_id"):
			0:
				get_parent().get_node("p1_audio").get_node("fire_audio").playing = true
			1:
				get_parent().get_node("p2_audio").get_node("fire_audio").playing = true

func shoot():
	charging = true
	$charge_sprite.region_rect = Rect2(CHARGE_WIDTH/2.0, 0, 0.1, LASER_LENGTH)
	
	match get_parent().get_meta("controller_id"):
		0:
			get_parent().get_node("p1_audio").get_node("charge_audio").playing = true
		1:
			get_parent().get_node("p2_audio").get_node("charge_audio").playing = true
	

func cancel():
	$charge_sprite.visible = false
	charging = false
	charge = 0
	
	match get_parent().get_meta("controller_id"):
		0:
			get_parent().get_node("p1_audio").get_node("charge_audio").playing = false
		1:
			get_parent().get_node("p2_audio").get_node("charge_audio").playing = false

func is_charging():
	return charging

func fire_rocket():
	var proj = projectile.instantiate()
	add_child(proj)
	proj.global_position = global_position
	proj.rotation = rotation
	proj.add_collision_exception_with(get_parent())
	proj.set_velocity(ROCKET_SPEED * Vector2.from_angle(rotation+PI/2))

func draw_laser(length):
	var laser = fire_sprite.instantiate()
	add_child(laser)
	laser.region_rect = Rect2(FIRE_WIDTH/2.0, 0, FIRE_WIDTH, length)
	laser.global_transform = $charge_sprite.global_transform
	laser.set_trail_time(TRAIL_TIME)
	
func spawn_explosion():
	while $RayCast2D.is_colliding():
		var boom = explosion.instantiate()
		add_child(boom)
		if get_parent().has_powerup(Constants.PowerupType.EX2): boom.set_ex2()
		boom.global_position = $RayCast2D.get_collision_point()
		boom.rotation = $RayCast2D.get_collision_normal().angle() + PI/2
		
		if ($RayCast2D.get_collider().scene_file_path != "res://scenes/objects/walls.tscn" and (
				$RayCast2D.get_collider().get_collision_layer_value(2) or
				$RayCast2D.get_collider().get_collision_layer_value(3) or
				$RayCast2D.get_collider().get_collision_layer_value(4))):
			boom.set_direct_hit()
		
		if settings.particles and !get_parent().has_powerup(Constants.PowerupType.BREACH):
			var particle = particles.instantiate()
			add_child(particle)
			particle.restart()
			particle.global_position = $RayCast2D.get_collision_point()
			particle.rotation = $RayCast2D.get_collision_normal().angle() + PI/2

			if ($RayCast2D.get_collider().scene_file_path == 
				"res://scenes/objects/player.tscn"):
				particle.set_direct_hit()
		else:
			boom.set_no_particles()	
		
		if !get_parent().has_powerup(Constants.PowerupType.BREACH): return
		$RayCast2D.global_position = $RayCast2D.get_collision_point() + Vector2.RIGHT
		$RayCast2D.force_raycast_update()
		
	$RayCast2D.rotation += PI
		
	while $RayCast2D.is_colliding():
		var boom = explosion.instantiate()
		add_child(boom)
		boom.global_position = $RayCast2D.get_collision_point()
		boom.rotation = $RayCast2D.get_collision_normal().angle() + PI/2
		
		if ($RayCast2D.get_collider().scene_file_path == 
			"res://scenes/objects/player.tscn"):
			boom.set_direct_hit()
		
		boom.set_no_particles()	
			
		$RayCast2D.global_position = $RayCast2D.get_collision_point() + Vector2.RIGHT
		$RayCast2D.force_raycast_update()

	$RayCast2D.rotation = 0
	$RayCast2D.position = Vector2.ZERO
