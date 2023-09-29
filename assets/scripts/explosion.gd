extends Node2D

@export var EXPLOSION_POWER = 50
@export var EX2_COLOR = Color(1, 0, 0.28, 1)
const LIFESPAN = 0.1
const EX2_MULT = 2.0
const RADIUS = 50
const BASE_SCALE = Vector2(1.5, 1.5)

var direct_hit = false
var no_particles = false
var lifespan = LIFESPAN

func _physics_process(delta):
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		var dir = global_position.direction_to(body.global_position)
		if direct_hit or dir.dot(Vector2.from_angle(rotation - PI/2)) >= 0:
			var dist = global_position.distance_to(body.global_position)
			if body.get_collision_layer_value(2):
				body.force_release()
				body.explode(
					EXPLOSION_POWER * $Area2D/CollisionShape2D.shape.radius / dist * dir,
					body == get_parent().get_parent()
				)				

			if body.get_collision_layer_value(3): # grappling hook
				# unhook if we shoot the tip
				body.get_parent().get_parent().force_release()
				
			if body.get_collision_layer_value(4): # powerup
				body.queue_free()
				get_parent().get_parent().get_powerup(body.get_type())
			
	lifespan -= delta
	if lifespan < 0:
		$Area2D/CollisionShape2D.shape.radius = RADIUS
		$Sprite2D.scale = BASE_SCALE
		$Sprite2D.modulate = Color.WHITE
		queue_free()
		
func _process(delta):
	$Sprite2D.modulate.a -= delta * 5

func set_direct_hit():
	direct_hit = true

func set_no_particles():
	$Sprite2D.visible = true
	no_particles = true

func set_ex2():
	EXPLOSION_POWER *= EX2_MULT
	$Sprite2D.modulate = EX2_COLOR
#	$Area2D/CollisionShape2D.shape.radius *= EX2_MULT
#	$Sprite2D.scale *= EX2_MULT
