extends Node3D

@onready var camera = $Camera3D
@onready var floor = $floor

var menuState = 0

var rollSpeed = 12.0

var cloudTarget = 1.207

func _process(delta):
	$texture.position.z = lerp( $texture.position.z , cloudTarget , 0.2 )
	match menuState:
		0:
			$ball3d.rotate_x(rollSpeed*delta)
			$sky.rotate_object_local(Vector3(0,1,0),-2.0*delta)
			floor.position.z -= rollSpeed * delta
			if floor.position.z < -12.8:
				floor.position.z += 2.56
			rollSpeed = lerp(rollSpeed,12.0,0.6)
			camera.global_rotation = lerp(camera.global_rotation, $CAM.global_rotation, 0.2  )
			camera.position = lerp(camera.position, $CAM.position, 0.2  )
			camera.fov = lerp(camera.fov,48.2,0.2)
			cloudTarget = 1.207
		1:
			$ball3d.rotate_x(rollSpeed*delta)
			floor.position.z -= rollSpeed * delta
			$flowers.position.z -= rollSpeed * delta
			if floor.position.z < -12.8:
				floor.position.z += 2.56
			rollSpeed = lerp(rollSpeed,0.0,0.15)
			camera.global_rotation = lerp(camera.global_rotation, $BASE.global_rotation, 0.2  )
			camera.position = lerp(camera.position, $BASE.position, 0.2  )
			camera.fov = lerp(camera.fov,35.0,0.2)

func shove(amount):
	rollSpeed = amount
	cloudTarget += amount * -0.1

func huge(really):
	if really:
		$BASE.position.x = 8.0
	else:
		$BASE.position.x = 10.0

func move(amount):
	floor.position.z += amount
	$flowers.position.z += amount
	cloudTarget += amount
