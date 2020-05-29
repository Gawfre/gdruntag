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


#VARIABLES FOR SPEED BOOST
var bool_speed_boost_allowed = false
var bool_speed_decrement = false
var delay_speed_timer = 3
var timer_speed
var base_speed = MAX_SPEED_CONST
var MAX_RATIO_BOOST_SPEED = 1.5
var bool_change_speed = false
puppet var puppet_bool_speed = bool_change_speed
puppet var puppet_bool_speed_decrement = bool_speed_decrement
puppet var puppet_lp = lifepoints

#VARIABLES FOR LIGHT BOOST
var bool_light_boost_allowed = false
var bool_light_decrement = false
var delay_light_timer = 3
var timer_light
var base_light = 1.0
var MAX_LIGHT_VALUE = 5.0
var MAX_RATIO_BOOST_LIGHT = 1.5
var bool_change_light = false
puppet var puppet_bool_light = bool_change_light
puppet var puppet_bool_light_decrement = bool_light_decrement

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
	timer_speed = Timer.new()
	timer_speed.set_one_shot(true)
	timer_speed.set_wait_time(delay_speed_timer)
	timer_speed.connect("timeout", self, "on_timeout_speed_complete")
	add_child(timer_speed) #TO-DO : instanciate timer when walking into a boost
	timer_light = Timer.new()
	timer_light.set_one_shot(true)
	timer_light.set_wait_time(delay_light_timer)
	timer_light.connect("timeout", self, "on_timeout_light_complete")
	add_child(timer_light) #TO-DO : instanciate timer when walking into a boost

func _init():
	.ACCELERATION_set(ACCELERATION_CONST)
	.MAX_SPEED_set(MAX_SPEED_CONST)
	
func get_speed_boost_allowed():
	return bool_speed_boost_allowed
	

func get_light_boost_allowed():
	return bool_light_boost_allowed	


func set_player_name(new_name):
	.set_player_name(new_name)
	
func on_timeout_speed_complete():
	bool_speed_decrement = true
	rset_unreliable("puppet_bool_speed_decrement", bool_speed_decrement)

func on_timeout_light_complete():
	bool_speed_decrement = true
	rset_unreliable("puppet_bool_light_decrement", bool_light_decrement)

func set_bool_light():
	bool_light_boost_allowed = true
	bool_change_light = true	
	rset_unreliable("puppet_bool_light", bool_change_light)

func set_bool_speed():
	bool_speed_boost_allowed = true
	bool_change_speed = true	
	rset_unreliable("puppet_bool_speed", bool_change_speed)
	
func _physics_process(_delta):
	detected = remote_dtct
	if is_network_master():#get_tree().is_network_server():#
		#if nb_fdetected the same for 360 frames (6sec)
		
		#BOOST SPEED PHYSICS PROCESS UPDATE
		if bool_speed_boost_allowed:
			if bool_change_speed:
				if MAX_SPEED_CONST < MAX_RATIO_BOOST_SPEED * base_speed:
					MAX_SPEED_CONST += 50
					.MAX_SPEED_set(MAX_SPEED_CONST)
					print("vitesse actuelle incr " + String(MAX_SPEED_CONST))
				else:
					bool_change_speed = false	
					rset_unreliable("puppet_bool_speed", bool_change_speed)
					timer_speed.start()
					print("timer started")
			if bool_speed_decrement:
				if MAX_SPEED_CONST > base_speed:
					MAX_SPEED_CONST -= 50.0
					.MAX_SPEED_set(MAX_SPEED_CONST)
					print("vitesse actuelle decr " + String(MAX_SPEED_CONST))
				elif MAX_SPEED_CONST == base_speed:
					bool_speed_decrement = false
					bool_speed_boost_allowed = false
					rset_unreliable("puppet_bool_speed_decrement", bool_speed_decrement)
		if bool_light_boost_allowed:
			if bool_change_light:
				if get_node("Light2D").energy < base_light * MAX_RATIO_BOOST_LIGHT:
					get_node("Light2D").texture_scale += 1
					get_node("Light2D").energy += 1
					print("texture scale actuelle incr " + String(get_node("Light2D").texture_scale))
					print("energy light actuelle incr " + String(get_node("Light2D").energy))
				else:
					bool_change_light = false	
					rset_unreliable("puppet_bool_light", bool_change_light)
					timer_light.start()
					print("timer started")
			if bool_light_decrement:
				if get_node("Light2D").energy > base_light:
					get_node("Light2D").texture_scale -= 1
					get_node("Light2D").energy -= 1
					print("texture scale actuelle decr " + String(get_node("Light2D").texture_scale))
					print("energy light actuelle decr " + String(get_node("Light2D").energy))
				elif get_node("Light2D").energy == base_light:
					bool_light_decrement = false
					bool_light_boost_allowed = false
					rset_unreliable("puppet_bool_light_decrement", bool_light_decrement)			
		if prev_lp == lifepoints:
			lifepoints += 1 * _delta / 8 #8sec = delta * 1/8
		prev_lp = lifepoints
		if detected:
			lifepoints -= 2 * _delta
			#spr.Texture = 
			spr = spr_detected
		else:
			spr = spr_hidden
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
		bool_change_light = puppet_bool_light
		bool_change_speed = puppet_bool_speed
		bool_speed_decrement = puppet_bool_speed_decrement
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
		spr = spr_hidden
		spr.visible = true
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
		spr = spr_hidden
		spr.visible = true
		new_inst = load("res://PlayerSeeker.tscn").instance()
		new_inst.set_name(self.get_name())
		new_inst.set_network_master(self.get_network_master())
		self.replace_by(new_inst)
		
		
func sprite_spotted():
	spr = spr_detected
 
