extends Camera2D

# constants
@export var ZOOM_OFFSET = 0.9
@export var ZOOM_SMOOTHING = 0.9

# variables
var players_group
var player_rect = Rect2()
var viewport_rect

func _ready():
	# expects a group holding all players called "players"
	players_group = get_node("../players")
	viewport_rect = get_viewport_rect()

func _process(delta):
	# find the bounding coordinates of all players
	player_rect = Rect2(players_group.get_child(0).global_position, Vector2())
	for i in players_group.get_child_count():
		if i == 0: continue
		player_rect = player_rect.expand(players_group.get_child(i).global_position)
		
	position = player_rect.get_center()
	var zoom_num = 1 / max(
		player_rect.size.x / viewport_rect.size.x + ZOOM_OFFSET,
		player_rect.size.y / viewport_rect.size.y + ZOOM_OFFSET
	)	
	zoom = lerp(zoom, Vector2(zoom_num, zoom_num), 1/ZOOM_SMOOTHING * delta)
