@tool
extends Node2D

@onready var testLine = $Line2D
@export var secondPoint: Vector2 = Vector2(64,0) :
	get:
		return secondPoint
	set(value):
		secondPoint = value
		if Engine.is_editor_hint():
			$Line2D.clear_points()
			$Line2D.add_point(Vector2.ZERO)
			$Line2D.add_point(value)
			$Line2D.add_point((value/2))
			$Line2D.add_point((value/2) + ( value.normalized().rotated(PI/2) * 4) )

@export var heightMultiplier :float = 0.1
@export var groundOffset :float = 0.0

@onready var poly = $poly

@onready var bottomLine = $Outlines/bottomLine
@onready var topLine = $Outlines/topLine
@onready var leftLine = $Outlines/leftLine
@onready var rightLine = $Outlines/rightLine

@export var wallTexture :Texture 

@export var displayBottomOutline :bool = true
@export var displayTopOutline :bool = true

@export var displayGrassOutline :bool = true

@export var displayLeftOutline :bool = false
@export var displayRightOutline :bool = false

@export var shouldHaveCollision :bool = true

var texSize = Vector2(1,1)

var colorarray :PackedColorArray = PackedColorArray([ Color.WHITE,Color.WHITE,Color.WHITE,Color.WHITE  ])

func _ready():
	if !Engine.is_editor_hint():
		testLine.queue_free()
		
		poly.texture = wallTexture
		
		texSize = wallTexture.get_size()
		
		poly.vertex_colors = colorarray
		
		if shouldHaveCollision:
			var newpolycoll = PackedVector2Array()
			newpolycoll.append(Vector2.ZERO)
			newpolycoll.append(secondPoint)
			newpolycoll.append((secondPoint/2) + ( secondPoint.normalized().rotated(PI/2) * -8))
			$StaticBody2D/CollisionPolygon2D.polygon = newpolycoll

func _process(delta):
	if !Engine.is_editor_hint():
		
		var normal = secondPoint.normalized().rotated(PI/2)
		
		
		var camPos = Global.getGlobalCameraPosition()
		var oneLocal = heightMultiplier * (camPos - global_position)
		var secLocal = heightMultiplier * (camPos - (global_position + secondPoint))
		
		var oneLocalB = groundOffset * (camPos - global_position)
		var secLocalB = groundOffset * (camPos - (global_position + secondPoint))
		
		var shouldShow = normal.dot(camPos - (global_position + (secondPoint/2))) > 0
		
		
		var newPoly = PackedVector2Array()
		if shouldShow:
			newPoly.append(Vector2.ZERO - oneLocalB)
			newPoly.append(secondPoint - secLocalB)
			newPoly.append(secondPoint - secLocal)
			newPoly.append(Vector2.ZERO - oneLocal)
		
		poly.polygon = newPoly
		
		var newUV = PackedVector2Array()
		newUV.append( Vector2( 0, texSize.y ) )
		newUV.append( texSize )
		newUV.append( Vector2( texSize.x, 0 ) )
		newUV.append( Vector2.ZERO )
		
		if displayBottomOutline:
			bottomLine.clear_points()
			bottomLine.add_point(Vector2.ZERO - oneLocalB)
			bottomLine.add_point(secondPoint - secLocalB)
		
		if displayTopOutline:
			topLine.clear_points()
			topLine.add_point(secondPoint - secLocal)
			topLine.add_point(Vector2.ZERO - oneLocal)
	
		
		if displayLeftOutline:
			leftLine.clear_points()
			leftLine.add_point(Vector2.ZERO - oneLocalB)
			leftLine.add_point(Vector2.ZERO - oneLocal)
			
		if displayRightOutline:
			rightLine.clear_points()
			rightLine.add_point(secondPoint - secLocalB)
			rightLine.add_point(secondPoint - secLocal)

func uglyass():
	topLine.z_index = 2
