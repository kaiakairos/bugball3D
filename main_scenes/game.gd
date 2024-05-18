extends Node2D


@onready var container = $Container

var levels :Array[String] = []

var current = 0

var loading = false

var circ = 1.0

var time = 0.0
var timing = false

var GRRRAAHHHHHHHH = true

var pauseSelected = 0 # Unpause, Restart, Options, Exit

var deaths :int= 0

func _ready():
	Global.gameController = self
	
	levels = Global.LVLHOLDER
	loadLevel(0)
	Global.connect("cameraCHANGED",placeTransition)
	
	if Global.mirrored:
		$UI.scale = Vector2(1,-1)
		$transition.scale = Vector2(1,-1)
	
	await get_tree().create_timer(0.05).timeout
	$UI.visible = true

func reloadLevel():
	if loading:
		return
	deaths += 1
	loadLevel(current)

func nextLevel():
	if loading:
		return
	current += 1
	loadLevel(current)

func isLevelLoaded():
	return container.get_children().size() > 0

func loadLevel(id):
	
	$UI/Paused/levelsLeft.text = "( " + str(current+1) + " / " + str(levels.size()) + " )" 
	
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
		# end course
		print_debug("Ran out of levels! Going to course completion.")
		$UI/Paused/levelsLeft.text = ""
		var tweenEnd = get_tree().create_tween()
		tweenEnd.tween_property(self,"circ",1.0,1.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
		GRRRAAHHHHHHHH = true
		$transition.z_index = 4096
		$courseComplete.postScores( deaths, time )
		return
	
	
	
	var ins = load(levels[id]).instantiate()
	container.add_child(ins)
	print(levels[id])
	
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
	
	if timing and !get_tree().paused:
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
	
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			unpauseGame()
			$UI/Paused/Options.set_process(false)
			$UI/Paused/Options.visible = false
			$UI/Paused/PAUSED.visible = true
		else:
			pauseGame()
	
	if Input.is_action_just_pressed("menuBack") and get_tree().paused and !$UI/Paused/Options.visible:
		unpauseGame()
	
	
	if get_tree().paused:
		if !$UI/Paused/Options.visible:
			resetPauseIconPositions()
			var nudge = 0
			if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_down_joy"):
				pauseSelected += 1
				nudge += 1
			if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_up_joy"):
				pauseSelected -= 1
				nudge -= 1
			pauseSelected = clamp(pauseSelected,0,3)
			selectItem(pauseSelected,nudge)
			if Input.is_action_just_pressed("menuSelect"):
				match pauseSelected:
					0:
						unpauseGame()
					1:
						unpauseGame()
						get_tree().reload_current_scene()
					2:
						$UI/Paused/Options.set_process(true)
						$UI/Paused/Options.visible = true
						$UI/Paused/PAUSED.visible = false
					3:
						unpauseGame()
						get_tree().change_scene_to_file("res://main_scenes/mainMenu/main_menu.tscn")
		else:
			if Input.is_action_just_pressed("menuBack"):
				$UI/Paused/Options.set_process(false)
				$UI/Paused/Options.visible = false
				$UI/Paused/PAUSED.visible = true
		
func placeTransition():
	if !is_instance_valid(Global.player):
		$transition.material.set_shader_parameter("retard",Vector2(0.5,0.5))
		$transition.position = Vector2(0,-100)
		return
	var o = Global.player.get_global_transform_with_canvas().origin
	var gay = o - Vector2(0,-100)
	
	
	gay= gay / Vector2(500,500)
	$transition.material.set_shader_parameter("retard",gay)
	$transition.global_position = Global.camera.global_position - Vector2(250,250)


func pauseGame():
	get_tree().paused = true
	pauseSelected = 0
	selectItem(0,0)
	$UI/Paused.visible = true

func unpauseGame():
	get_tree().paused = false
	$UI/Paused.visible = false
	$UI/Paused/Options.disable()

func selectItem(id,nudge):
	var a = [ $UI/Paused/unpause , $UI/Paused/restart , $UI/Paused/option ,$UI/Paused/exit  ]
	for i in range(4):
		a[i].modulate = Color.WHITE
		if i == id:
			a[i].modulate = Color(0.6,0.588,0.655)
			a[i].position.y += 10*nudge

func resetPauseIconPositions():
	var a = [ $UI/Paused/unpause , $UI/Paused/restart , $UI/Paused/option ,$UI/Paused/exit  ]
	for i in range(4):
		a[i].position.y = lerp(a[i].position.y, -44.0 + (40.0*i),0.2 )
