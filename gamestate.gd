extends Node

# Default game port. Can be any number between 1024 and 49151.
const DEFAULT_PORT = 38492#10567
var server_port = DEFAULT_PORT

# Max number of players.
const MAX_PEERS = 12

# Define roles
const SEEKER = "seeker"
const HIDER = "hider"

#Define Boosts
const BOOST_SPEED = "speed"
const BOOST_LIGHT = "light"

# Default role when connecting
const DEFAULT_ROLE = SEEKER
#const OTHER_ROLE = HIDER

# Files' const, allow to easily change them instead of searching and changing each issue/entry
const SEEKER_OBJ = "res://PlayerSeeker.tscn"
const HIDER_OBJ = "res://PlayerHider.tscn"
const MAP_OBJ = "res://World.tscn"

# Name for my player.
var player_name = "The Warrior"
var player_role = DEFAULT_ROLE

# Names for remote players in id:name format.
var players_count
var players = {}
var players_ready = []

# Each player's role [id:role]
var roles = {}

#Timer for hider
var timer_game
var delay_timer_game = 300.0 #60*5 -> 5 minutes

var upnp = null

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name, player_role)
	print(id)

func on_timeout_game_complete():
	print("LE TIMER EST TERMINÉ")
	end_game()

# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")
	print("connected")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(new_player_name, new_player_role):
	var id = get_tree().get_rpc_sender_id()
	print(id)
	players[id] = new_player_name
	roles[id] = new_player_role
	emit_signal("player_list_changed")
	
remote func register_self_player(new_player_name, new_player_role):
	var id = get_tree().get_network_unique_id()
	print(id)
	players[id] = new_player_name
	roles[id] = new_player_role
	emit_signal("player_list_changed")	


remote func register_role(role):
	# func called by a rpc_id each times someone updates its role
	var id = get_tree().get_rpc_sender_id()
	roles[id] = role
	print("roles : ", roles[id])
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")


remote func pre_start_game(spawn_points):
	# Change scene.
	var world = load(MAP_OBJ).instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("Lobby").hide()

	var player_scene = load(SEEKER_OBJ) if player_role == SEEKER else load(HIDER_OBJ) #ternary is like in python : [value_condition_true] if [condition] else [value_condition_false]

	for p_id in spawn_points:
		var spawn_pos = world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var player
		if p_id == get_tree().get_network_unique_id():
			player = player_scene.instance()
		else:
			player = (load(SEEKER_OBJ) if get_player_role_from_pid(p_id) == SEEKER else load(HIDER_OBJ)).instance()
		player.add_to_group("player")
		player.set_name(str(p_id)) # Use unique ID as node name.
		player.position=spawn_pos
		player.set_network_master(p_id) #set unique id as master.
		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name.
			player.set_player_name(player_name)
			player.get_node("Camera2D").make_current()
		else:
			# Otherwise set name from peer.
			player.set_player_name(players[p_id])

		world.get_node("Players").add_child(player)
	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


func set_timer():
	timer_game = Timer.new() #LAUNCH TIMER AND ADD AS A CHILD IN SCENE
	timer_game.set_one_shot(true)
	timer_game.set_wait_time(delay_timer_game)
	timer_game.connect("timeout", self, "on_timeout_game_complete")
	if get_tree().get_root().has_node("Root"): # Game is in progress.
		add_child(timer_game) 
	timer_game.start()


remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!
	set_timer()

remote func ready_to_start(id):
	assert(get_tree().is_network_server())
	#register_self_player(get_player_name(), get_player_role())
	if not id in players_ready:
		players_ready.append(id)
	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()
		players_ready.clear()


func launch_upnp(eport, iport):
	upnp = UPNP.new()
	#print("discover ", upnp.discover()) 
	#print("add ptfwd on ", port, " ", upnp.add_port_mapping(port))
	var discover = upnp.discover()
	if discover != UPNP.UPNP_RESULT_SUCCESS:
		print("discover failed ", discover) #UPNPResult.keys()[discover]
		return discover
	print("discover succeed")
	var ptfwd = upnp.add_port_mapping(eport, iport)
	if ptfwd != UPNP.UPNP_RESULT_SUCCESS:
		print("ptfwd failed ", ptfwd)
	else:
		server_port = iport
	return ptfwd
	

func host_game(new_player_name):
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(server_port, MAX_PEERS)
	get_tree().set_network_peer(host)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		print("exiting...")
		if upnp != null: #if upnp.get_gateway()
			print("delete ", upnp.delete_port_mapping(server_port))

func join_game(ip, port, new_player_name):
	player_name = new_player_name
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip, port)
	get_tree().set_network_peer(client)


func get_player_list():
	return players#.values()


func get_player_name():
	return player_name

func get_player_role():
	return player_role

	
func toggle_prole():
	if player_role == SEEKER:
		player_role = HIDER
	else:
		player_role = SEEKER
	rpc("register_role", player_role)
	emit_signal("player_list_changed") #to refrech locally since we only update the other clients here (func called by rpc is remote and not remotesync, so there's no local call)

func get_player_role_from_pname(player): #! IF 2 PLAYERS SHARE THE SAME NAME THIS WON'T WORK CORRECTLY
	for p in players:
		if players[p] == player:
			return roles[p]
	return "Error"
	
func get_player_role_from_pid(id):
	return roles[id]

func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points.
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)
	pre_start_game(spawn_points)


func end_game():
	if get_tree().get_root().has_node("Root"): # Game is in progress.
		# End it
		get_tree().get_root().get_node("Root").queue_free()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().reload_current_scene()
	
	#if server disconnect clients? if they don't disconnect by themselves
	emit_signal("game_ended")
	players.clear()


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"unregister_player") #edit func _player_disconnected
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "end_game")

func _physics_process(delta):
	check_all_seekers()

func check_all_seekers():
	var seeker_numbers = 0
	
	for N in get_tree().get_root().get_children():
		if N.get_child_count() > 0:
			if (N.get_name() == "Root"):
				for Y in N.get_children():
					if Y.get_child_count() > 0:
						#print("["+Y.get_name()+"]")
						if(Y.get_name() == "Players"):
							for U in Y.get_children():
								players_count = Y.get_child_count()
								print(U.name)
								if(U.filename == SEEKER_OBJ):
									seeker_numbers+=1
	#print("seeker numbers = ")
	#print(seeker_numbers)
	#print("players_count = ")
	#print(players_count)
	if(seeker_numbers == players_count):
		end_game()
