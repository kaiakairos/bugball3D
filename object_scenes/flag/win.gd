extends Node2D

@export var radius :int= 32
@onready var hole = preload("res://world_scenes/hole/hole.tscn")

func _ready():
	
	var ins = hole.instantiate()
	
	var newpoly = PackedVector2Array()
	for i in range(16):
		newpoly.append( Vector2(radius,0).rotated((PI/8)*i) )
	ins.polygon = newpoly
	ins.amWin = true
	
	add_child(ins)

func entered():
	$CanvasGroup/fuck.emitting = true
