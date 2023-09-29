extends Camera2D

# constants
@export var ZOOM_OFFSET = 0.9
@export var ZOOM_SMOOTHING = 0.9
@export var FALL_CAM_DISTANCE = 500
@export var SHAKE_TIME = 0.5
@export var SHAKE_POWER = 100.0

# variables
var players_group
var player_rect = Rect2()
var viewport_rect
var fall_cam = false
var shaking = false
var shake_time = SHAKE_TIME
var zoom_smoothing = ZOOM_SMOOTHING

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
		fall_cam = players_group.get_child(i).global_position.y > FALL_CAM_DISTANCE
		
	position = player_rect.get_center()
	var zoom_num = 1 / max(
		player_rect.size.x / viewport_rect.size.x + ZOOM_OFFSET,
		player_rect.size.y / viewport_rect.size.y + ZOOM_OFFSET
	)
	zoom = lerp(zoom, Vector2(zoom_num, zoom_num), 1/zoom_smoothing * delta)
	
	if is_nan(zoom.x) or is_nan(zoom.y):
		zoom = Vector2(0.1, 0.1)
	if fall_cam: zoom_smoothing = lerp(zoom_smoothing, 0.01, 0.1)
	else: zoom_smoothing = ZOOM_SMOOTHING
	
	if shaking:
		if shake_time >= 0:
			offset = SHAKE_POWER * shake_time * Vector2(randf(), randf())
			shake_time -= delta
		else:
			shaking = false
			shake_time = SHAKE_TIME

func _on_blast_body_entered(body):
	shaking = true
