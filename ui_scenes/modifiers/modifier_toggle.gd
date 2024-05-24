extends Node2D


##Displays this
@export var modName :String = ""
@export var desc :String = ""

@export var frame :int= 0

## Uses this to call to global script
@export var modId :String = ""

var tween = null

@onready var sp = $Base

var looking = false
var t = 0

func _ready():
	sp.frame_coords.y = frame
	sp.frame_coords.x = int(Global.call("get"+modId))

func _process(delta):
	if looking:
		t += 1
		sp.rotation = sin(t*0.11) * 0.2
	else:
		sp.rotation = 0.0

func press():
	sp.scale *= 0.2
	if is_instance_valid(tween):
		tween.stop()
	tween = get_tree().create_tween()
	tween.tween_property(sp,"scale",Vector2(1,1),1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	sp.frame_coords.x = int(Global.call("toggle"+modId))
	Sound.playSound2D(Vector2(250,150),"res://audio/jump.ogg",0.0)
