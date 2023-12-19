extends Node

@onready var player = get_parent()

func _physics_process(delta):
	player.velocity.x = 100
	player.move_and_slide()
