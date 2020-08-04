extends TileMap

var selfmodulatefinal = self_modulate

# Called when the node enters the scene tree for the first time.
func _ready():
	self_modulate = Color(0,0,0,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	if get_tree().get_root().get_node("SplashScr").state == "oaspl":
		var tween = get_node("../Tween")
		tween.interpolate_property(self, "self_modulate",
				null, selfmodulatefinal, 1.5,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
