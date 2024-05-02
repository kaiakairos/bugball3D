extends Node2D


@onready var container = $Container

var levels :Array[String] = [
"res://main_scenes/levels/courseEasy/0.tscn",
"res://main_scenes/levels/courseEasy/1.tscn",
"res://main_scenes/levels/courseEasy/2.tscn",
"res://main_scenes/levels/courseEasy/3.tscn",
"res://main_scenes/levels/courseEasy/4.tscn",
"res://main_scenes/levels/courseEasy/16.tscn",
"res://main_scenes/levels/courseEasy/8.tscn",
"res://main_scenes/levels/courseEasy/5.tscn",
"res://main_scenes/levels/courseEasy/15.tscn",
"res://main_scenes/levels/courseEasy/9.tscn",
"res://main_scenes/levels/courseEasy/6.tscn",
"res://main_scenes/levels/courseEasy/10.tscn",
"res://main_scenes/levels/courseEasy/7.tscn",
"res://main_scenes/levels/courseEasy/11.tscn",
"res://main_scenes/levels/courseEasy/12.tscn",
"res://main_scenes/levels/courseEasy/13.tscn",
]

var current = 0

var loading = false

var circ = 1.0

var time = 0.0
var timing = false

var GRRRAAHHHHHHHH = true

func _ready():
	Global.gameController = self
	loadLevel(0)
	Global.connect("cameraCHANGED",placeTransition)

func reloadLevel():
	if loading:
		return
	loadLevel(current)

func nextLevel():
	if loading:
		return
	current += 1
	loadLevel(current)

func isLevelLoaded():
	return container.get_children().size() > 0

func loadLevel(id):
	
	var open = isLevelLoaded()
	
	timing = false
	
	if open:
		var tween = get_tree().create_tween()
		tween.tween_property(self,"circ",0.0,1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		GRRRAAHHHHHHHH = true
		loading = true
		await tween.finished
	else:
		circ = 0.0
	
	
	for i in container.get_children():
		i.queue_free()
	
	if id < 0 or id >= levels.size():
		print_debug("Level load failed, level array does not have id " + str(id))
		await get_tree().create_timer(1.0).timeout
		$UI/finalTime.visible = true
		return
	
	
	
	var ins = load(levels[id]).instantiate()
	container.add_child(ins)
	
	await get_tree().create_timer(0.5).timeout
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(self,"circ",0.25,0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	await tween2.finished
	
	Global.player.canMove = true
	
	if !open:
		#this is where we put timer start, music shit swag
		pass
	
	
	await get_tree().create_timer(0.1).timeout
	
	timing = true
	
	var tween4 = get_tree().create_tween()
	tween4.tween_property(self,"circ",2.0,0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	await tween4.finished
	
	GRRRAAHHHHHHHH = false
	loading = false

func pauseTimer():
	timing = false

func _process(delta):
	
	if timing:
		time += delta
		var value = time - (int(time/60.0)*60)
		var string = str( value )
		if value < 10.0:
			string = "0" + string
		
		string = string.left(5)
		
		$UI/Timer.text = str( int(time/60.0) ) + " : " + string
	
	if GRRRAAHHHHHHHH:
		$transition.material.set_shader_parameter("circle_size",circ)
		placeTransition()
		
	if $UI/finalTime.visible:
		if Input.is_action_just_pressed("roll"):
			get_tree().reload_current_scene()
	
func placeTransition():
	if !is_instance_valid(Global.player):
		$transition.material.set_shader_parameter("retard",Vector2(0.5,0.5))
		return
	var gay = Global.player.get_global_transform_with_canvas().origin - Vector2(0,-100)
	
	gay= gay / Vector2(500,500)
	$transition.material.set_shader_parameter("retard",gay)
	$transition.global_position = Global.camera.global_position - Vector2(250,250)
