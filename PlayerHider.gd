extends "res://Player.gd"

var ACCELERATION_CONST = 3000
var MAX_SPEED_CONST = 500
var pos = Vector2()
var direction = Vector2()
var lifepoints = 10 #100
var prev_lp = lifepoints
var detected = false
var new_inst = self
const type = gamestate.HIDER


puppet var puppet_lp = lifepoints
puppet var puppet_enable_particle = enable_particle

var enable_particle = false
var spr = null
var spr_hidden = null #ideally we should be able to build or own ImageTexture or StreamTexture (from existing texture file)
var spr_detected = null

remotesync var remote_dtct = false
puppet var change = false

func _ready():
	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) #hide mouse
	spr_hidden = get_node("Sprite")
	spr_detected = get_node("SpriteSpot")
	spr = spr_hidden

func set_bool_boost(type_boost):
	.set_bool_boost(type_boost)

func get_speed_boost_allowed():
	.get_speed_boost_allowed()
	

func get_light_boost_allowed():
	.get_light_boost_allowed()


func _init():
	.ACCELERATION_set(ACCELERATION_CONST)
	.MAX_SPEED_set(MAX_SPEED_CONST)
	
func set_player_name(new_name):
	.set_player_name(new_name)
	
func _physics_process(_delta):
	detected = remote_dtct
	if is_network_master():#get_tree().is_network_server():#
		#if nb_fdetected the same for 360 frames (6sec)
		if prev_lp == lifepoints:
			lifepoints += 1 * _delta / 8 #8sec = delta * 1/8
			if lifepoints >= prev_lp:
				if lifepoints < 100:
					enable_particle = true
					rset_unreliable("puppet_enable_particle", enable_particle)
			else:
				enable_particle = false
				rset_unreliable("puppet_enable_particle", enable_particle)
		prev_lp = lifepoints
		
		if detected:
			lifepoints -= 2 * _delta
			if lifepoints <= prev_lp:
				if lifepoints < 100:
					enable_particle = false
					rset_unreliable("puppet_enable_particle", enable_particle)
			#spr.Texture = 
			spr = spr_detected
		else:
			spr = spr_hidden
		if lifepoints > 100:
			lifepoints = 100
			enable_particle = false
			rset_unreliable("puppet_enable_particle", enable_particle)
		elif lifepoints < 0:
			lifepoints = 0
			become_seeker()
			return
		rset_unreliable("puppet_lp", lifepoints)
		detected = false
		rset_unreliable("remote_dtct", detected)
		
	else:
		lifepoints = puppet_lp
		enable_particle = puppet_enable_particle
		#sync with pupped vars
		if change:
			become_seeker()
			return
	
	if spr == spr_detected:
		spr_detected.visible = true
		spr_hidden.visible = false
		spr = spr_hidden
	else:
		spr_detected.visible = false
		spr_hidden.visible = true
	#var Player = get_tree().get_root().get_node("./Root/PlayerSeeker")
	#direction = (position - Player.position).normalized()
	#pos = position
	#print(lifepoints)
	if enable_particle:
		if(get_node("Particles2D").emitting!=true):
			get_node("Particles2D").emitting = true
	else:
		if(get_node("Particles2D").emitting!=false):
			get_node("Particles2D").emitting = false
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
		remove_child(self.get_node("Sprite"))
		remove_child(self.get_node("SpriteSpot"))
		remove_child(self.get_node("Particles2D"))
		spr = spr_hidden
		spr.visible = true
		self.set_filename("res://PlayerSeeker.tscn")
		new_inst = load("res://PlayerSeeker.tscn").instance()
		new_inst.set_name(self.get_name())
		new_inst.set_network_master(self.get_network_master())
		rset("change", true)
		self.replace_by(new_inst, true)
	elif change:
		#new_inst.set_name(self.get_name())
		self.remove_from_group("detectable")
		remove_child(self.get_node("LP_Bar"))
		remove_child(self.get_node("Sprite"))
		remove_child(self.get_node("SpriteSpot"))
		remove_child(self.get_node("Particles2D"))
		spr = spr_hidden
		spr.visible = true
		self.set_filename("res://PlayerSeeker.tscn")
		new_inst = load("res://PlayerSeeker.tscn").instance()
		new_inst.set_name(self.get_name())
		new_inst.set_network_master(self.get_network_master())
		self.replace_by(new_inst)
		
func sprite_spotted():
	spr = spr_detected
