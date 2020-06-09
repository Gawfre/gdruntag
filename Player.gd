extends KinematicBody2D






var MAX_SPEED = 500
var ACCELERATION = 2000 setget ACCELERATION_set, ACCELERATION_get
puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()
var motion = Vector2.ZERO

#VARIABLES FOR SPEED BOOST
var bool_speed_boost_allowed = false
var bool_speed_decrement = false
var delay_speed_timer = 3
var timer_speed
var base_speed = MAX_SPEED
var MAX_RATIO_BOOST_SPEED = 1.5
var bool_change_speed = false
puppet var puppet_light_intensity
puppet var puppet_light_scale
puppet var puppet_bool_speed = bool_change_speed
puppet var puppet_bool_speed_decrement = bool_speed_decrement

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

# SETTERS AND GETTERS
func ACCELERATION_set(new_value):
	ACCELERATION = new_value

func ACCELERATION_get():
	return ACCELERATION 
	
func MAX_SPEED_set(new_value):
	MAX_SPEED = new_value

func MAX_SPEED_get():
	return MAX_SPEED

func set_bool_boost(type_boost):
	if(type_boost == gamestate.BOOST_SPEED):
		set_bool_speed()
	elif(type_boost == gamestate.BOOST_LIGHT):
		set_bool_light()

func set_bool_light():
	bool_light_boost_allowed = true
	bool_change_light = true	
	rset_unreliable("puppet_bool_light", bool_change_light)

func set_bool_speed():
	bool_speed_boost_allowed = true
	bool_change_speed = true	
	rset_unreliable("puppet_bool_speed", bool_change_speed)

func set_player_name(new_name):
	get_node("Label").set_text(new_name)

func get_speed_boost_allowed():
	return bool_speed_boost_allowed
	

func get_light_boost_allowed():
	return bool_light_boost_allowed	

#TIMER FUNCTIONS
func on_timeout_speed_complete():
	bool_speed_decrement = true
	rset_unreliable("puppet_bool_speed_decrement", bool_speed_decrement)

func on_timeout_light_complete():
	bool_light_decrement = true
	rset_unreliable("puppet_bool_light_decrement", bool_light_decrement)

func check_boost_allowed():
	if bool_speed_boost_allowed:
			if bool_change_speed:
				increment_speed()
			if bool_speed_decrement:
				decrement_speed()

func increment_speed():
	if MAX_SPEED < MAX_RATIO_BOOST_SPEED * base_speed:
		MAX_SPEED += 50
		MAX_SPEED_set(MAX_SPEED)
		print("vitesse actuelle incr " + String(MAX_SPEED))
	else:
		bool_change_speed = false	
		rset_unreliable("puppet_bool_speed", bool_change_speed)
		timer_speed.start()
		print("timer started")

func decrement_speed():
	if MAX_SPEED > base_speed:
		MAX_SPEED -= 50.0
		MAX_SPEED_set(MAX_SPEED)
		print("vitesse actuelle decr " + String(MAX_SPEED))
	elif MAX_SPEED == base_speed:
		bool_speed_decrement = false
		bool_speed_boost_allowed = false
		rset_unreliable("puppet_bool_speed_decrement", bool_speed_decrement)

func check_light_allowed():
	if bool_light_boost_allowed:
			if bool_change_light:
				increment_light()
			if bool_light_decrement:
				decrement_light()

func increment_light():
	if get_node("Light2D").energy < base_light * MAX_RATIO_BOOST_LIGHT:
		get_node("Light2D").texture_scale += 1
		get_node("Light2D").energy += 1
		rset_unreliable("puppet_light_intensity", get_node("Light2D").energy)
		rset_unreliable("puppet_light_scale", get_node("Light2D").texture_scale)
		print("texture scale actuelle incr " + String(get_node("Light2D").texture_scale))
		print("energy light actuelle incr " + String(get_node("Light2D").energy))
	else:
		bool_change_light = false	
		rset_unreliable("puppet_bool_light", bool_change_light)
		timer_light.start()
		print("timer started")

func decrement_light():
	if get_node("Light2D").energy > base_light:
		get_node("Light2D").texture_scale -= 1
		get_node("Light2D").energy -= 1
		rset_unreliable("puppet_light_intensity", get_node("Light2D").energy)
		rset_unreliable("puppet_light_scale", get_node("Light2D").texture_scale)
		print("texture scale actuelle decr " + String(get_node("Light2D").texture_scale))
		print("energy light actuelle decr " + String(get_node("Light2D").energy))
	elif get_node("Light2D").energy == base_light:
		bool_light_decrement = false
		bool_light_boost_allowed = false
		rset_unreliable("puppet_bool_light_decrement", bool_light_decrement)

func _physics_process(delta):
	if is_network_master():
		check_boost_allowed()
		check_light_allowed()
		var axis = get_input_axis()
		if axis == Vector2.ZERO:
			apply_friction(ACCELERATION * delta)
		else:
			apply_movement(axis * ACCELERATION * delta)
		motion = move_and_slide(motion)
		
		rset_unreliable("puppet_motion", motion)
		rset_unreliable("puppet_pos", position)
	else:
		get_node("Light2D").texture_scale = puppet_light_scale
		get_node("Light2D").energy = puppet_light_intensity
		position = puppet_pos
		motion = puppet_motion	
		bool_change_light = puppet_bool_light
		bool_change_speed = puppet_bool_speed
		bool_speed_decrement = puppet_bool_speed_decrement
	if not is_network_master():
		puppet_pos = position

func get_input_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	return axis.normalized()

func apply_friction(amount):
	if motion.length() > amount:
		motion -= motion.normalized() * amount
	else:
		motion = Vector2.ZERO

func apply_movement(acceleration):
	motion += acceleration
	motion = motion.clamped(MAX_SPEED)

func _ready():
	puppet_pos = position
	puppet_light_intensity = get_node("Light2D").energy
	puppet_light_scale = get_node("Light2D").texture_scale
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
