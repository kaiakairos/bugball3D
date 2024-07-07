extends Node2D
class_name DropTarget

@export var thick :int= 12
@export var length :int = 64
@export var angle :float = 0.0

@onready var wallScene = preload("res://world_scenes/wall/wall.tscn")

var height = 0.1

func _ready():
	
	var ins = wallScene.instantiate()
	ins.secondPoint = Vector2(length,0).rotated(angle)
	
	ins.displayLeftOutline = true
	ins.displayRightOutline = true
	ins.shouldHaveCollision = false
	
	$walls.add_child(ins)
	
	var inss = wallScene.instantiate()
	inss.secondPoint = Vector2(length,0).rotated(angle+PI)
	inss.position = Vector2(length, -thick).rotated(angle)
	
	inss.displayLeftOutline = true
	inss.displayRightOutline = true
	inss.shouldHaveCollision = false
	
	$walls.add_child(inss)
	
	var poly = PackedVector2Array()
	poly.append(Vector2.ZERO)
	poly.append(Vector2(0, -thick))
	poly.append(Vector2(length, -thick))
	poly.append(Vector2(length, 0))
	$Polygon2D.polygon = poly
	$Polygon2D.rotation = angle
	$StaticBody2D/CollisionPolygon2D.polygon = poly
	$StaticBody2D.rotation = angle
	$Area2D.rotation = angle
	
	var areaOff = 6
	var apoly = PackedVector2Array()
	apoly.append(Vector2(0,areaOff))
	apoly.append(Vector2(0, -thick-areaOff))
	apoly.append(Vector2(length, -thick-areaOff))
	apoly.append(Vector2(length, areaOff))
	
	$Area2D/CollisionPolygon2D.polygon = apoly

func _process(delta):
	var cam = to_local(Global.getGlobalCameraPosition())
	$Polygon2D.position = cam * height * -1
	
	for w in $walls.get_children():
		w.heightMultiplier = height
	
	$Polygon2D.scale.x = height + 1.0

func openDoor():
	var tween = get_tree().create_tween()
	tween.tween_property(self,"height",0.0,0.5)
	await tween.finished
	$StaticBody2D/CollisionPolygon2D.disabled = true
	
	if get_tree() == null:
		return
	var tween2 = get_tree().create_tween()
	tween2.tween_property(self,"modulate:a",0.2,0.1)
	
	z_index = -2
	
	await tween2.finished
	for w in $walls.get_children():
		w.queue_free()
	
	
	
func get_global():
	var v = Vector2( length/2, -(thick/2)  ).rotated(angle)
	return global_position + v
	


func _on_area_2d_body_entered(body):
	openDoor()
