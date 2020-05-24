extends KinematicBody2D

var MAX_SPEED = 500
var ACCELERATION = 2000 setget ACCELERATION_set, ACCELERATION_get
puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()
var motion = Vector2.ZERO
func ACCELERATION_set(new_value):
	ACCELERATION = new_value

func ACCELERATION_get():
	return ACCELERATION 
	
func MAX_SPEED_set(new_value):
	MAX_SPEED = new_value

func MAX_SPEED_get():
	return MAX_SPEED


func set_player_name(new_name):
	get_node("Label").set_text(new_name)

func _physics_process(delta):
	if is_network_master():
		var axis = get_input_axis()
		if axis == Vector2.ZERO:
			apply_friction(ACCELERATION * delta)
		else:
			apply_movement(axis * ACCELERATION * delta)
		motion = move_and_slide(motion)
		
		rset_unreliable("puppet_motion", motion)
		rset_unreliable("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion	
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
