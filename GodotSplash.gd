extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal godot_anim_ended
signal godot_fadeout_ended

# Called when the node enters the scene tree for the first time.
func _ready():
	$GodotText.self_modulate.a = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().get_root().get_node("SplashScr").state == "godotspl":
		#if $GodotLogo.rect_position.y > -50:
		#	$GodotLogo.rect_position.y -= 8 * delta *3
		if $GodotText.rect_position.y < 850:
			$GodotLogo.rect_position.y -= 8 * delta *3.5
			$GodotText.rect_position.y += 8 * delta *3.5
		if $GodotText.self_modulate.a < 1:
			$GodotText.self_modulate.a += 0.1 * delta *4
			
		if $GodotText.rect_position.y > 850 and $GodotText.self_modulate.a > 1:
			emit_signal("godot_anim_ended")
	elif get_tree().get_root().get_node("SplashScr").state == "fadespl":
		if modulate.a > 0:
			modulate.a -= 0.65 * delta
		else:
			emit_signal("godot_fadeout_ended")
