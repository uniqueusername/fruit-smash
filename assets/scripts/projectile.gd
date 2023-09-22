extends CharacterBody2D

func _physics_process(delta):
	move_and_collide(velocity)

func _on_timer_timeout():
	queue_free()
