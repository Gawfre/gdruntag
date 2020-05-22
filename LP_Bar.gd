extends Control


func update_lp(lp):
	#print("update lp")
	if lp <= 100 and lp > 0: 
		get_node("TextureProgress").value = lp
	elif lp > 100: 
		get_node("TextureProgress").value = 100
	else:
		get_node("TextureProgress").value = 0
