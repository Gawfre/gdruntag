extends Control

var timer = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# timer = get_tree().get_root().get_node("Timer")
	# print(get_tree().get_root().get_node("Timer"))
	# get_node("TextureProgress").max_value = timer.get_wait_time()
	get_node("CanvasLayer/TextureProgress").value = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if timer != null:
		get_node("CanvasLayer/TextureProgress").value = timer.get_time_left()


func give_timer(timer):
	self.timer = timer
	get_node("CanvasLayer/TextureProgress").max_value = timer.get_wait_time() + 50
