extends Node2D

var dif :float= 0.05
var tween :Tween = null

func _process(delta):
	
	var camPos = to_local(Global.getGlobalCameraPosition())
	
	var i :int= 0
	for child in $CanvasGroup.get_children():
		child.position = camPos * i * -dif
		if i == 3:
			child.position = camPos * 2.5 * -dif
		
		i += 1

func _on_area_2d_body_entered(body):
	
	if !body.rolling:
		body.rolling = true
		body.jumpVelocity = 2.0
		
	body.velocity = body.velocity.normalized() * 800
	dif = 0.0
	
	Sound.playSound2D(global_position,"res://audio/bumperDing.ogg",-10.0,randf_range(0.98,1.02))
	
	if is_instance_valid(tween):
		tween.stop()
	
	tween = get_tree().create_tween()
	tween.tween_property(self,"dif",0.05,1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _on_visible_on_screen_notifier_2d_screen_entered():
	set_process(true)


func _on_visible_on_screen_notifier_2d_screen_exited():
	set_process(false)
