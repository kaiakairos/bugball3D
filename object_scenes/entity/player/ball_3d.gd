extends Node3D

@onready var axis = $axis

func _ready():
	SkinHandler.connect("skinChanged",changeSkin)
	changeSkin()

func setRotationBase(dir:Vector2):
	var target = Vector3(0.0,-dir.angle() + (PI/2),0.0)
	axis.global_rotation = target #lerp( axis.global_rotation , target , 0.2 )

func rotateByVelocity(velocity:Vector2,delta):
	
	## Horizontal
	axis.global_rotate(Vector3(0,0,1),velocity.x*delta)
	## Vertical
	axis.global_rotate(Vector3(1,0,0),velocity.y*-delta)

func changeSkin():
	$axis/MeshInstance3D.mesh.material.set_texture(0,SkinHandler.currentBallTexture)
