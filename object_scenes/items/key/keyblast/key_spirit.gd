extends CharacterBody2D

var door = null
var multi = 1.0


var BALLS = false

func _ready():
	if !is_instance_valid(door):
		queue_free()
	$KeySpirit/CPUParticles2D4.emitting = true
	
	$KeySpirit/CPUParticles2D3.rotation = door.angle
	
func _process(delta):
	
	if BALLS:
		$KeySpirit/CPUParticles2D3.position += velocity.normalized()
		return
	
	var cam = to_local(Global.getGlobalCameraPosition())
	$KeySpirit.position = cam * 0.02 * -1
	
	var dir = to_local(door.get_global())
	
	velocity += dir.normalized() * multi
	
	var prev = position
	move_and_slide()
	
	$KeySpirit/CPUParticles2D4.position = position - prev
	
	multi *= 1.2
	
	if dir.length() < 48:
		
		global_position = door.get_global()
		
		door.openDoor()
		BALLS = true
		
		$KeySpirit/sprite.visible = false
		$KeySpirit/CPUParticles2D2.visible = false
		$Shadow.visible = false
		
		$KeySpirit/CPUParticles2D.emitting = false
		$KeySpirit/CPUParticles2D3.emitting = true
		
		Global.shakeCamera(3.0)
		
		await get_tree().create_timer(1.0).timeout
		queue_free()
