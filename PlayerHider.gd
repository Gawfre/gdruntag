extends "res://Player.gd"

var pos = Vector2()
var direction = Vector2()

func _ready():
	set_physics_process(true)
	
func _physics_process(_delta):
	var Player = get_tree().get_root().get_node("./Root/PlayerSeeker")
	direction = (position - Player.position).normalized()
	pos = position
	update()
