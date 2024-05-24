extends Node

var camera :Camera2D= null
var player = null
var gameController = null

var shake = 0.0

var usingController = false

var LVLHOLDER = []
var levelSaveCode:String=""
var levelRANKHolder = []

signal cameraCHANGED

var wiggleNoise = FastNoiseLite.new()

var clearSaveTick = 0

signal disableCloud
signal enableCloud

signal disableDecor
signal enableDecor

signal changeLanguage

var isFinalLevel = false

################ MODIFIERS ##########################
var tenRollSpeed = false
var mirrored = false
var fuse = false
var doubleBounce = false

func isPlayerDisqualified():
	
	if tenRollSpeed:
		return true
	if doubleBounce:
		return true
	if fuse:
		return true
	if mirrored:
		return true
	
	return false

#togglers
func toggleRoll():
	tenRollSpeed = !tenRollSpeed
	return tenRollSpeed

func toggleMirrored():
	mirrored = !mirrored
	return mirrored

func toggleFuse():
	fuse = !fuse
	return fuse

func toggleBounce():
	doubleBounce = !doubleBounce
	return doubleBounce

# getters
func getRoll():
	return tenRollSpeed

func getMirrored():
	return mirrored

func getFuse():
	return fuse

func getBounce():
	return doubleBounce

######################################################



func setLanguage(lang):
	TranslationServer.set_locale(lang)
	emit_signal("changeLanguage")

func cloudTog(yes):
	if yes:
		emit_signal("enableCloud")
	else:
		emit_signal("disableCloud")

func decorTog(yes):
	if yes:
		emit_signal("enableDecor")
	else:
		emit_signal("disableDecor")

func getGlobalCameraPosition():
	if is_instance_valid(camera):
		return camera.global_position
	return Vector2(250,150)

func reloadLevel():
	if !is_instance_valid(gameController):
		get_tree().reload_current_scene()
		return
	
	gameController.reloadLevel()

func nextLevel():
	if !is_instance_valid(gameController):
		get_tree().reload_current_scene()
		return
	
	gameController.nextLevel()

func shakeCamera(value):
	value = min(value,40)
	shake = max(shake,value)

func _process(delta):
	
	determineController()
	
	if is_instance_valid(camera):
		camera.position.x += randf_range(-shake,shake)
		camera.position.y += randf_range(-shake,shake)
	shake = max(0.0,shake-0.1)
	
	if Input.is_action_pressed("clearSave"):
		clearSaveTick += 1
		if clearSaveTick > 300:
			Saving.clearSave()
			#get_tree().change_scene_to_file("res://main_scenes/compiler/loadin.tscn")
			get_tree().quit()
	else:
		clearSaveTick = 0
	
func determineController():
	var newDir = Vector2.ZERO
	newDir.x = Input.get_action_raw_strength("move_right_joy") - Input.get_action_raw_strength("move_left_joy")
	newDir.y = Input.get_action_raw_strength("move_down_joy") - Input.get_action_raw_strength("move_up_joy")
	if newDir.length() > 0.5:
		usingController = true
		return
	
	if Input.is_action_just_pressed("move_down"):
		usingController = false
		return
	if Input.is_action_just_pressed("move_up"):
		usingController = false
		return
	if Input.is_action_just_pressed("move_left"):
		usingController = false
		return
	if Input.is_action_just_pressed("move_right"):
		usingController = false
		return
