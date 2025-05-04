extends Label

func _process(delta):
	if Input.is_action_just_pressed("mnk_start"):
			get_tree().change_scene_to_file("res://scenes/levels/map3.tscn")
		
	var time_left = int(get_parent().get_node("Timer").time_left)
	text = str(time_left)
	
	if time_left < 40:
		get_parent().get_node("meter").visible = true
		
	if time_left < 20:
		get_parent().get_node("hook").visible = true
