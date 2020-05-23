extends "res://Player.gd"

var ACCELERATIONHIDER = 3000
var MAX_SPEEDHIDER = 500
var pos = Vector2()
var direction = Vector2()
var lifepoints = 10 #100
var prev_lp = lifepoints
var detected = false
var new_inst = self
const type = gamestate.HIDER

puppet var puppet_lp = lifepoints

remotesync var remote_dtct = false
puppet var change = false

func _ready():
	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #hide mouse
	

func _init():
	.ACCELERATION_set(ACCELERATIONHIDER)

func set_player_name(new_name):
	.set_player_name(new_name)
	
func _physics_process(_delta):
	detected = remote_dtct
	if is_network_master():#get_tree().is_network_server():#
		#if nb_fdetected the same for 360 frames (6sec)
		if prev_lp == lifepoints:
			lifepoints += 1 * _delta / 8 #8sec = delta * 1/8
		prev_lp = lifepoints
		if detected:
			lifepoints -= 2 * _delta
		if lifepoints > 100:
			lifepoints = 100
		elif lifepoints < 0:
			lifepoints = 0
			become_seeker()
			return
		rset_unreliable("puppet_lp", lifepoints)
		detected = false
		rset_unreliable("remote_dtct", detected)
		
	else:
		lifepoints = puppet_lp
		#sync with pupped vars
		if change:
			become_seeker()
			return
	
	#var Player = get_tree().get_root().get_node("./Root/PlayerSeeker")
	#direction = (position - Player.position).normalized()
	#pos = position
	#print(lifepoints)
	get_node("LP_Bar").update_lp(lifepoints)
	update()
	#IF LP < 0 BECOME SEEKER OBJECT
	
func detected(): #change in a detected? (true/false) and then update in _process?
	if get_tree().is_network_server(): #is_network_master():
		#++nb_fdetected
		#if nb_fdetected > 59:
		#	lifepoints -= 2
		#nb_fdetected %= 60
		detected = true
		rset_unreliable("remote_dtct", detected)
	else:
		detected = remote_dtct
		#sync with pupped vars

func become_seeker():
	if is_network_master():
		#rset("change", true)
		print("name = ", self.get_name())
		self.remove_from_group("detectable")
		remove_child(self.get_node("LP_Bar"))
		new_inst = load("res://PlayerSeeker.tscn").instance()
		new_inst.set_name(self.get_name())
		new_inst.set_network_master(self.get_network_master())
		rset("change", true)
		self.replace_by(new_inst, true)
	elif change:
		#new_inst.set_name(self.get_name())
		self.remove_from_group("detectable")
		remove_child(self.get_node("LP_Bar"))
		new_inst = load("res://PlayerSeeker.tscn").instance()
		new_inst.set_name(self.get_name())
		new_inst.set_network_master(self.get_network_master())
		self.replace_by(new_inst)
 
