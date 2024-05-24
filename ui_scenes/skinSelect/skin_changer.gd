extends Node2D

@onready var label = $text
@onready var unlockText = $toUnlock

@onready var arrowUp = $arrowUp
@onready var arrowDown = $arrowDown

var skinAmount := 9999
var currentSkin = 0

func _ready():
	skinAmount = SkinHandler.skins.size() -1
	setDefaultData()
	set_process(false)
	
func _process(delta):
	arrowUp.visible = currentSkin != 0
	arrowDown.visible = currentSkin != skinAmount
	
	if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_down_joy"):
		currentSkin += 1
		currentSkin = clamp(currentSkin,0,skinAmount)
		bump(1)
		Sound.playSound2D(Vector2(250,150),"res://audio/menuDown.ogg",5.0)
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_up_joy"):
		currentSkin -= 1
		currentSkin = clamp(currentSkin,0,skinAmount)
		bump(-1)
		Sound.playSound2D(Vector2(250,150),"res://audio/menuUp.ogg",5.0)
	
	label.position.y = lerp( label.position.y , 0.0,0.2 )
	
	if SkinHandler.setSkin(currentSkin):
		label.text = SkinHandler.getName(currentSkin)
		Saving.setValue("skinID",currentSkin)
	else:
		label.text = "???????"
	unlockText.text = SkinHandler.getInfo(currentSkin)
	
func bump(dir):
	label.position.y = dir * 10

func exitMenu():
	Saving.write_save()
	set_process(false)

func openMenu():
	setDefaultData()
	set_process(true)

func setDefaultData():
	currentSkin = Saving.getValue("skinID")
	if currentSkin == null:
		currentSkin = 0
	currentSkin = clamp(currentSkin,0,skinAmount)
	if SkinHandler.setSkin(currentSkin):
		label.text = SkinHandler.getName(currentSkin)
	else:
		label.text = "???????"
	unlockText.text = SkinHandler.getInfo(currentSkin)
	
	arrowUp.visible = currentSkin != 0
	arrowDown.visible = currentSkin != skinAmount
