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


puppet var puppet_direction = Vector2()
puppet var puppet_angle = 0
puppet var puppet_color = draw_color
remotesync var puppet_count = []

var spr = null

func _init():
	.ACCELERATION_set(ACCELERATION_CONST)
	.MAX_SPEED_set(MAX_SPEED_CONST)
	spr = get_node("Sprite")

func set_bool_boost(type_boost):
	.set_bool_boost(type_boost)
	
func set_player_name(new_name):
	.set_player_name(new_name)
	
func get_speed_boost_allowed():
	.get_speed_boost_allowed()
	

func get_light_boost_allowed():
	.get_light_boost_allowed()
	
# Drawing the FOV
const RED = Color(1.0, 0, 0, 0.4)
const GREEN = Color(0, 1.0, 0, 0.4)
const COLOR_DETECTED = RED

func _ready():
	set_physics_process(true)
	
func _physics_process(_delta):
	if is_network_master():
		#BOOST SPEED PHYSICS PROCESS UPDATE
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
