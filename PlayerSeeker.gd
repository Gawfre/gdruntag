extends "res://Player.gd"

const DETECT_RADIUS = 200
const FOV = 80
var angle = 0
var prevmousepos = Vector2.ZERO
var detect_count = []
const type = gamestate.SEEKER

var direction = Vector2()
var draw_color = GREEN
var ACCELERATION_CONST = 1000
var MAX_SPEED_CONST = 250

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

puppet var puppet_direction = Vector2()
puppet var puppet_angle = 0
puppet var puppet_color = draw_color
remotesync var puppet_count = []

var spr = null

func _init():
	.ACCELERATION_set(ACCELERATION_CONST)
	.MAX_SPEED_set(MAX_SPEED_CONST)
	spr = get_node("Sprite")
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

func get_speed_boost_allowed():
	return bool_speed_boost_allowed

func get_light_boost_allowed():
	return bool_light_boost_allowed	
	
func set_player_name(new_name):
	.set_player_name(new_name)

func set_bool_speed():
	bool_speed_boost_allowed = true
	bool_change_speed = true	
	rset_unreliable("puppet_bool_speed", bool_change_speed)
	
	
func set_bool_light():
	bool_light_boost_allowed = true
	bool_change_light = true	
	rset_unreliable("puppet_bool_light", bool_change_light)

func on_timeout_light_complete():
	bool_speed_decrement = true
	rset_unreliable("puppet_bool_light_decrement", bool_light_decrement)
	
func on_timeout_speed_complete():
	bool_speed_decrement = true
	rset_unreliable("puppet_bool_speed_decrement", bool_speed_decrement)
	
# Drawing the FOV
const RED = Color(1.0, 0, 0, 0.4)
const GREEN = Color(0, 1.0, 0, 0.4)
const COLOR_DETECTED = RED

func _ready():
	set_physics_process(true)
	
func _physics_process(_delta):
	if is_network_master():
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
		var pos = position

		if prevmousepos != get_viewport().get_mouse_position():
			prevmousepos = get_viewport().get_mouse_position()
			direction = Vector2(get_local_mouse_position().y, get_local_mouse_position().x).normalized()#(get_global_mouse_position() - pos).normalized()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		var dirjoy = Vector2(Input.get_joy_axis(0, JOY_AXIS_3), Input.get_joy_axis(0,JOY_AXIS_2))
		if (dirjoy.x > 0.2 or dirjoy.x < -0.2) or (dirjoy.y > 0.2 or dirjoy.y < -0.2):
			direction = dirjoy.normalized()
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		
		angle = 90 - rad2deg(direction.angle()) # Thx to black magic we get the angle we want by inverting x and y value in V2 variable direction
		
		detect_count = []
		for node in get_tree().get_nodes_in_group('detectable'):
			if pos.distance_to(node.position) < DETECT_RADIUS:
				# Find the angle to the node, using the dot product
				#var dot_product = direction.dot(node.direction)
				var angle_to_node = rad2deg(Vector2(direction.y,direction.x).angle_to( (node.position - position).normalized() ))
				#var angle_to_node = rad2deg(acos(dot_product))
				if  abs(angle_to_node) < FOV/2:
					detect_count.push_back(node.get_path())
				
				#If it's within the Player's cone of vision, the object is detected
	
		# DRAWING
		if detect_count.size() > 0:
			draw_color = RED
		else:
			draw_color = GREEN
		update()
		#rset_unreliable("puppet_direction", direction)
		rset_unreliable("puppet_angle", angle)
		rset_unreliable("puppet_color", draw_color)
		rset_unreliable("puppet_count", detect_count)
	else:
		bool_change_light = puppet_bool_light
		bool_change_speed = puppet_bool_speed
		bool_speed_decrement = puppet_bool_speed_decrement
		#direction = puppet_direction
		angle = puppet_angle
		draw_color = puppet_color
		detect_count = puppet_count
		update()
		
	
	if draw_color == COLOR_DETECTED:
		for nd in detect_count:
			var dn = get_tree().get_root().get_node(nd)#instance_from_id(nd.object_id)
			if dn.type == gamestate.HIDER:
				dn.sprite_spotted() #this works over a variable sync over network if it causes issue and we want our local game to be consistent, we can calculate draw_color and the detection locally here so it will be consistent locally but the data if a hider is seen and lose PV will only work if it is seen by a seeker on the server regardless of each local states
				if get_tree().is_network_server():
					dn.detected()
	
	print(angle)
	spr.rotation_degrees = angle
	if angle > 90:
		spr.flip_v = true
	else:
		spr.flip_v = false
		

func _draw():
	draw_circle_arc_poly(Vector2(), DETECT_RADIUS,  angle - FOV/2, angle + FOV/2, draw_color)


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var vector = Vector2()
	var points_arc = [vector]
	points_arc.push_back(center)
	var colors = [color]

	for i in range(nb_points+1):
		var angle_point = angle_from + i*(angle_to-angle_from)/nb_points
		points_arc.push_back(center + Vector2( cos( deg2rad(angle_point) ), sin( deg2rad(angle_point) ) ) * radius)
	draw_polygon(points_arc, colors)
