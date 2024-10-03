extends Line2D

var running = false

var playa = null
var playaVel :Vector2=Vector2.ZERO

@onready var railLine = $CanvasGroup/rail
@onready var part = $CanvasGroup/grind

var playerOffset = 0.0

@export var entranceOnly = false

func _ready():
	$Entrance.position = points[0]
	$Exit.position = points[points.size()-1]
	

func _process(delta):
	#if playa != null:
	#	offsetCamera(playa,playaVel)
	
	part.emitting = playa != null
	
	var camPos = Global.getGlobalCameraPosition()
	railLine.clear_points()
	for point in points:
		
		var mult = 1.1
		if point == points[0] or point == points[points.size()-1]:
			mult = 1.0
		if entranceOnly and point == points[points.size()-1]:
			continue
			
		
		var newPos = to_local(camPos)
		railLine.add_point( ( point*mult ) + ( newPos * ( mult - 1.0 ) * -1 ) )
	
	if playa != null:
		playa.fakeRollSound(playaVel.length())
		part.global_position = playa.ballEpic.global_position
		playa.offsetRollSprite( playa.to_local(camPos) * -playerOffset )
		
		playa.ball.rotateByVelocity(playaVel * 0.1,delta)
		part.global_position = playa.ballEpic.global_position
		
func offsetCamera(p,vel):
	
	var c = p.camera.global_position
	
	#p.camOffset.position = lerp(p.camOffset.position,Vector2.ZERO,0.4)
	
	var lerpSpeed = 0.2
	p.camera.global_position.x = lerp(p.camera.global_position.x,clamp(p.camOffset.global_position.x, p.cameraLimitX.x, p.cameraLimitX.y),lerpSpeed)
	p.camera.global_position.y = lerp(p.camera.global_position.y,clamp(p.camOffset.global_position.y, p.cameraLimitY.x, p.cameraLimitY.y),lerpSpeed)
	
	if c != p.camera.global_position:
		Global.emit_signal("cameraCHANGED")

func _on_entrance_body_entered(body):
	
	if !Global.player.canMove:
		return
		
	runTrack(body,false)


func _on_exit_body_entered(body):
	
	if !entranceOnly:
		runTrack(body,true)
	

func runTrack(body,exit:bool):
	if running:
		return
		
	var velocityAMOUNT :float= body.velocity.length()
	if velocityAMOUNT < 200:
		return
	
	var BOOBS :Array= points.duplicate()
	if exit:
		BOOBS.reverse()
	
	var correctAngle = (BOOBS[1] - BOOBS[0]).normalized()
	var d = body.velocity.normalized().dot(correctAngle)
	if d < 0.8:
		return
	
	
	running = true
	playa = body
	
	body.ballEpic.z_index = 34
	body.bodyOutline.z_index = 34
	
	
	body.canMove = false
	body.inPipe = true
	
	
	body.velocity = Vector2.ZERO
	
	body.global_position = to_global(BOOBS[0])
	
	var i = 1
	for point in BOOBS:
		if point == BOOBS[0]:
			continue
		
		var dis = (point - BOOBS[i-1]).length()
		
		var speed = (dis / velocityAMOUNT) * 0.95
		
		playaVel = (point - BOOBS[i-1]).normalized() * velocityAMOUNT
		part.rotation = playaVel.angle() + (PI/2)
		
		if !is_instance_valid(Global.player):
			return
		
		var tween = get_tree().create_tween().set_parallel(true)
		tween.tween_property(body,"global_position",to_global(point),speed)
		
		if point == BOOBS[1]:
			tween.tween_property(self,"playerOffset",0.1,speed)
		elif point == BOOBS[BOOBS.size()-1]:
			tween.tween_property(self,"playerOffset",0.0,speed)
		
		await tween.finished
		
		i += 1
	
	body.canMove = true
	body.inPipe = false
	
	
	
	var exitAngle = BOOBS[BOOBS.size()-1] - BOOBS[BOOBS.size()-2]
	body.velocity = exitAngle.normalized() * velocityAMOUNT
	body.dir = exitAngle.normalized()
	body.shouldDecelerate = true
	
	playa = null
	body.ballEpic.z_index = 0
	body.bodyOutline.z_index = 0
	running = false
	
	body.offsetRollSprite( Vector2.ZERO )

