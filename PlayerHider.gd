extends "res://Player.gd"

var pos = Vector2()
var direction = Vector2()

func _ready():
	var Player = get_tree().get_root().get_node("./Root/PlayerSeeker")
	direction = (position - Player.position).normalized()
	pos = position
