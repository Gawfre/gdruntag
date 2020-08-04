extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var imageTexture = ImageTexture.new()
	var dynImage = Image.new()
	
	dynImage.create(256,256,false,Image.FORMAT_RGB8)
	dynImage.fill(Color(1,1,1,1)) #dynImage.fill(Color(0,0,0,1)) #black
	
	imageTexture.create_from_image(dynImage)
	self.texture = imageTexture
	
	imageTexture.resource_name = "whitetexture"
	print(self.texture.resource_name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().get_root().get_node("SplashScr").state == "fadespl":
		if self_modulate.a > 0:
			self_modulate.a -= 0.65 * delta

