extends Control


var state = ""

#enum STATE?

# Called when the node enters the scene tree for the first time.
func _ready():
	$GodotSplash.connect("godot_anim_ended", self, "_on_godot_anim_end")
	$GodotSplash.connect("godot_fadeout_ended", self, "_on_godot_fadeout_end")
	$OALogo.connect("oa_anim_ended", self, "_on_oa_anim_end")
	
	state = "godotspl"
	#get_node("Timer").start(10)


func _process(delta):
	#print(str(get_node("Timer").get_wait_time()) + " - " + str(get_node("Timer").get_time_left()))
	#print(get_node("Timer").is_stopped())
	
	# Skip a splash by pressing Enter or Space (ui_accept)
	if Input.is_action_just_pressed("ui_accept"):
		if state == "godotspl" or state == "fadespl":
			$GodotSplash.visible = false
			$BackgroundRect.visible = false
			get_node("Timer").stop()
			state = "oaspl"
		else: #if state == "oaspl"
			change_to_network_scene()

func _on_godot_anim_end():
	#get_node("Timer").start(2)
	if get_node("Timer").is_stopped():
		get_node("Timer").start(0.8)

func _on_godot_fadeout_end():
	_on_Timer_timeout()

func _on_oa_anim_end():
	#print("received oa anim end")
	if get_node("Timer").is_stopped():
		get_node("Timer").start(2.4)

func _on_Timer_timeout():
	if state == "godotspl":
		state = "fadespl"
	elif state == "fadespl":
		state = "oaspl"
	elif state == "oaspl":
		change_to_network_scene()
		
func change_to_network_scene():
	get_tree().change_scene("res://NetworkingTest.tscn")
