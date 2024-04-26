extends Node

var camera :Camera2D= null
var player = null
var gameController = null

var shake = 0.0

signal cameraCHANGED

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
	if is_instance_valid(camera):
		camera.position.x += randf_range(-shake,shake)
		camera.position.y += randf_range(-shake,shake)
	shake = max(0.0,shake-0.1)
