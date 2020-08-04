extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal oa_anim_ended

# Called when the node enters the scene tree for the first time.
func _ready():
	self_modulate = Color(0,0,0,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().get_root().get_node("SplashScr").state == "oaspl":
		if self_modulate.a < 1:
			self_modulate.a += 0.1 * delta *3
		
		if self_modulate.a > 0.5:
			if self_modulate.r < 0.7:
				self_modulate.r += 0.1 * delta *3
				self_modulate.g += 0.1 * delta *3
				self_modulate.b += 0.1 * delta *3
			else:
				if self_modulate.r < 1.2:
					self_modulate.r += 0.1 * delta *3
				if self_modulate.g > 0:
					self_modulate.g -= 0.25 * delta *3
					self_modulate.b -= 0.25 * delta *3
					
				if self_modulate.r > 1.2 and self_modulate.g < 0:
					emit_signal("oa_anim_ended")
	
			
		#print(self_modulate)
