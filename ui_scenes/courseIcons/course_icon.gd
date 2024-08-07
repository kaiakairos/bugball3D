extends Node2D

@onready var icon = $icon

@export var image :Texture = null

@export var easyLevels :Array[String] = []
@export var mediumLevels :Array[String] = []
@export var hardLevels :Array[String] = []

@export var courseName :String = "bleh"

@export var saveCodeE :String = ""
@export var saveCodeM :String = ""
@export var saveCodeH :String = ""

## needs 5 minimums : S,A,B,C,D
@export var rankLimitE :Array[float] = []
## needs 5 minimums : S,A,B,C,D
@export var rankLimitM :Array[float] = []
## needs 5 minimums : S,A,B,C,D
@export var rankLimitH :Array[float] = []

#### EXPORTS FOR MAP TEXTURES ####
@export var wallTexture :Texture2D = null
@export var floorTextures :Array[Texture2D] = []
@export var ceilingTextures :Array[Texture2D] = []
@export var ceilDye :Color = Color.WHITE
@export var holeTexture :Texture2D = null
@export var ceilBorderColor :Color = Color.BLACK
@export var wallBorderColor :Color = Color.BLACK


var boingtween :Tween = null
var shinetween :Tween = null
var hovering = false

func _ready():
	if image != null:
		icon.texture = image
	else:
		print_debug("failure, no image")
	
	$icon/Label.text = tr(courseName)
	Global.connect("changeLanguage",swapLanguage)
	
func _process(delta):
	if hovering:
		icon.modulate = lerp(icon.modulate,Color.WHITE,0.2)
		icon.scale = lerp(icon.scale,Vector2(1,1),0.2)
	else:
		icon.modulate = lerp(icon.modulate,Color(0.2,0.2,0.2),0.2)
		icon.scale = lerp(icon.scale,Vector2(0.8,0.8),0.2)
	

func swapLanguage():
	$icon/Label.text = tr(courseName)

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
