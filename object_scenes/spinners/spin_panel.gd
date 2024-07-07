extends Node2D

@export var radius :int= 32
@export var startingAngle :float= 0.0
@export var speed = 1

@onready var wall1 = $Wall
#@onready var wall2 = $Wall

var angle :float= 0.0

func _ready():
	angle = startingAngle
	updateWall()

func _process(delta):
	angle += speed * delta
	$Area2D.rotation = angle
	$Area2D2.rotation = angle
	#$StaticBody2D.rotation = angle
	updateWall()

func updateWall():
	wall1.position = Vector2(-radius,0).rotated(angle)
	wall1.secondPoint = Vector2(radius * 2,0).rotated(angle)
	#wall1.setCollision()


func _on_area_2d_body_entered(body):
	var addVel = (radius * speed) * (to_local(body.global_position).length()/float(radius))
	
	var poo = Vector2(0,-addVel).rotated(angle)
	
	body.velocity = body.velocity.bounce( Vector2(0,-1).rotated(angle) ) + poo


func _on_area_2d_2_body_entered(body):
	var addVel = (radius * speed) * (to_local(body.global_position).length()/float(radius))
	var poo = Vector2(0,addVel).rotated(angle)
	
	body.velocity = body.velocity.bounce( Vector2(0,1).rotated(angle) ) + poo
