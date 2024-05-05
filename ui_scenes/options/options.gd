extends Node2D

## 0 = SFX, 1 = MUS, 2 = FS TOG, 3 = ROL TOG, 4 = CLOUD TOG, 5 = DECOR TOG
var state = 0
var totalStates = 6

@onready var scrollContain = $scrollContain

@onready var curLabel = $scrollContain/sfxBar

var music = AudioServer.get_bus_index("Music")
var sound = AudioServer.get_bus_index("Sound")

var slideWait = 0

func _ready():
	displayValues()

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
				showCloudToggle(curLabel)
			5:
				Saving.setValue("showDecor",!Saving.getValue("showDecor"))
				showDecorToggle(curLabel)
	
	if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_down_joy"):
		state += 1
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_up_joy"):
		state -= 1
	
	state = clamp(state,0,totalStates-1)
	
	setSelectedLabel(state)
	
func setSelectedLabel(id):
	var c = 0
	for label in scrollContain.get_children():
		if label is Label:
			label.modulate = Color.WHITE
			if c - 1 == id:
				label.modulate = Color.GOLD
				curLabel = label
			c += 1

func sfxSlider():
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_left_joy"):
		slideWait = 0
		changeSound(-0.05)
	
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_right_joy"):
		slideWait = 0
		changeSound(0.05)
	
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
		changeMusic(-0.05)
	
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_right_joy"):
		slideWait = 0
		changeMusic(0.05)
	
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
		
		label.text = "fullscreen: DISABLED"
		
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			
		label.text = "fullscreen: ENABLED"
	
	Saving.write_save()
	
func rollModeToggle(label):
	if Saving.getValue("rollToggle"):
		label.text = "roll control mode: TOGGLE"
	else:
		label.text = "roll control mode: HOLD"

func showCloudToggle(label):
	if Saving.getValue("showClouds"):
		label.text = "show clouds?: YES"
	else:
		label.text = "show clouds?: NO"

func showDecorToggle(label):
	if Saving.getValue("showDecor"):
		label.text = "show decor?: YES"
	else:
		label.text = "show decor?: NO"

func displayValues():
	
	$scrollContain/sfxBar.value = db_to_linear( AudioServer.get_bus_volume_db(sound) )
	$scrollContain/musBar.value = db_to_linear( AudioServer.get_bus_volume_db(music) )
	
	
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		$scrollContain/fullscreen.text = "fullscreen: ENABLED"
		
	else:
		$scrollContain/fullscreen.text = "fullscreen: DISABLED"
	
	
	rollModeToggle($scrollContain/rollMode)
	showCloudToggle($scrollContain/showClouds)
	showDecorToggle($scrollContain/showDecor)
