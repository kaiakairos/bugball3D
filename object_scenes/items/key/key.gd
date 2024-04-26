extends Node2D

@export var door:Door = null

var tick = 0

@onready var faggot = preload("res://object_scenes/items/key/keyblast/key_spirit.tscn")

func _process(delta):
	var cam = to_local(Global.getGlobalCameraPosition())
	
	var dis = (sin(tick*0.08)*0.01) + 0.02
	for i in $keymodel.get_children():
		i.position = cam * dis * -1
		
		dis += 0.005
		i.rotate(4.0*delta)
	
	tick += 1

func catch():
	var ins = faggot.instantiate()
	ins.position = position
	ins.velocity = Global.player.velocity
	ins.door = door
	get_parent().add_child(ins)


func _on_area_2d_body_entered(body):
	catch()
	queue_free()
