extends Label

func _process(delta):
	var tl = int($Timer.time_left)
	if tl == 0:
		text = "GO"
	else:
		text = str(int($Timer.time_left))

func _on_timer_timeout():
	queue_free()
