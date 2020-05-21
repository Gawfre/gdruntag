extends "res://Player.gd"

const DETECT_RADIUS = 200
const FOV = 80
var angle = 0
var lmousespeed = Vector2.ZERO

var direction = Vector2()
var draw_color = GREEN
var ACCELERATIONSEEKER = 1000
var MAX_SPEEDSEEKER = 500


func _init():
	.ACCELERATION_set(ACCELERATIONSEEKER)

func set_player_name(new_name):
	.set_player_name(new_name)

# Drawing the FOV
const RED = Color(1.0, 0, 0, 0.4)
const GREEN = Color(0, 1.0, 0, 0.4)

func _ready():
	set_physics_process(true)
	
func _physics_process(_delta):
	var pos = position
	if lmousespeed != get_viewport().get_mouse_position():
		lmousespeed = get_viewport().get_mouse_position()
		direction = Vector2(get_local_mouse_position().y, get_local_mouse_position().x).normalized()#(get_global_mouse_position() - pos).normalized()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#print("Stand", get_local_mouse_position())
	#print("Norm", get_local_mouse_position().normalized())
	var dirjoy = Vector2(Input.get_joy_axis(0, JOY_AXIS_3), Input.get_joy_axis(0,JOY_AXIS_2))
	#print(dirjoy)
	if (dirjoy.x > 0.2 or dirjoy.x < -0.2) or (dirjoy.y > 0.2 or dirjoy.y < -0.2): #https://godotengine.org/article/handling-axis-godot
		direction = dirjoy.normalized()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	angle = rad2deg(direction.angle())
	
	var detect_count = 0
	for node in get_tree().get_nodes_in_group('detectable'):
		if pos.distance_to(node.pos) < DETECT_RADIUS:
			# Find the angle to the node, using the dot product
			#var dot_product = direction.dot(node.direction)
			var angle_to_node = rad2deg(direction.angle_to(node.direction))
			#var angle_to_node = rad2deg(acos(dot_product))
			if  abs(angle_to_node) < FOV/2:
				detect_count +=1
			
			#If it's within the Player's cone of vision, the object is detected
			
	# DRAWING
	if detect_count >0:
		draw_color = RED
	else:
		draw_color = GREEN
	update()

func _draw():
	draw_circle_arc_poly(Vector2(), DETECT_RADIUS,  angle - FOV/2, angle + FOV/2, draw_color)


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var vector = Vector2()
	var points_arc = [vector]
	points_arc.push_back(center)
	var colors = [color]

	for i in range(nb_points+1):
		var angle_point = -angle_from + i*(angle_to-angle_from)/nb_points
		points_arc.push_back(center + Vector2( cos( deg2rad(angle_point) ), sin( deg2rad(angle_point) ) ) * radius)
	draw_polygon(points_arc, colors)
