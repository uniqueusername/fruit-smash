extends Label

@onready var players = get_parent().get_node("players")

func _ready():
	players.get_node("player").set_disabled(true)
	players.get_node("player2").set_disabled(true)
	
	var controllers = Input.get_connected_joypads()
	if controllers.size() == 0:
		players.get_node("player").set_controller(-1, true)
	elif controllers.size() == 1:
		var id = controllers[0]
		players.get_node("player").set_controller(id, true)
		players.get_node("player2").set_controller(0 if id == 0 else 1, false)
	elif controllers.size() >= 2:
		players.get_node("player").set_controller(controllers[0], false)
		players.get_node("player2").set_controller(controllers[1], false)
		
	Input.joy_connection_changed.connect(connect_second_controller)

func _process(delta):
	var tl = int($Timer.time_left)
	if tl == 0:
		text = "GO"
	else:
		text = str(int($Timer.time_left))

func _on_timer_timeout():
	players.get_node("player").set_disabled(false)
	players.get_node("player2").set_disabled(false)
	queue_free()

func connect_second_controller(id: int, connected: bool):
	if connected:
		players.get_node("player2").set_controller(id, false)
