extends Sprite2D

var tick :int= 0

func _ready():
	
	if !Saving.getValue("showClouds"):
		queue_free()
		return
	
	
	texture.noise.seed = randi()
	tick = asin(texture.noise.fractal_gain/2.0)/0.001

func _process(delta):
	tick += 1
	texture.noise.fractal_gain = sin(tick*0.001) * 2.0
