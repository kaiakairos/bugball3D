extends Node

var camera :Camera2D= null
var player = null
var gameController = null

var shake = 0.0

var usingController = false

var LVLHOLDER = []

signal cameraCHANGED

var wiggleNoise = FastNoiseLite.new()

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
	shake = max(shake,value)

func _process(delta):
	
	determineController()
	
	if is_instance_valid(camera):
		camera.position.x += randf_range(-shake,shake)
		camera.position.y += randf_range(-shake,shake)
	shake = max(0.0,shake-0.1)
	
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
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
