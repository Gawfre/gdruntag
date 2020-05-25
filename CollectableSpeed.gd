extends "res://Collectable.gd"

func _on_Collectable_body_entered(body):
	if body.is_in_group("player"):
		body.set_bool_speed()
		queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
