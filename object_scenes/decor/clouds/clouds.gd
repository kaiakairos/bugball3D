extends Sprite2D

var tick :int= 0

func _ready():
	
	if !Saving.getValue("showClouds"):
		visible = false
		set_process(false)
		return
	
	
	texture.noise.seed = randi()
	tick = asin(texture.noise.fractal_gain/2.0)/0.001
	
	Global.connect("disableCloud",disable)
	Global.connect("enableCloud",enable)

func _process(delta):
	tick += 1
	texture.noise.fractal_gain = sin(tick*0.001) * 2.0

func disable():
	visible = false
	set_process(false)

func enable():
	visible = true
	set_process(true)
