extends Control

const PSEUDO = "Robin"
const COLOR = Color("FF0000") #Color8(255, 0, 0)

func _ready():
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	
	$PortInfoPopup.connect("config_success", self, "_on_server_setup_done")
	
	$Connection/Port.text = str(gamestate.DEFAULT_PORT)
	
	$Players/StartButton.disabled = true
	$Players/ChangeRole.disabled = true
	
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
	emit_signal("player_list_changed")
	print(player_info)
	
	#Update UI with new player name	
	
#Find a way to display names

func unregister_player(id):
	gamestate.players.erase(id)
	emit_signal("player_list_changed")

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 22033
const MAX_PLAYERS = 8

func refresh_lobby():
	var players = gamestate.get_player_list()
	#players.sort()
	$Players/List.clear()
	$Players/List.add_item(gamestate.get_player_name() + " [" + gamestate.get_player_role() + "] (You)")
	for p in players:
		$Players/List.add_item(players[p] + " [" + gamestate.get_player_role_from_pid(p)+ "]")
	
	$Players/StartButton.disabled = not get_tree().is_network_server()
	$Players/ChangeRole.disabled = false



func _on_HostButton_pressed():
	print("popuppressed")
	$PortInfoPopup.popup_centered()


func _on_JoinButton_pressed():
	print("joinpressed")
	var ip = $Connection/IPAddress.text
	var port = int($Connection/Port.text)
	var player_name = $Connection/Pseudo.text
	gamestate.join_game(ip, port, player_name)


func _on_StartButton_pressed():
	gamestate.begin_game()


func _on_ChangeRole_pressed():
	gamestate.toggle_prole()
	print("toggled_role: ", gamestate.get_player_role())
	

func _on_server_setup_done():
	print("configdone")
	var player_name = $Connection/Pseudo.text
	gamestate.host_game(player_name)
	refresh_lobby()
	print(get_tree().get_network_peer())
	$Connection/IPAddress.text = gamestate.upnp.query_external_address()
	$Connection/Port.text = String(gamestate.server_port)

func _on_PortInfoPopup_about_to_show():
	$Connection/HostButton.disabled = true
	$Connection/JoinButton.disabled = true
	$Connection/IPAddress.editable = false
	$Connection/Pseudo.editable = false
	$Connection/Port.editable = false


func _on_PortInfoPopup_popup_hide():
	$Connection/HostButton.disabled = false
	$Connection/JoinButton.disabled = false
	$Connection/IPAddress.editable = true
	$Connection/Pseudo.editable = true
	$Connection/Port.editable = true
