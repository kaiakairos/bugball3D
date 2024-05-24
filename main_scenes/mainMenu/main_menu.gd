extends Node2D

var tick = 0
var circ = 1.0

## Menu States:
# 0 - main menu ( play, option, credit)
# 1 - play
# 2 - options
# 3 - credits
# 4 - course
# 5 - skins
var menuState :int= 0

var swappin = false

@onready var menuGraphic = $MenuGraphic

#main menu nodes
@onready var MAINFOLDER = $MAINMENU
@onready var playButton = $MAINMENU/play
@onready var optionButton = $MAINMENU/option
@onready var creditButton = $MAINMENU/credits
var menuOptionSelected = 0
@onready var selectDust = preload("res://object_scenes/entity/player/dust/selectDust.tscn")
var SELECTIONMADE = false

#course select nodes
var courseSelect = 0
var numberOfCourses = 3
@onready var COURSEFOLDER = $COURSESELECT
@onready var courseContainer = $COURSESELECT/Courses
var COURSECHOSEN = false
#fuck
var difficulty = 0 # 0 = easy, 1 = med, 2 = hard
@onready var difselect = $COURSESELECT/Difficulty/DifBorder/DifSelect
var lookinAtModifiers = false
var modSelected = 0

var tweenHolder = []

func setMenuState(newState):
	
	for t in tweenHolder:
		if is_instance_valid(t):
			t.stop()
	
	tweenHolder = []
	
	var oldState = menuState
	
	match oldState:
		0:
			var tween = get_tree().create_tween()
			tween.tween_property(MAINFOLDER,"position:y",-300,0.2)
			tweenHolder.append(tween)
			$versionLabel.visible = false
		1:
			if newState == 0:
				var tween = get_tree().create_tween()
				tween.tween_property(COURSEFOLDER,"position:y",300,0.2)
				tweenHolder.append(tween)
				courseContainer.position.y = 110
				$COURSESELECT/Text.position.y = 57
			elif newState == 4:
				var tween = get_tree().create_tween()
				tween.tween_property(COURSEFOLDER,"position:x",-500,0.75).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
				tweenHolder.append(tween)
		2:
			var tween = get_tree().create_tween()
			tween.tween_property($Options,"position:y",300,0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tweenHolder.append(tween)
			$Options.set_process(false)
			$Options.disable()
			Saving.write_save()
		3:
			var tween = get_tree().create_tween()
			tween.tween_property($Credits,"position:y",300,0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tweenHolder.append(tween)
			$Credits.set_process(false)
		4:
			$COURSESELECT/Difficulty/DifBorder/FlameParticle.emitting = false
			lookinAtModifiers = false
		5:
			var tween = get_tree().create_tween()
			tween.tween_property($SkinMenu,"position:x",500.0,0.3)
			tweenHolder.append(tween)
			$SkinMenu/skinChanger.exitMenu()
	match newState:
		0:
			$versionLabel.visible = true
			menuGraphic.menuState = 0
			var tween = get_tree().create_tween()
			tween.tween_property(MAINFOLDER,"position:y",0,0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tweenHolder.append(tween)
		1:
			menuGraphic.huge(true)
			if oldState == 0:
				menuGraphic.menuState = 1
				var tween = get_tree().create_tween()
				tween.tween_property(COURSEFOLDER,"position:y",0,0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
				courseSelect = 0
				var c = courseContainer.get_children()
				for i in c:
					i.hovering = false
				c[0].hovering = true
				c[0].shine()
				tweenHolder.append(tween)
			elif oldState == 4:
				var tween = get_tree().create_tween()
				tween.tween_property(COURSEFOLDER,"position:x",0,0.75).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
				tweenHolder.append(tween)
		2:
			menuGraphic.menuState = 1
			var tween = get_tree().create_tween()
			tween.tween_property($Options,"position:y",0,0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tweenHolder.append(tween)
			$Options.set_process(true)
			$Options.displayValues()
		3:
			menuGraphic.menuState = 1
			var tween = get_tree().create_tween()
			tween.tween_property($Credits,"position:y",0,0.6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
			tweenHolder.append(tween)
			$Credits.set_process(true)
			SkinHandler.UNLOCKSKIN(8)
		4:
			menuGraphic.huge(false)
			var c = courseContainer.get_children()
			#c[0].hovering = false
			$COURSESELECT/Difficulty/courseName.text = tr(c[courseSelect].courseName)
		5:
			var tween = get_tree().create_tween()
			tween.tween_property($SkinMenu,"position:x",0.0,0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			tweenHolder.append(tween)
			$SkinMenu/skinChanger.openMenu()
	
	menuState = newState
	
	print("changed state to: " + str(newState) )
	
func _process(delta):
	tick += 1
	
	$transition.material.set_shader_parameter("circle_size",circ)
	
	match menuState:
		0:
			mainMenu(delta)
		1:
			playMenu(delta)
		2:
			optionMenu(delta)
		3:
			creditMenu(delta)
		4:
			if lookinAtModifiers:
				modifierMenu(delta)
			else:
				courseMenu(delta)
			$COURSESELECT/Difficulty/MenuArrows.visible = !lookinAtModifiers
		5:
			skinMenu(delta)
		
		
func mainMenu(delta):
	
	$MAINMENU/Logo.rotation = sin(tick*6.0*delta) * 0.06
	
	if SELECTIONMADE:
		return
	
	var buttons = [playButton,$MAINMENU/skins,optionButton,creditButton,$MAINMENU/quit]
	
	buttons[menuOptionSelected].modulate = Color.WHITE
	lerpMenuButtons()
	
	var nudge = 0
	
	if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_down_joy"):
		menuOptionSelected += 1
		nudge += 1
		Sound.playSound2D(Vector2(250,150),"res://audio/menuDown.ogg",5.0)
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_up_joy"):
		menuOptionSelected -= 1
		nudge -= 1
		Sound.playSound2D(Vector2(250,150),"res://audio/menuUp.ogg",5.0)
	if menuOptionSelected < 0:
		menuOptionSelected = 4
	elif menuOptionSelected > 4:
		menuOptionSelected = 0
	
	buttons[menuOptionSelected].modulate = Color(0.6,0.588,0.655)
	buttons[menuOptionSelected].position.y += 10 * nudge
	
	if Input.is_action_just_pressed("menuSelect"):
		Sound.playSound2D(Vector2(250,150),"res://audio/menuSelect.ogg",5.0)
		#selectDusty(buttons[menuOptionSelected].position)
		SELECTIONMADE = true
		#await buttons[menuOptionSelected].bump()
		match menuOptionSelected:
			0:
				setMenuState(1) # PLAY
			1:
				setMenuState(5) # SKINS
			2:
				setMenuState(2) # OPTIOSN
			3:
				setMenuState(3) # CREDITS
			4:
				get_tree().quit() # QUIT
		
		SELECTIONMADE = false
	
	
	
func playMenu(delta):
	
	if COURSECHOSEN:
		return
	
	if Input.is_action_just_pressed("menuBack"):
		setMenuState(0)
		Sound.playSound2D(Vector2(250,150),"res://audio/menuBack.ogg",5.0)
		return
	
	var oldCourse = courseSelect
	if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_down_joy"):
		courseSelect += 1
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_up_joy"):
		courseSelect -= 1
	courseSelect = clamp(courseSelect,0,numberOfCourses-1)
	var c = courseContainer.get_children()
	if courseSelect != oldCourse:
		Sound.playSound2D(Vector2(250,150),"res://audio/menuDown.ogg",5.0)
		c[oldCourse].hovering = false
		c[courseSelect].hovering = true
		
		c[courseSelect].shine()
		
		menuGraphic.shove((courseSelect-oldCourse)*4.0)
		
	
	courseContainer.position.y = lerp(courseContainer.position.y,110+(courseSelect * -95.0),0.2)
	$COURSESELECT/Text.position.y = courseContainer.position.y - 87
	
	if Input.is_action_just_pressed("menuSelect"):
		difficulty = -1
		Sound.playSound2D(Vector2(250,150),"res://audio/menuSelect.ogg",5.0)
		if courseSelect > 0:
			#Remove when there are more courses
			#For coming soon courses
			OS.shell_open("https://store.steampowered.com/app/2976450")
			return
		
		#Sound.playSound2D(Vector2(250,150),"res://audio/menuSelection.ogg",5.0)
		
		COURSECHOSEN = true
		c[courseSelect].boing()
		c[courseSelect].shine()
		await get_tree().create_timer(0.2).timeout
		setMenuState(4)
		COURSECHOSEN = false
		
	
func optionMenu(delta):
	if Input.is_action_just_pressed("menuBack"):
		Sound.playSound2D(Vector2(250,150),"res://audio/menuBack.ogg",5.0)
		setMenuState(0)

func creditMenu(delta):
	if Input.is_action_just_pressed("menuBack"):
		Sound.playSound2D(Vector2(250,150),"res://audio/menuBack.ogg",5.0)
		setMenuState(0)
		return
	
	var moveSpeed = 240
	if Input.is_action_pressed("move_down") or Input.is_action_pressed("move_down_joy"):
		$Credits.position.y += -moveSpeed * delta
		if $Credits.position.y == clamp($Credits.position.y,-376,0):
			menuGraphic.move(-1.0 * delta)
	if Input.is_action_pressed("move_up") or Input.is_action_pressed("move_up_joy"):
		$Credits.position.y += moveSpeed * delta
		if $Credits.position.y == clamp($Credits.position.y,-376,0):
			menuGraphic.move(1.0 * delta)
	
	
	$Credits.position.y = clamp($Credits.position.y,-376,0)
	
func courseMenu(delta):
	if Input.is_action_just_pressed("menuBack"):
		setMenuState(1)
		Sound.playSound2D(Vector2(250,150),"res://audio/menuBack.ogg",5.0)
	
	var prevDif = difficulty
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_right_joy"):
		difficulty += 1
		difselect.position.x += 10
		Sound.playSound2D(Vector2(250,150),"res://audio/menuUp.ogg",5.0)
		if difficulty == 2:
			$COURSESELECT/Difficulty/DifBorder/FlameParticle.emitting = true
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_left_joy"):
		difficulty -= 1
		difselect.position.x -= 10
		Sound.playSound2D(Vector2(250,150),"res://audio/menuDown.ogg",5.0)
		$COURSESELECT/Difficulty/DifBorder/FlameParticle.emitting = false
	
	difficulty = clamp(difficulty,0,2)
	difselect.position.x = lerp(difselect.position.x,(difficulty-1)*110.0,0.3)
	if prevDif != difficulty:
		var c = courseContainer.get_children()
		match difficulty:
			0:
				$COURSESELECT/Difficulty/DifBorder/dif.text = tr("EASY")
				var pb = Saving.getValue(c[courseSelect].saveCodeE)
				if pb == null:
					$COURSESELECT/Difficulty/courseName/score.text = "PB: ----"
				else:
					var value = pb - (int(pb/60.0)*60)
					var string = str( value )
					if value < 10.0:
						string = "0" + string
						
					string = string.left(5)
					$COURSESELECT/Difficulty/courseName/score.text = "PB" + ": " + str( int(pb/60.0) ) + ":" + string
				setTimeToBeat(c[courseSelect].rankLimitE,pb)
				
			1:
				$COURSESELECT/Difficulty/DifBorder/dif.text = tr("MEDIUM")
				var pb = Saving.getValue(c[courseSelect].saveCodeM)
				if pb == null:
					$COURSESELECT/Difficulty/courseName/score.text = "PB: ----"
				else:
					var value = pb - (int(pb/60.0)*60)
					var string = str( value )
					if value < 10.0:
						string = "0" + string
						
					string = string.left(5)
					$COURSESELECT/Difficulty/courseName/score.text = "PB" + ": " + str( int(pb/60.0) ) + ":" + string
				setTimeToBeat(c[courseSelect].rankLimitM,pb)
			2:
				$COURSESELECT/Difficulty/DifBorder/dif.text = tr("HARD")
				var pb = Saving.getValue(c[courseSelect].saveCodeH)
				if pb == null:
					$COURSESELECT/Difficulty/courseName/score.text = "PB: ----"
				else:
					var value = pb - (int(pb/60.0)*60)
					var string = str( value )
					if value < 10.0:
						string = "0" + string
						
					string = string.left(5)
					$COURSESELECT/Difficulty/courseName/score.text = "PB" + ": " + str( int(pb/60.0) ) + ":" + string
				setTimeToBeat(c[courseSelect].rankLimitH,pb)
	
	if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_down_joy"):
		lookinAtModifiers = true
		$COURSESELECT/Difficulty/modName.visible = true
		$COURSESELECT/Difficulty/modDesc.visible = true
		$COURSESELECT/Difficulty/courseName.visible = false
		$COURSESELECT/Difficulty/courseName/timetobeat.visible = false
		Sound.playSound2D(Vector2(250,150),"res://audio/menuDown.ogg",5.0)
		return
	
	
	if Input.is_action_just_pressed("menuSelect"):
		menuState = 99
		Sound.playSound2D(Vector2(250,150),"res://audio/menuSelect.ogg",5.0)
		
		var course = courseContainer.get_children()[courseSelect]
		match difficulty:
			0:
				Global.LVLHOLDER = course.easyLevels
				Global.levelSaveCode = course.saveCodeE
				Global.levelRANKHolder = course.rankLimitE
			1:
				Global.LVLHOLDER = course.mediumLevels
				Global.levelSaveCode = course.saveCodeM
				Global.levelRANKHolder = course.rankLimitM
			2:
				Global.LVLHOLDER = course.hardLevels
				Global.levelSaveCode = course.saveCodeH
				Global.levelRANKHolder = course.rankLimitH
		
		ballOut()

func modifierMenu(delta):
	var mods :Array = $COURSESELECT/Difficulty/Modifiers.get_children()
	
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_right_joy"):
		modSelected += 1
		Sound.playSound2D(Vector2(250,150),"res://audio/menuUp.ogg",5.0)
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_left_joy"):
		modSelected -= 1
		Sound.playSound2D(Vector2(250,150),"res://audio/menuDown.ogg",5.0)
	modSelected = clamp(modSelected,0,mods.size()-1)
	
	for m in range(mods.size()):
		mods[m].looking = m == modSelected
	
	# shit code my beloved
	$COURSESELECT/Difficulty/modName.text = tr(mods[modSelected].modName)
	$COURSESELECT/Difficulty/modDesc.text = tr(mods[modSelected].desc)
	
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_up_joy") or Input.is_action_just_pressed("menuBack"):
		lookinAtModifiers = false
		mods[modSelected].looking = false
		$COURSESELECT/Difficulty/modName.visible = false
		$COURSESELECT/Difficulty/modDesc.visible = false
		$COURSESELECT/Difficulty/courseName.visible = true
		$COURSESELECT/Difficulty/courseName/timetobeat.visible = true
		if Global.isPlayerDisqualified():
			$COURSESELECT/Difficulty/courseName/timetobeat.text = ""
		if Input.is_action_just_pressed("menuBack"):
			setMenuState(1)
		return
	
	if Input.is_action_just_pressed("menuSelect"):
		mods[modSelected].press()
		$COURSESELECT/Difficulty/modWarn.visible = Global.isPlayerDisqualified()

func selectDusty(pos):
	var ins = selectDust.instantiate()
	ins.position = pos
	$farticles.add_child(ins)

func ballOut():
	$transition.material.set_shader_parameter("retard",Vector2(0.5,0.5))
	var tween = get_tree().create_tween()
	tween.tween_property(self,"circ",0.0,1.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tween.finished
	get_tree().change_scene_to_file("res://main_scenes/game.tscn")

func lerpMenuButtons():
	var lerpAmount = 0.2
	playButton.position.y = lerp(playButton.position.y,133.0,lerpAmount)
	optionButton.position.y = lerp(optionButton.position.y,195.0,lerpAmount)
	creditButton.position.y = lerp(creditButton.position.y,227.0,lerpAmount)
	$MAINMENU/skins.position.y = lerp($MAINMENU/skins.position.y,165.0,lerpAmount)
	$MAINMENU/quit.position.y = lerp($MAINMENU/quit.position.y,257.0,lerpAmount)

func setTimeToBeat(rankArray,time):
	
	
	
	if time == null:
		$COURSESELECT/Difficulty/courseName/timetobeat.text = ""
		$COURSESELECT/Difficulty/courseName/rank.frame = 6
		return
	
	
	
	var slot = -1
	for rank in rankArray:
		if time > rank:
			slot += 1
	
	$COURSESELECT/Difficulty/courseName/rank.frame = slot + 1
	
	if Global.isPlayerDisqualified():
		$COURSESELECT/Difficulty/courseName/timetobeat.text = ""
		$COURSESELECT/Difficulty/modWarn.visible = true
		return
	
	if slot <= -1:
		
		$COURSESELECT/Difficulty/courseName/timetobeat.text = ""
		return
	
	var nextRank = rankArray[slot]
	var value = nextRank - (int(nextRank/60.0)*60)
	var string = str( value )
	if value < 10.0:
		string = "0" + string
		
	string = string.left(5)
	
	var bb = "[outline_size=12][outline_color=BLACK][center][font_size=24]"
	var displayTime = str( int(nextRank/60.0) ) + ":" + string
	$COURSESELECT/Difficulty/courseName/timetobeat.text=  bb + "time to beat" + ": " + displayTime
	
func skinMenu(delta):
	if Input.is_action_just_pressed("menuBack"):
		setMenuState(0)
		Sound.playSound2D(Vector2(250,150),"res://audio/menuBack.ogg",5.0)
		return
	if Input.is_action_just_pressed("menuSelect"):
		setMenuState(0)
		Sound.playSound2D(Vector2(250,150),"res://audio/menuBack.ogg",5.0)
		return
