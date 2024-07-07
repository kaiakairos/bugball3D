extends Polygon2D

@onready var wallScene = preload("res://world_scenes/wall/wall.tscn")
@onready var ballsTexture = preload("res://world_scenes/world_textures/hole.png")

@export var renderWalls :bool = true
@export var renderOutline :bool = false

@export var camOffset :float=0.0

@export var sepLayer :bool= true
@export var swapWalls :bool = false

@export var island :bool = false

func _ready():
	if renderWalls:
		if swapWalls:
			generateBackwardsHole()
		else:
			generateHole()
	if renderOutline or island:
		$Line2D.points = polygon
	set_process(camOffset != 0.0)
	z_index = int(camOffset*100.0) - 4
	scale = Vector2( 1.0 + camOffset, 1.0 + camOffset )
	
	if island:
		z_index += 1
		$Area2D/CollisionPolygon2D.polygon =polygon
	
	if sepLayer:
		
		if renderWalls:
			if MapTextures.floorTextures.size() == 3:
				$layer2.texture = MapTextures.floorTextures[1]
				$layer1.texture = MapTextures.floorTextures[2]
				texture = MapTextures.floorTextures[0]
		else:
			# if is ceiling
			if MapTextures.ceilingTextures.size() == 3:
				$layer2.texture = MapTextures.ceilingTextures[1]
				$layer1.texture = MapTextures.ceilingTextures[2]
				texture = MapTextures.ceilingTextures[0]
			color = MapTextures.ceilDye
		
		$layer1.polygon = polygon
		$layer2.polygon = polygon
		$layer1.color = color
		$layer2.color = color
		
		set_process(true)
	
func generateHole():
	var lastAngle = null
	for i in range(polygon.size()):
		var newWall = wallScene.instantiate()
		
		newWall.displayBottomOutline = true
		newWall.heightMultiplier = 0.1
		newWall.wallTexture = MapTextures.wallTexture
		
		newWall.position = polygon[i]
		if i == polygon.size()-1:
			newWall.secondPoint = polygon[0] - polygon[i]
		else:
			newWall.secondPoint = polygon[i+1] - polygon[i]
		
		if lastAngle == null:
			lastAngle = polygon[0] - polygon[polygon.size()-1]
		
		if newWall.secondPoint.normalized().rotated((PI/2)).dot(lastAngle) > 0.0:
			newWall.displayLeftOutline = true
		
		lastAngle = newWall.secondPoint.normalized()
		
		newWall.z_index = 4
		add_child(newWall)

func generateBackwardsHole():
	var lastAngle = null
	for i in range(polygon.size()):
		var newWall = wallScene.instantiate()
		
		newWall.displayBottomOutline = true
		newWall.heightMultiplier = 0.1
		newWall.wallTexture = MapTextures.wallTexture
		
		if island:
			newWall.groundOffset = -0.05
			newWall.heightMultiplier = 0.0
			#newWall.colorarray = PackedColorArray([ Color.BLACK,Color.BLACK,Color.WHITE,Color.WHITE  ])
		
		
		newWall.position = polygon[i]
		if i == polygon.size()-1:
			newWall.secondPoint = polygon[0] - polygon[i]
		else:
			newWall.secondPoint = polygon[i+1] - polygon[i]
		
		newWall.position += newWall.secondPoint
		newWall.secondPoint *= -1
		
		if lastAngle == null:
			lastAngle = polygon[0] - polygon[polygon.size()-1]
		
		if newWall.secondPoint.normalized().rotated((PI/2)).dot(lastAngle) > 0.0:
			newWall.displayRightOutline = true
		
		if island:
			newWall.displayRightOutline = false
			newWall.displayLeftOutline = false
			newWall.displayBottomOutline = false
			newWall.displayTopOutline = false
			newWall.shouldHaveCollision = false
			newWall.wallTexture = ballsTexture
			$Line2D.z_index = 1
		
		lastAngle = newWall.secondPoint.normalized()
		
		newWall.z_index = 4
		if island:
			newWall.z_index = 0
		
		add_child(newWall)

func _process(delta):
	var cam = to_local(Global.getGlobalCameraPosition())
	offset = cam * camOffset * -1
	texture_offset = cam * camOffset
	$Line2D.position = cam * camOffset * -1
	
	if sepLayer:
		$layer1.texture_offset = cam * (0.02 - camOffset) * -1
		$layer2.texture_offset = cam * (0.04 - camOffset) * -1
		$layer1.offset = cam * camOffset * -1
		$layer2.offset = cam * camOffset * -1
