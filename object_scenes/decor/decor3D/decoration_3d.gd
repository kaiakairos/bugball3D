extends Node2D

@export var spriteSheet :Texture
@export var images :int= 1

@export var disBetweenLayers :float= 0.01
## leave at 0.1 to be on top floor
@export var baseLayer :float = 0.1

@onready var canvas = $canvas

@export var randRotation :bool = true
@export var wiggle :bool = true
@export var wiggleAmount :float = 2.0

var angle :int= 0

var tick :int= 0

var unrendered = true

func _ready():
	
	$VisibleOnScreenNotifier2D.visible = true
	
	Global.connect("disableDecor",disable)
	Global.connect("enableDecor",enable)
	
	if !Saving.getValue("showDecor"):
		visible = false
		set_process(false)
		return
	render()

func render():
	if spriteSheet == null:
		print_debug("no sprite dumbass")
		queue_free()
	
	angle = (randi() % 4) * int(randRotation)
	
	createLayers()
	z_index = 219
	
	unrendered = false
	
func createLayers():
	for i in range(images):
		var ins = Sprite2D.new()
		ins.texture = spriteSheet
		ins.hframes = images
		ins.frame = i
		ins.rotation = (PI/2) * angle
		canvas.add_child(ins)

func _process(delta):
	tick += 1
	var camPos = to_local(Global.getGlobalCameraPosition())
	#canvas.position = camPos * -baseLayer
	var i = 0
	for layer in canvas.get_children():
		layer.position = camPos * -((disBetweenLayers*i)+baseLayer)
		if wiggle:
			var mul = wiggleAmount * (i+1)* (i+1)
			var g = global_position
			layer.position.x += Global.wiggleNoise.get_noise_1d((tick*0.2) + g.x ) * mul
			layer.position.y += Global.wiggleNoise.get_noise_1d((tick*0.2) + 4000 + g.y) * mul
		
		i += 1

func disable():
	visible = false
	set_process(false)

func enable():
	visible = true
	set_process(true)
	
	if unrendered:
		render()


func _on_visible_on_screen_notifier_2d_screen_entered():
	if !visible:
		return
	set_process(true)

func _on_visible_on_screen_notifier_2d_screen_exited():
	if !visible:
		return
	set_process(false)
