extends Node2D

@export var door:Door = null

var tick = 0

@onready var faggot = preload("res://object_scenes/items/key/keyblast/key_spirit.tscn")

func _ready():
	set_process(false)

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
	ins.velocity = Global.player.velocity * 0.75
	ins.door = door
	get_parent().add_child(ins)


func _on_area_2d_body_entered(body):
	catch()
	Sound.playSound2D(Vector2(250,150),"res://audio/getKey.ogg",2.0)
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered():
	set_process(true)


func _on_visible_on_screen_notifier_2d_screen_exited():
	set_process(false)
