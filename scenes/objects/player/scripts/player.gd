extends CharacterBody2D

func _unhandled_input(event):
	if event.is_action_pressed("click"):
		Network.send_inputs.rpc([
			{
				"player": multiplayer.get_unique_id(),
				"input": "click"
			}
		])
