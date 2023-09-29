extends Node2D

@export var min_range = -500
@export var max_range = 500
var powerup = load("res://scenes/objects/powerup.tscn")

func _on_timer_timeout():
	position.x = randi_range(min_range, max_range)
	var guy = powerup.instantiate()
	add_child(guy)
	guy.set_type(randi_range(0, Constants.PowerupType.size()-1))
	guy.global_position = global_position
