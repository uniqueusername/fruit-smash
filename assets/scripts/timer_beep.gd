extends AudioStreamPlayer2D

func _ready():
	play()

func _on_timer_timeout():
	play()
