extends Node2D

@export var radius :int= 32
@onready var hole = preload("res://world_scenes/hole/hole.tscn")

func _ready():
	
	$CanvasGroup/alexyiik.emitting = Global.isFinalLevel
	
	var ins = hole.instantiate()
	
	var newpoly = PackedVector2Array()
	for i in range(8):
		newpoly.append( Vector2(radius,0).rotated((PI/4)*i) )
	ins.polygon = newpoly
	ins.amWin = true
	
	add_child(ins)

func entered():
	$CanvasGroup/fuck.emitting = true
	if Global.isFinalLevel:
		Global.gameController.endMusic()
		Sound.playSound2D(global_position,"res://audio/whistle.ogg",-2.0)
