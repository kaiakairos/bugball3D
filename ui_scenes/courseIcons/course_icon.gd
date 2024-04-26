extends Node2D

@onready var icon = $icon

@export var image :Texture = null

@export var easyLevels :Array[String] = []
@export var mediumLevels :Array[String] = []
@export var hardLevels :Array[String] = []

@export var courseName :String = "bleh"



var boingtween :Tween = null
var shinetween :Tween = null
var hovering = false

func _ready():
	if image != null:
		icon.texture = image
	else:
		print_debug("failure, no image")

func _process(delta):
	if hovering:
		icon.modulate = lerp(icon.modulate,Color.WHITE,0.2)
		icon.scale = lerp(icon.scale,Vector2(1,1),0.2)
	else:
		icon.modulate = lerp(icon.modulate,Color(0.2,0.2,0.2),0.2)
		icon.scale = lerp(icon.scale,Vector2(0.8,0.8),0.2)

func shine():
	
	if is_instance_valid(shinetween):
		if shinetween.is_running():
			return
	
	$icon/Shine.position.x = -620
	shinetween = get_tree().create_tween()
	shinetween.tween_property($icon/Shine,"position:x",160,0.5)

func boing():
	if is_instance_valid(boingtween):
		if boingtween.is_running():
			return
	
	icon.scale = Vector2(0.6,0.6)
	boingtween = get_tree().create_tween()
	boingtween.tween_property(icon,"scale",Vector2(1.0,1.0),0.8).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
