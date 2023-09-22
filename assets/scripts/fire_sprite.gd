extends Sprite2D

var trail_time = 2

func _process(delta):
	modulate = Color(1, 1, 1, lerpf(modulate.a, 0, delta * trail_time))
	if modulate.a <= 0:
		queue_free()

func set_trail_time(length: float):
	if length != 0:
		trail_time = 1 / length
