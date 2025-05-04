extends Label

@onready var players = get_parent().get_parent().get_node("players")

func _ready():
	players.get_node("player").set_disabled(true)
	players.get_node("player2").set_disabled(true)

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
