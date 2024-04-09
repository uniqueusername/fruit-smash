extends Node2D

var player_controllers = [-1, -1]

func _ready():
	var controllers = Input.get_connected_joypads()
	
	if controllers.size() == 0:
		$player.set_controller(0, true)
		$player2.set_controller(1, false)
	elif controllers.size() == 1:
		var id = controllers[0]
		player_controllers[0] = id
		$player.set_controller(controllers[0], false)
		$player2.set_controller(1 if id == 0 else 0, true)
	elif controllers.size() >= 2:
		player_controllers[0] = controllers[0]
		player_controllers[1] = controllers[1]
		$player.set_controller(player_controllers[0], false)
		$player2.set_controller(player_controllers[1], false)
		
	Input.joy_connection_changed.connect(update_controllers)

func update_controllers(id: int, connected: bool):
	if connected:
		# this controller is already assigned
		if player_controllers.has(id):
			return
			
		# find a player for the new controller
		if player_controllers[0] == -1:
			player_controllers[0] = id
			$player.set_controller(player_controllers[0], false)
			$player2.set_controller(player_controllers[1], true)
		elif player_controllers[1] == -1:
			player_controllers[1] = id
			$player2.set_controller(player_controllers[1], false)
	

