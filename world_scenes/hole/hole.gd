extends Polygon2D

@onready var wallScene = preload("res://world_scenes/wall/wall.tscn")
@onready var ballsTexture = preload("res://world_scenes/world_textures/hole.png")

var COLORARRAY = PackedColorArray([ Color.BLACK,Color.BLACK,Color.WHITE,Color.WHITE  ])


var COLORWIN = PackedColorArray([ Color(1.0,1.0,1.0,0.0),Color(1.0,1.0,1.0,0.0),Color.WHITE,Color.WHITE  ])

var amWin = false

func _ready():
	
	if amWin:
		color = Color.WHITE
	else:
		color = Color.BLACK
	
	$Area2D/CollisionPolygon2D.polygon = polygon
	
	generateHole()
	

func generateHole():
	for i in range(polygon.size()):
		var newWall = wallScene.instantiate()
		
		newWall.displayBottomOutline = false
		newWall.groundOffset = -0.2
		newWall.heightMultiplier = 0.0
		if amWin:
			newWall.colorarray = COLORWIN
		else:
			newWall.colorarray = COLORARRAY
		
		newWall.shouldHaveCollision = false
		newWall.wallTexture = ballsTexture
		
		newWall.position = polygon[i]
		if i == polygon.size()-1:
			newWall.secondPoint = polygon[0] - polygon[i]
		else:
			newWall.secondPoint = polygon[i+1] - polygon[i]
		add_child(newWall)
		newWall.uglyass()
