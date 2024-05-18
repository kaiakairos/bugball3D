extends Node2D

## 0 = SFX, 1 = MUS, 2 = FS TOG, 3 = ROL TOG, 4 = CLOUD TOG, 5 = DECOR TOG
var state = 0
var totalStates = 12

@onready var scrollContain = $scrollContain

@onready var curLabel = $scrollContain/sfxBar

var music = AudioServer.get_bus_index("Music")
var sound = AudioServer.get_bus_index("Sound")

var slideWait = 0

var selectedFlag = null
@onready var flagArray = [ $scrollContain/Flags/en,$scrollContain/Flags/es,$scrollContain/Flags/pt, $scrollContain/Flags/fr, $scrollContain/Flags/jp, $scrollContain/Flags/de ]

@onready var minimumFlagState = totalStates - flagArray.size()

var flagTick = 0

func _ready():
	displayValues()
	set_process(false)
	Global.connect("changeLanguage",displayValues)

func _process(delta):
	match state:
		0:
			sfxSlider()
		1:
			musSlider()
	
	if Input.is_action_just_pressed("menuSelect"):
		match state:
			2:
				fullscreenToggle(curLabel)
			3:
				Saving.setValue("rollToggle",!Saving.getValue("rollToggle"))
				rollModeToggle(curLabel)
			4:
				Saving.setValue("showClouds",!Saving.getValue("showClouds"))
				Global.cloudTog(Saving.getValue("showClouds"))
				showCloudToggle(curLabel)
			5:
				Saving.setValue("showDecor",!Saving.getValue("showDecor"))
				Global.decorTog(Saving.getValue("showDecor"))
				showDecorToggle(curLabel)
				Global.setLanguage("es")
		if state >= minimumFlagState:
			selectFlag(selectedFlag)
	if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_down_joy"):
		state += 1 + int(state >= minimumFlagState)
		
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_up_joy"):
		if state == minimumFlagState:
			state -= 1
		else:
			state -= 1 + int(state >= minimumFlagState)
	if state >= minimumFlagState:
		if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_right_joy"):
			state += 1
		
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_left_joy"):
			state -= 1
	
	state = clamp(state,0,totalStates-1)
	
	setSelectedLabel(state)
	
	scrollContain.position.y = lerp(scrollContain.position.y,(curLabel.position.y-150.0)*-1,0.2)
	scrollContain.position.y = clamp( scrollContain.position.y,$scrollContain/patch.size.y*-0.5,0 )
	
	shrinkFlags()
	
func setSelectedLabel(id):
	var c = 0
	for label in scrollContain.get_children():
		if label is Label:
			label.modulate = Color.WHITE
			if c - 1 == id:
				label.modulate = Color.GOLD
				curLabel = label
			c += 1
	
	if id >= minimumFlagState:
		selectedFlag = flagArray[id-minimumFlagState]
		curLabel = selectedFlag
	else:
		selectedFlag = null
	
func sfxSlider():
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_left_joy"):
		slideWait = 0
		changeSound(-0.025)
	
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_right_joy"):
		slideWait = 0
		changeSound(0.025)
	
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_right_joy"):
		slideWait += 1
		if slideWait > 20:
			changeSound(0.025)
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_left_joy"):
		slideWait += 1
		if slideWait > 20:
			changeSound(-0.025)
	
func changeSound(amount):
	var newAudio = $scrollContain/sfxBar.value + amount
	newAudio = clamp(newAudio,0.0,2.0)
	AudioServer.set_bus_volume_db(sound, linear_to_db( newAudio ) )
	$scrollContain/sfxBar.value = db_to_linear( AudioServer.get_bus_volume_db(sound) )
	Saving.setValue("sfxVol", newAudio)

func musSlider():
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_left_joy"):
		slideWait = 0
		changeMusic(-0.025)
	
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_right_joy"):
		slideWait = 0
		changeMusic(0.025)
	
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_right_joy"):
		slideWait += 1
		if slideWait > 20:
			changeMusic(0.025)
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_left_joy"):
		slideWait += 1
		if slideWait > 20:
			changeMusic(-0.025)

func changeMusic(amount):
	var newAudio = $scrollContain/musBar.value + amount
	newAudio = clamp(newAudio,0.0,2.0)
	AudioServer.set_bus_volume_db(music, linear_to_db( newAudio ) )
	$scrollContain/musBar.value = db_to_linear( AudioServer.get_bus_volume_db(music) )
	Saving.setValue("musicVol", newAudio)

func fullscreenToggle(label):
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		label.text = tr("OPTION_FULLSCREEN") + " " + tr("DISABLED")
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		label.text = tr("OPTION_FULLSCREEN") + " " + tr("DISABLED")
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		label.text = tr("OPTION_FULLSCREEN") + " " + tr("DISABLED")
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			
		label.text = tr("OPTION_FULLSCREEN") + " " + tr("ENABLED")
	
	
func rollModeToggle(label):
	if Saving.getValue("rollToggle"):
		label.text = tr("OPTION_ROLL_CONTROL") + " " + tr("OPTION_ROLL_TOGGLE")
	else:
		label.text = tr("OPTION_ROLL_CONTROL") + " " + tr("OPTION_ROLL_HOLD")

func showCloudToggle(label):
	if Saving.getValue("showClouds"):
		label.text = tr("OPTION_SHOW_CLOUDS") + " " + tr("YES")
	else:
		label.text = tr("OPTION_SHOW_CLOUDS") + " " + tr("NO")

func showDecorToggle(label):
	if Saving.getValue("showDecor"):
		label.text = tr("OPTION_SHOW_DECOR") + " " + tr("YES")
	else:
		label.text = tr("OPTION_SHOW_DECOR") + " " + tr("NO")

func displayValues():
	
	$scrollContain/sfxBar.value = db_to_linear( AudioServer.get_bus_volume_db(sound) )
	$scrollContain/musBar.value = db_to_linear( AudioServer.get_bus_volume_db(music) )
	
	
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		$scrollContain/fullscreen.text = tr("OPTION_FULLSCREEN") + " " + tr("ENABLED")
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		$scrollContain/fullscreen.text = tr("OPTION_FULLSCREEN") + " " + tr("ENABLED")
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
		$scrollContain/fullscreen.text = tr("OPTION_FULLSCREEN") + " " + tr("ENABLED")
	else:
		$scrollContain/fullscreen.text = tr("OPTION_FULLSCREEN") + " " + tr("DISABLED")
	
	
	rollModeToggle($scrollContain/rollMode)
	showCloudToggle($scrollContain/showClouds)
	showDecorToggle($scrollContain/showDecor)

func disable():
	scrollContain.position.y = 0
	Saving.write_save()

func shrinkFlags():
	flagTick += 1
	for flag in $scrollContain/Flags.get_children():
		if flag is Label:
			continue
		if flag == selectedFlag:
			flag.modulate = lerp(flag.modulate,Color.WHITE,0.2  )
			flag.scale = lerp(flag.scale,Vector2(1,1),0.2  )
			flag.rotation = sin(flagTick*0.1) * 0.1
		else:
			flag.modulate = lerp(flag.modulate,Color.GRAY,0.2  )
			flag.scale = lerp(flag.scale,Vector2(0.75,0.75),0.2  )
			flag.rotation = 0.0

func selectFlag(flag):
	Global.setLanguage(flag.name)
	Saving.setValue("lang",flag.name)
