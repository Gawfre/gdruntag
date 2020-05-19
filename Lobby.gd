extends Node

const PSEUDO = "Robin"
const COLOR = Color("FF0000") #Color8(255, 0, 0)

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
# dict that gives infos for each player, provided its ID
var player_info = {}
# our infos
var my_info = {name = PSEUDO, color = COLOR}

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)
	
func _player_disconnected(id):
	# Delete player and its datas from list player_info
	player_info.erase(id)
	
func connected_ok():
	pass # Only called on clients
	
func _server_disconnected():
	pass # Server kicked our client
	
func _connected_fail():
	pass # Server unreached
	
remote func register_player(info):
	# Get id of who called the function (RPC sender)
	var id = get_tree().get_rpc_sender_id()
	# Store new player's info 
	player_info[id] = info
	print(player_info)
	
	#Update UI with new player name	
	
#Find a way to display names

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 22033
const MAX_PLAYERS = 8

func _on_HostButton_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer


func _on_JoinButton_pressed():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer
