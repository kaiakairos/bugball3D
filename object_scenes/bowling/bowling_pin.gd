extends CharacterBody2D

@onready var canvas = $layers
@onready var sprite = $killedSprite
@onready var knocked :bool= false

@onready var holeRay :RayCast2D = $holecast
@onready var surprise :CanvasGroup = $surprise

var knockVelocity :Vector2 = Vector2.ZERO
var vertVelocity :float = 2.0
var height :float = 0.01

var bounceRand = Vector2.ZERO

var sleep = false

var fall = false

func _process(delta):
	
	if sleep:
		return
		
	if fall:
		var camPos = to_local(Global.getGlobalCameraPosition())
		
		sprite.position = camPos * -height * 0.6
		sprite.scale.x = max(height + 0.8,0.0)
		sprite.scale.y = max(height + 0.8,0.0)
		
		height += vertVelocity * 0.01
		vertVelocity -= 0.1
		sprite.modulate.a = lerp( sprite.modulate.a, 0.0, 0.1 )
		return
	
	if !knocked:
		# move around 3d object
		var camPos = to_local(Global.getGlobalCameraPosition())
		var i = 0
		for layer in canvas.get_children():
			layer.position = camPos * -((0.02*i))

			i += 1
	else:
		
		var collision = move_and_collide(knockVelocity * delta)
		if collision:
			# bounced on wall
			knockVelocity = knockVelocity.bounce(collision.get_normal())
			directPin()
		
		if height <= 0.1:
			knockVelocity = lerp( knockVelocity, Vector2.ZERO, 0.05 )
		
		var camPos = to_local(Global.getGlobalCameraPosition())
		
		sprite.position = camPos * -height
		sprite.scale = Vector2( height + 0.8,height + 0.8  )
		height += vertVelocity * 0.01
		vertVelocity -= 0.1
		
		if height <= 0.0:
			
			if holeRay.is_colliding():
				fall = true
				return
			
			vertVelocity *= -0.6
			height = 0.001
			directPin()
		
		if knockVelocity.length() < 2.0:
			sprite.position = Vector2.ZERO
			sleep = true

func _on_area_2d_body_entered(body):
	if knocked:
		return
	get_parent().knockPin(self)
	knocked = true
	
	var rand :float= randi_range( -45,45 )
	#rollBounceRand()
	
	knockVelocity = body.velocity.rotated( deg_to_rad(rand) )
	directPin()
	
	canvas.visible = false
	sprite.visible = true
	$PinShadow.visible = true
	
func directPin():
	Sound.playSound2D(global_position,"res://audio/jump.ogg",-7.0)
	sprite.rotation = knockVelocity.rotated( (PI/2) ).angle()
	sprite.rotation += deg_to_rad( randi_range( -25,25 ) )
	
	$PinShadow.rotation = sprite.rotation
