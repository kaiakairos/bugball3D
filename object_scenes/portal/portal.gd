@tool
extends Node2D

@export var secondPortal: Vector2 = Vector2(32,0) :
	get:
		return secondPortal
	set(value):
		secondPortal = value
		if Engine.is_editor_hint():
			$poop/Portal2.position = value

var justEntered = 0 # 0 = not entered, 1 = portal 1, 2 = portal 2

@onready var portal1 = $poop/Portal1
@onready var portal2 = $poop/Portal2

@onready var flareParticle1 = $poop/Portal1/CPUParticles2D2
@onready var flareParticle2 = $poop/Portal2/CPUParticles2D4

func _ready():
	if !Engine.is_editor_hint():
		portal2.position = secondPortal


func _on_portal_1_body_entered(body):
	
	if justEntered == 0:
		
		epicShake(body.global_position,portal2.global_position)
		flareParticle2.direction = body.velocity.normalized()
		flareParticle2.initial_velocity_min = body.velocity.length()
		flareParticle2.initial_velocity_max = body.velocity.length()
		
		body.global_position = portal2.global_position
		
		
		justEntered = 1


func _on_portal_2_body_entered(body):
	
	
	if justEntered == 0:
		
		epicShake(body.global_position,portal1.global_position)
		
		flareParticle1.direction = body.velocity.normalized()
		flareParticle1.initial_velocity_min = body.velocity.length()
		flareParticle1.initial_velocity_max = body.velocity.length()
		
		body.global_position = portal1.global_position
		
		justEntered = 2


func _on_portal_1_body_exited(body):
	if justEntered == 2:
		justEntered = 0


func _on_portal_2_body_exited(body):
	if justEntered == 1:
		justEntered = 0

func epicShake(ogPosition,newPosition):
	
	Global.player.teleportPlayerCameraRelative(ogPosition,newPosition)
	
	Global.shakeCamera(2.0)

func _process(delta):
	flareParticle1.initial_velocity_min = lerp(flareParticle1.initial_velocity_min,0.0,0.05)
	flareParticle1.initial_velocity_max = flareParticle1.initial_velocity_min
	
	flareParticle2.initial_velocity_min = lerp(flareParticle2.initial_velocity_min,0.0,0.05)
	flareParticle2.initial_velocity_max = flareParticle2.initial_velocity_min
