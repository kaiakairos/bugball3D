extends Node2D

var pins :int = 1


func _ready():
	pins = get_children().size() - 1 # minus 1 to account for particles


func knockPin(pin):
	pins -= 1
	
	var sound :String=  "res://audio/bowlingPinKnock" + str((randi() % 3) + 1) + ".ogg"
	
	Sound.playSound2D(pin.global_position,sound,-6.0,randf_range(0.9,1.1))
	
	if pins <= 0:
		Sound.playSound2D(pin.global_position,"res://audio/bowlingStrike.ogg",0.0)
		
		var poob = $winner
		poob.reparent(pin.surprise)
		poob.position = Vector2.ZERO
		poob.emitting = true
		
		win()

func win():
	
	Sound.playSound2D(global_position,"res://audio/partyHorn.ogg",-10.0)
	if is_instance_valid(Global.gameController):
		Global.gameController.pauseTimer()
		
	if Global.isFinalLevel:
		Global.gameController.endMusic()
		Sound.playSound2D(global_position,"res://audio/whistle.ogg",-2.0)
	Global.player.canMove = false
	await get_tree().create_timer(1.0).timeout
	
	Global.nextLevel()
