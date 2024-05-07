extends Node2D

@onready var line = $Line2D
@onready var line2 = $Line2D2

var dis = 4

func _ready():
	line.add_point(Vector2.ZERO)
	line2.add_point(Vector2.ZERO)
	
	if is_instance_valid(Global.player):
		line.position = Vector2(0,-dis).rotated( Global.player.dir.angle()  )
		line2.position = Vector2(0,dis).rotated( Global.player.dir.angle() )


func _process(delta):
	if !is_instance_valid(Global.player):
		set_process(false)
		return
	
	line.add_point( to_local(Global.player.global_position) )
	line2.add_point( to_local(Global.player.global_position) )
	
	if Global.player.rolling:
		set_process(false)
		return
	if Global.player.velocity.length() < 300:
		set_process(false)
		return
