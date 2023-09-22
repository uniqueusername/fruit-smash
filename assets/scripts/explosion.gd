extends Node2D

@export var EXPLOSION_POWER = 100
const LIFESPAN = 0.1

var direct_hit = false
var lifespan = LIFESPAN

func _physics_process(delta):
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		var dir = global_position.direction_to(body.global_position)
		if direct_hit or dir.dot(Vector2.from_angle(rotation - PI/2)) >= 0:
			var dist = global_position.distance_to(body.global_position)
			if body.scene_file_path == "res://scenes/objects/player.tscn":
				body.force_release()
			body.set_velocity(body.velocity + EXPLOSION_POWER * $Area2D/CollisionShape2D.shape.radius / dist * dir)
			
	lifespan -= delta
	if lifespan < 0:
		queue_free()

func set_direct_hit():
	direct_hit = true
