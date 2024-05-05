extends Sprite2D


func _ready():
	z_index = 210
	scale = Vector2(2,2)
	hframes = 2

func _process(delta):
	offset = Global.getGlobalCameraPosition() * -0.05
	frame = int(!Global.usingController)
