extends Node2D

## New shader? Just add to this array :]
var requiredShaders = [
	"res://main_scenes/courseCompleteBackground.tres",
	"res://main_scenes/mainMenu/outlineMenu.tres",
	"res://main_scenes/mainMenu/transition.tres",
	"res://object_scenes/decor/clouds/cloudMaterial.tres",
	"res://object_scenes/decor/decor3D/decoration_3d_material.tres",
	"res://ui_scenes/outlineCanvasMaterial.tres",
]

var needscanvas = [ false,true,false,false,true,true ]
var num = 0
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	num = requiredShaders.size()

func _process(delta):
	if OS.has_feature('web'):
		if Input.is_action_just_pressed("webClick"):
			loadShaders()
			set_process(false)
			return
	else:
		loadShaders()
		set_process(false)
		return

func loadShaders():
	
	var startX = 250 - (  32 * (requiredShaders.size()*0.5))
	
	var i = 0
	
	for sh in requiredShaders:
		var sprite = Sprite2D.new()
		sprite.texture = load("res://main_scenes/compiler/testBug.png")
		sprite.centered = false
		sprite.position = Vector2(startX + ( i * 32 ), 184)
		if needscanvas[i]:
			var c = CanvasGroup.new()
			c.material = load(sh)
			add_child(c)
			c.add_child(sprite)
		else:
			sprite.material = load(sh)
			add_child(sprite)
		i += 1
		$text.text = tr("SHADER_COMPILE") + " (" + str(i) + "/" + str(num) + ")"
		await get_tree().create_timer(0.05).timeout
	
	get_tree().change_scene_to_file("res://main_scenes/mainMenu/main_menu.tscn")
