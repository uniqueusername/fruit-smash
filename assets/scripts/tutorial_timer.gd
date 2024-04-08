extends Label

@onready var players = get_parent().get_node("players")

func _ready():
	var controllers = Input.get_connected_joypads()
	if controllers.size() == 0:
		players.get_node("player").set_controller(0, true)
		players.get_node("player2").set_controller(1, false)
	elif controllers.size() == 1:
		var id = controllers[0]
		players.get_node("player").set_controller(0 if id == 1 else 1, true)
		players.get_node("player2").set_controller(id, false)
	elif controllers.size() >= 2:
		players.get_node("player").set_controller(0, false)
		players.get_node("player2").set_controller(1, false)
		
	Input.joy_connection_changed.connect(connect_second_controller)

func _process(delta):
	if Input.is_action_just_pressed("mnk_start"):
			get_tree().change_scene_to_file("res://scenes/levels/map3.tscn")
		
	var time_left = int(get_parent().get_node("Timer").time_left)
	text = str(time_left)
	
	if time_left < 40:
		get_parent().get_node("meter").visible = true
		
	if time_left < 20:
		get_parent().get_node("hook").visible = true

func _on_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/levels/map3.tscn")

func connect_second_controller(id: int, connected: bool):
	if connected:
		if id == 0 or id == 1:
			players.get_node("player2").set_controller(id, false)
