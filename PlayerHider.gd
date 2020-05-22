extends "res://Player.gd"

var ACCELERATIONHIDER = 3000
var MAX_SPEEDHIDER = 500
var pos = Vector2()
var direction = Vector2()
var lifepoints = 100
var prev_lp = lifepoints
var detected = false

puppet var puppet_lp = lifepoints

func _ready():
	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #hide mouse
	

func _init():
	.ACCELERATION_set(ACCELERATIONHIDER)

func set_player_name(new_name):
	.set_player_name(new_name)
	
func _physics_process(_delta):
	if is_network_master():#get_tree().is_network_server():#
		#if nb_fdetected the same for 360 frames (6sec)
		if prev_lp == lifepoints:
			lifepoints += 1 * _delta / 8 #8sec = delta * 1/8
		prev_lp = lifepoints
		if lifepoints > 100:
			lifepoints = 100
		rset_unreliable("puppet_lp", lifepoints)
	else:
		lifepoints = puppet_lp
		#sync with pupped vars
	
	#var Player = get_tree().get_root().get_node("./Root/PlayerSeeker")
	#direction = (position - Player.position).normalized()
	#pos = position
	print(lifepoints)
	get_node("LP_Bar").update_lp(lifepoints)
	update()
	#IF LP < 0 BECOME SEEKER OBJECT
	
func detected(delta): #change in a detected? (true/false) and then update in _process?
	if get_tree().is_network_server(): #is_network_master():
		#++nb_fdetected
		#if nb_fdetected > 59:
		#	lifepoints -= 2
		#nb_fdetected %= 60
		lifepoints -= 2 * delta
		rset_unreliable("puppet_lp", lifepoints)
	else:
		lifepoints = puppet_lp
		#sync with pupped vars

