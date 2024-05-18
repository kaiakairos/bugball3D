extends CharacterBody2D

@onready var bodyLine = $BodyLine
@onready var bodyOutline = $BodyOutline

@onready var ball = $SubViewport/ball3d
@onready var vpSprite = $BallCenter/viewportSprite


@onready var camera = $Camera2D

@onready var skid = preload("res://object_scenes/entity/skid/skid_mark.tscn")

var bounceAmount = 0.81

var dir := Vector2.UP
var speed :int = 10000

var turnSpeed :float = 0.15 # How long ( in seconds ) does it take him to turn halfway ?

var previousTurnArray :Array= []
var bodyLag :int= 6 # How large is the array ?
var bodySeperation :float= 6.0 # How far apart are the bugs segments ?

var feetFlip :bool = false
var tick :int = 0.0

var rolling = false

var tennaOneGlob = Vector2.ZERO
var tennaTwoGlob = Vector2.ZERO

var shouldDecelerate = false

var jumpVelocity = 0.0
var air = 0.0

var worldHeight = 0.0

@export var cameraLimitX = Vector2(250,250)
@export var cameraLimitY = Vector2(150,150)
@export var startingAngle = Vector2(0,-1)

var falling = false

var rayLength = 1.0

var canMove = false

## dusts

var soundSubtract = 1.0

#@onready var landDust = preload("res://object_scenes/entity/player/dust/dust_land.tscn")
@onready var bounceDust = preload("res://object_scenes/entity/player/dust/bouncedust.tscn")

var jumpBufferTicks = 0

func _ready():
	
	
	dir = startingAngle.normalized()
	#$head/Tenna.rotation = startingAngle.angle()
	#$head/Tenna2.rotation = startingAngle.angle()
	$head.rotation = startingAngle.rotated((PI/2)).angle()
	snapCameraStart()
	
	for i in range(bodyLag):
		previousTurnArray.append(startingAngle)
	
	vpSprite.texture = $SubViewport.get_texture()

	Global.camera = camera
	Global.player = self
	
	if Global.mirrored:
		camera.zoom = Vector2(1,-1)
	if Global.doubleBounce:
		bounceAmount = 1.2
	
	await get_tree().create_timer(0.5).timeout
	$Camera2D/cover.visible = false
	if Global.gameController == null:
		canMove = true
	
	
func _physics_process(delta):
	tick += 1

func _process(delta):
	
	$holeCast.target_position = velocity.normalized() * rayLength
	
	if falling:
		
		fallingMovement(delta)
		return
	
	if $boostCast.is_colliding() and air <= 0.0:
		var col = $boostCast.get_collider()
		if col != null:
			velocity += Vector2(20,0).rotated(-col.get_parent().angle)
			$CanvasGroup/DASH.emitting = true
	else:
		$CanvasGroup/DASH.emitting = false
	
	if Input.is_action_just_pressed("jump"):
		jumpBufferTicks = 10
	if	jumpBufferTicks > 0 and air <= 0.0:
		# Jump code
		Sound.playSound2D(global_position,"res://audio/jump.ogg",0.0)
		air = 0.0
		jumpVelocity = 10.0
		velocity += dir.normalized() * 1000 * delta
		jumpBufferTicks = 0
	
	if jumpBufferTicks > 0:
		jumpBufferTicks -= 1
	
	jumpVelocity -= 40.0 * delta
	var keep = air
	air = max(0.0,air + jumpVelocity)
	
	if keep != 0.0 and air == 0.0:
		landed() 
	
	setZHeight(delta)
	
	if air > 0.0:
		jumpMovement(delta)
		rolling = true
		getValues()
		vpSprite.modulate.a = 1.0
		offsetCamera()
		return
	
	var curRol = rolling
	
	if Saving.getValue("rollToggle"):
		if Input.is_action_just_pressed("roll"):
			rolling = !rolling
	else:
		rolling = Input.is_action_pressed("roll")
	
	if $boostCast.is_colliding():
		rolling = true
	getValues()
	
	if curRol != rolling and !rolling:
		if velocity.length() > 500.0:
			var vol = (velocity.length() - 500) / 2000.0
			vol = clamp(vol,0.0,1.0)
			Sound.playSound2D(global_position,"res://audio/tire.ogg",linear_to_db(vol),randf_range(0.6,0.8))
			
			var i = skid.instantiate()
			i.global_position = global_position
			i.z_index = z_index - 1
			get_parent().add_child(i)
			
	var newDir = Vector2.ZERO
	if Global.usingController:
		newDir.x = Input.get_action_raw_strength("move_right_joy") - Input.get_action_raw_strength("move_left_joy")
		newDir.y = Input.get_action_raw_strength("move_down_joy") - Input.get_action_raw_strength("move_up_joy")
		
		if newDir.length() < 0.5:
			newDir = Vector2.ZERO
		else:
			newDir = newDir.normalized()
			
		
		
	else:
		newDir.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
		newDir.y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	
	if Global.mirrored:
		newDir *= Vector2(1,-1)
	
	if !canMove:
		newDir = Vector2.ZERO
	
	if rolling:
		rollingMovement(newDir,delta)
	else:
		staticMovement(newDir,delta)
	
	
	
	$CanvasGroup/dust.emitting = rolling and velocity.length() > 100
	$CanvasGroup/dust.scale_amount_max = min(velocity.length() / 300.0,1.5)
	
	offsetCamera()
	checkIfHole()
	
	if Global.fuse and canMove:
		modulate.r += 0.0025
		if modulate.r >= 2.15:
			Global.reloadLevel()
			canMove = false
			$explode.play("default")
			$explode.visible = true
			Sound.playSound2D(global_position,"res://audio/explode.ogg",2.0)
			
func rollingMovement(newDir,delta):
	
	
	if !falling:
		var target = velocity * -0.02
		if target.length() < 6:
			target = velocity.normalized() * -6
		$holeCast.position = lerp($holeCast.position,target,0.1)
	
	
	var slowDownDelta = 1 - pow(2,   (  -delta / 3.8168 )  )
	
	velocity += newDir * delta * 500  * ((9 * int(Global.tenRollSpeed))+1 )
	
	if !$boostCast.is_colliding():
		if newDir.x == 0:
			velocity.x = lerp(velocity.x,0.0,slowDownDelta)
		if newDir.y == 0:
			velocity.y = lerp(velocity.y,0.0,slowDownDelta)
	
	ball.rotateByVelocity(velocity * 0.1,delta)
	
	tennaOneGlob = $head/Tenna.global_position
	tennaTwoGlob = $head/Tenna2.global_position
	
	if $sandCast.is_colliding():
		velocity = lerp(velocity,Vector2.ZERO,0.5)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		bounced(collision.get_normal())
		if !$boostCast.is_colliding():
			velocity *= bounceAmount
	
	if velocity != Vector2.ZERO:
		dir = velocity.normalized()
		previousTurnArray.append( dir.normalized() )
		previousTurnArray.remove_at(0)
	
	setBodyPositions(true)
	
	speed = velocity.length() / delta
	
	if speed > 11000:
		shouldDecelerate = true
	
	
	if tick % 8 == 0:
		
		var vol = ((velocity.length() / 1000.0) * 42.0) - 24.0
		vol = clamp(vol,-24,0.0)
		var pitch = velocity.length() / 1000.0
		pitch = clamp(pitch,0.01,2.5)
		
		Sound.playSound2D(global_position,"res://audio/speed.ogg",vol,pitch)
		
	

func staticMovement(newDir,delta):
	
	
	if !falling:
		$holeCast.position = Vector2.ZERO
	
	if newDir != Vector2.ZERO:
		dir = dir.slerp(newDir, 1 - pow( 2 , ( -delta / turnSpeed ) )  )
		
		speed = max(lerp(speed,10000, 0.1 ),10000)
		velocity = dir.normalized() * speed * 0.01666
		
		tennaOneGlob = $head/Tenna.global_position
		tennaTwoGlob = $head/Tenna2.global_position
		
		move_and_slide()
		
		velocity = get_real_velocity()
		
		previousTurnArray.append( dir.normalized() )
		previousTurnArray.remove_at(0)
		
		setBodyPositions(true)
		
		if tick % 5 == 0:
			flipFeet()
		
		shouldDecelerate = false
		if speed > 11000:
			shouldDecelerate = true
		
	else:
		
		if shouldDecelerate:
			speed = lerp(speed,0,0.1)
			if speed <= 100:
				shouldDecelerate = false
		else:
			speed = 0
			shouldDecelerate = false
		velocity = dir.normalized() * speed * 0.01666
		
		move_and_slide()
		
	
		setBodyPositions(velocity.length() > 1.0)
		
		$head/Tenna.rotation = lerp_angle( $head/Tenna.rotation, 0.0 , 0.05 )
		$head/Tenna2.rotation = lerp_angle( $head/Tenna2.rotation, 0.0 , 0.05 )
	
	ball.setRotationBase(dir)
	
func flipFeet():
	$body/Feet.frame = int(!feetFlip)
	$head/Feet.frame = int(feetFlip)
	$tail/Feet.frame = int(feetFlip)
	Sound.playSound2D(global_position,"res://audio/footstep.ogg",4.0)
	
	feetFlip = !feetFlip

func getValues():
	if rolling:
		
		bodySeperation = lerp(bodySeperation,0.01,0.8)
		$head.scale = lerp($head.scale,Vector2.ZERO,0.2)
		$body.scale = lerp($body.scale,Vector2.ZERO,0.2)
		$tail.scale = lerp($tail.scale,Vector2.ZERO,0.2)
		turnSpeed = lerp(turnSpeed,2.0,0.2)
		bodyOutline.width = lerp(bodyOutline.width,17.5,0.4)
		
		vpSprite.scale = Vector2(0.35,0.35)
		vpSprite.modulate.a = 1.0
		
	else:
		
		bodySeperation = lerp(bodySeperation,6.0,0.2)
		$head.scale = lerp($head.scale,Vector2(1,1),0.2)
		$body.scale = lerp($body.scale,Vector2(1,1),0.2)
		$tail.scale = lerp($tail.scale,Vector2(1,1),0.2)
		turnSpeed = lerp(turnSpeed,0.15, 0.1   )
		bodyOutline.width = lerp(bodyOutline.width,14.0,0.2)
		
		vpSprite.scale = lerp(vpSprite.scale,Vector2(0.1,0.1),0.3)
		vpSprite.modulate.a = lerp(vpSprite.modulate.a,0.0,0.8)

func setBodyPositions(moving):

	
	$tail.position = $body.position + (previousTurnArray[0] * -bodySeperation )
	$body.position = (previousTurnArray[ bodyLag / 2 ] * -bodySeperation )
	
	if moving:
		$head.rotation = dir.rotated((PI/2)).angle()
		
		var tennaOneDifference =  ($head/Tenna.global_position - tennaOneGlob).rotated( (PI/2) )
		$head/Tenna.global_rotation = lerp_angle( $head/Tenna.global_rotation, tennaOneDifference.angle() , 0.2 )
		$head/Tenna.rotation = clamp($head/Tenna.rotation,-(PI/6),(PI/6))
		var tennaTwoDifference =  ($head/Tenna2.global_position - tennaTwoGlob).rotated( (PI/2) )
		$head/Tenna2.global_rotation = lerp_angle( $head/Tenna2.global_rotation, tennaTwoDifference.angle() , 0.2 )
		$head/Tenna2.rotation = clamp($head/Tenna2.rotation,-(PI/6),(PI/6))
		
		
	$body.rotation = $body.position.rotated((PI/2) * 3).angle()
	$tail.rotation = ($tail.position - $body.position).rotated((PI/2) * 3).angle()
		
	bodyLine.clear_points()
	bodyLine.add_point( Vector2.ZERO )
	bodyLine.add_point( $body.position )
	bodyLine.add_point( $tail.position )
		
	bodyOutline.points = bodyLine.points

func jumpMovement(delta):
	
	
	if !falling:
		$holeCast.position = velocity.normalized() * 10
	
	tennaOneGlob = $head/Tenna.global_position
	tennaTwoGlob = $head/Tenna2.global_position
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		bounced(collision.get_normal())
		#velocity *= bounceAmount
	
	ball.rotateByVelocity(velocity * 0.05,delta)
	
	if velocity != Vector2.ZERO:
		dir = velocity.normalized()
		previousTurnArray.append( dir.normalized() )
		previousTurnArray.remove_at(0)
	
	setBodyPositions(true)
	
	speed = velocity.length() / delta
	
	if speed > 11000:
		shouldDecelerate = true

func setZHeight(delta):
	var s = max(0.0,1.0 + air*0.03)
	$BallCenter.scale = Vector2( s,s )

func setZHeightFALL(delta):
	var s = max(0.0,1.0 + air*0.03)
	return Vector2( s,s )

func offsetCamera():
	
	var c = camera.global_position
	
	var balls =  velocity * 0.1
	
	if balls.length() < 20:
		balls = Vector2.ZERO
	elif balls.length() > 128:
		balls = balls.normalized() * 128
	$cameraOffset.position = lerp($cameraOffset.position,balls,0.4)
	
	var lerpSpeed = 0.2
	camera.global_position.x = lerp(camera.global_position.x,clamp($cameraOffset.global_position.x, cameraLimitX.x, cameraLimitX.y),lerpSpeed)
	camera.global_position.y = lerp(camera.global_position.y,clamp($cameraOffset.global_position.y, cameraLimitY.x, cameraLimitY.y),lerpSpeed)
	
	if c != camera.global_position:
		Global.emit_signal("cameraCHANGED")
	
func snapCameraStart():
	var c = camera.global_position
	
	camera.global_position.x = clamp($cameraOffset.global_position.x, cameraLimitX.x, cameraLimitX.y)
	camera.global_position.y = clamp($cameraOffset.global_position.y, cameraLimitY.x, cameraLimitY.y)
	
	if c != camera.global_position:
		Global.emit_signal("cameraCHANGED")

func checkIfHole():
	
	if !canMove:
		return
	
	if $holeCast.is_colliding():
		
		var collider = $holeCast.get_collider()
		if !is_instance_valid(collider):
			return
		
		var win = collider.get_parent().amWin
		
		if $islandCast.is_colliding() and !win:
			jumpVelocity = 0.0
			return
		
		if win:
			collider.get_parent().get_parent().entered()
			Sound.playSound2D(global_position,"res://audio/partyHorn.ogg",-10.0)
			if is_instance_valid(Global.gameController):
				Global.gameController.pauseTimer()
			
		air = 0.0
		falling = true
		
		if velocity.length() > 300:
			velocity = velocity.normalized() * 300
		
		velocity += dir.normalized() * 10
		
		setZHeightFALL(0)
		
		Sound.playSound2D(global_position,"res://audio/fall.ogg",0.0)
		
		await get_tree().create_timer(1.0).timeout
		
		if win:
			Global.nextLevel()
		else:
			Global.reloadLevel()
		
		return
	
	jumpVelocity = 0.0

func fallingMovement(delta):
	
	jumpVelocity -= 5.0 * delta
	air = air + jumpVelocity
	
	jumpMovement(delta)
	rolling = true
	getValues()
	offsetCamera()
	
	var scalen = setZHeightFALL(delta)
	$BallCenter.scale = scalen
	bodyLine.scale = scalen
	bodyOutline.scale = scalen
	
	$holeCast.position = $holeCast.target_position * (32.0 - (scalen.x*32.0))
	
	
	if !$holeCast.is_colliding():
		
		$holeCast.target_position = velocity * -1
		$holeCast.force_raycast_update()
			
		if $holeCast.is_colliding():
			var norm = $holeCast.get_collision_normal()
			if norm != Vector2.ZERO:
				velocity = velocity.bounce(norm) * 0.99
				Global.shakeCamera(velocity.length() / 300.0)
				bounceSound()
				move_and_slide()
			
		$holeCast.target_position = velocity.normalized() * rayLength
	
	
	velocity *= 0.99

func landed():
	if falling:
		return
	
	Sound.playSound2D(global_position,"res://audio/brush.ogg",-4.0)
	$CanvasGroup/LAND.emitting = true

func bounced(normal):
	if falling:
		return
	
	if velocity.length() > 100 and velocity.normalized().dot(normal) > 0.3:
		var ins = bounceDust.instantiate()
		ins.rotation = normal.angle()
		ins.position = normal * -12
		$CanvasGroup.add_child(ins)
		bounceSound()
	
	if velocity.length() > 25:
		Sound.playSound2D(global_position,"res://audio/brush.ogg",-4.0)
		
	Global.shakeCamera(velocity.length() / 300.0)
	
func bounceSound():
	var pitch = 1.5 - (velocity.length() / 1000.0)
	var keep = pitch
	var vol = (velocity.length() / 75.0) - 5.0
	
	pitch = clamp(pitch,0.5,1.5)
	vol = clamp(vol,-10,5)
	
	if falling:
		vol += soundSubtract
		soundSubtract -= 1.0
	
	Sound.playSound2D(global_position,"res://audio/bounce.ogg",vol,pitch)
	


func _on_explode_animation_finished():
	$explode.visible = false


func _on_explode_frame_changed():
	if $explode.frame >= 5:
		$head.visible = false
		$body.visible = false
		$tail.visible = false
		$BallCenter.visible = false
		$BodyOutline.visible = false
		$BodyLine.visible = false
