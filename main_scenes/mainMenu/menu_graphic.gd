extends Node3D

@onready var camera = $Camera3D
@onready var floor = $floor

var menuState = 0

var rollSpeed = 12.0

func _process(delta):
	match menuState:
		0:
			$ball3d.rotate_x(rollSpeed*delta)
			floor.position.z -= rollSpeed * delta
			if floor.position.z < -12.8:
				floor.position.z += 2.56
			rollSpeed = lerp(rollSpeed,12.0,0.6)
			camera.global_rotation = lerp(camera.global_rotation, $CAM.global_rotation, 0.2  )
			camera.position = lerp(camera.position, $CAM.position, 0.2  )
			camera.fov = lerp(camera.fov,48.2,0.2)
		1:
			$ball3d.rotate_x(rollSpeed*delta)
			floor.position.z -= rollSpeed * delta
			if floor.position.z < -12.8:
				floor.position.z += 2.56
			rollSpeed = lerp(rollSpeed,0.0,0.15)
			camera.global_rotation = lerp(camera.global_rotation, $BASE.global_rotation, 0.2  )
			camera.position = lerp(camera.position, $BASE.position, 0.2  )
			camera.fov = lerp(camera.fov,35.0,0.2)

func shove(amount):
	rollSpeed = amount

func huge(really):
	if really:
		$BASE.position.x = 8.0
	else:
		$BASE.position.x = 10.0
