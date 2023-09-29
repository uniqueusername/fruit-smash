extends Label

func _process(delta):
	var time_left = int(get_parent().get_node("Timer").time_left)
	text = str(time_left)
	
	if time_left < 40:
		get_parent().get_node("meter").visible = true
		
	if time_left < 20:
		get_parent().get_node("hook").visible = true

func _on_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/levels/map3.tscn")
