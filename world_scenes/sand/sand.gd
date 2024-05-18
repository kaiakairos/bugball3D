@tool
extends Polygon2D

@export var angle :float= 0.0:
	get:
		return angle
	set(value):
		angle = value
		texture_rotation = value


func _ready():
	
	if !Engine.is_editor_hint():
		$Line2D.points = polygon
		$Area2D/CollisionPolygon2D.polygon = polygon
		texture_rotation = angle
