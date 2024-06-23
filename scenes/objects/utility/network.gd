extends Node

# server config
const PORT: int = 7000
const MAX_CONNECTIONS: int = 4
const DEFAULT_ADDRESS: String = "127.0.0.1"

# player config
const DEFAULT_NAME: String = "michael soft"
var player_info = { "name": DEFAULT_NAME }

# runtime vars
var players = {}
var input_history = []

func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# --- connections ---

func host_lobby():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error: return error
	multiplayer.multiplayer_peer = peer
	
	_distribute_player_info(multiplayer.get_unique_id(), player_info)

func join_lobby(address = ""):
	if address.is_empty(): address = DEFAULT_ADDRESS
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error: return error
	multiplayer.multiplayer_peer = peer

@rpc("any_peer", "call_local")
func start_game():
	get_tree().change_scene_to_file("res://scenes/maps/dev_map.tscn")

# called when any new peer joins the network
func _on_peer_connected(id):
	_register_player.rpc_id(id, player_info)

func _on_peer_disconnected(id):
	players.erase(id)

# called when *this peer* connects to a server
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	_distribute_player_info(new_player_id, new_player_info)

@rpc("any_peer", "call_remote", "reliable")
func _distribute_player_info(id, info):
	players[id] = info
	
	if multiplayer.is_server():
		for i in players:
			_distribute_player_info.rpc(i, players[i])

# --- input sharing ---

@rpc("any_peer", "call_local", "unreliable")
func send_inputs(inputs):
	if multiplayer.is_server():
		input_history.append(inputs)
