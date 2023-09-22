extends GPUParticles2D

func _on_timer_timeout():
	queue_free()

func set_direct_hit():
	$LightOccluder2D.queue_free()
