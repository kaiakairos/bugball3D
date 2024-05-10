extends Node2D

func _ready():
	set_process(false)

func postScores( deaths, time ):
	
	var value = time - (int(time/60.0)*60)
	var string = str( value )
	if value < 10.0:
		string = "0" + string
		
	string = string.left(5)

	$score.text = "time: " + str( int(time/60.0) ) + ":" + string
	
	var record = false
	# Calculate high score
	var prev = Saving.getValue(Global.levelSaveCode)
	if prev == null:
		record = true
		Saving.setValue(Global.levelSaveCode,time)
	elif time < prev:
		record = true
		Saving.setValue(Global.levelSaveCode,time)
	
	Saving.write_save()
	
	# calculate RANK
	$Grades.frame = 5
	if Global.levelRANKHolder.size() < 5:
		printerr("EPIC FAIL: you need five values in the level rank holder! ")
	else:
		for score in range(5):
			if time <= Global.levelRANKHolder[score]:
				$Grades.frame = score
				break
	
	$Background.visible = true
	$courseComplete.visible = true
	await get_tree().create_timer(2.0).timeout
	
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($courseComplete,"size:x",320,0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property($courseComplete,"position:y",12,0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Wipe,"position:y",-500,0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.75).timeout
	
	$score.visible = true
	await get_tree().create_timer(0.5).timeout
	$score.text = "time: " + str( int(time/60.0) ) + ":" + string +"\ndeaths: " + str(deaths)
	await get_tree().create_timer(0.5).timeout
	$Grades.visible = true
	
	await get_tree().create_timer(0.5).timeout
	
	var bestTime = Saving.getValue(Global.levelSaveCode)
	var bvalue = bestTime - (int(bestTime/60.0)*60)
	var bstring = str( bvalue )
	if bvalue < 10.0:
		bstring = "0" + bstring
		
	bstring = bstring.left(5)
	
	$pb.text = "PB: " + str( int(bestTime/60.0) ) + ":" + bstring
	$pb.visible = true
	if record:
		$newrecord.visible = true
	
	await get_tree().create_timer(0.5).timeout
	$select.visible = true
	set_process(true)
	


