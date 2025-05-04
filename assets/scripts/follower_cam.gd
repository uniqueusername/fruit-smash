extends Camera2D

# constants
@export var ZOOM_OFFSET = 0.9
@export var ZOOM_SMOOTHING = 0.9
@export var FALL_CAM_DISTANCE = 500
@export var SHAKE_TIME = 0.5
@export var SHAKE_POWER = 100.0

@export var background: CanvasLayer

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
	
	var falling = false
	for i in players_group.get_child_count():
		falling = falling or (players_group.get_child(i).global_position.y > FALL_CAM_DISTANCE)
		if i == 0: continue
		player_rect = player_rect.expand(players_group.get_child(i).global_position)
	fall_cam = falling
		
	position = player_rect.get_center()
	var zoom_num = 1 / max(
		player_rect.size.x / viewport_rect.size.x + ZOOM_OFFSET,
		player_rect.size.y / viewport_rect.size.y + ZOOM_OFFSET
	)
	zoom = lerp(zoom, Vector2(zoom_num, zoom_num), 1/zoom_smoothing * delta)
	
	if is_nan(zoom.x) or is_nan(zoom.y):
		zoom = Vector2(0.1, 0.1)
	if fall_cam: zoom_smoothing = 0.01
	else: zoom_smoothing = ZOOM_SMOOTHING
	
	if shaking:
		if shake_time >= 0:
			offset = SHAKE_POWER * shake_time * Vector2(randf(), randf())
			shake_time -= delta
		else:
			shaking = false
			shake_time = SHAKE_TIME
			
	if background: _handle_parallax()

func _on_blast_body_entered(body):
	shaking = true
	
func _handle_parallax():
	var layers = background.get_node("layers")
	for i in range(layers.get_child_count()):
		layers.get_child(i).set_pivot_goal(Vector2(
			i*position.x*0.3, 
#			clamp(-i*position.y*0.05, 200, -50)
			(layers.get_child_count()-i)*position.y*0.05
		))
