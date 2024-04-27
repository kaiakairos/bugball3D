extends Node

@onready var sound2d = preload("res://autoload/soundstuff/sfx.tscn")

func playSound2D(globpos:Vector2,file:String,volume:float,pitch:float=1.0):
	var newSound = sound2d.instantiate()
	newSound.global_position = globpos
	newSound.stream = load(file)
	newSound.volume_db = volume
	newSound.pitch_scale = pitch
	add_child(newSound)
