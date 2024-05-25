extends Node2D

var selectingRetry = true


var songBeat :float= 0.0
var tick :int= 0

func _ready():
	set_process(false)
	
	$select/retry.modulate = Color(0.6,0.588,0.655)
	
	$courseComplete.text = "[center][wave amp=50.0 freq=-5.0 connected=1][font_size=40]" + tr("COURSE_COMPLETE")
	$newrecord.text = "[right][wave amp=80.0 freq=-10.0 connected=1][font_size=32][rainbow freq=0.4 sat=1.0 val=1.0]" + tr("NEW_RECORD")
	
func postScores( deaths, time ):
	
	var disqualify = Global.isPlayerDisqualified()
	
	if !disqualify:
		match Global.levelSaveCode:
			"course1_EasyPB":
				Ngio.request("ScoreBoard.postScore", {"id": 13739, "value": time*1000})
				SkinHandler.UNLOCKSKIN(1)
			"course1_MeedPB":
				Ngio.request("ScoreBoard.postScore", {"id": 13740, "value": time*1000})
				SkinHandler.UNLOCKSKIN(2)
			"course1_HardPB":
				Ngio.request("ScoreBoard.postScore", {"id": 13741, "value": time*1000})
				SkinHandler.UNLOCKSKIN(3)
	
	if Global.mirrored:
		SkinHandler.UNLOCKSKIN(6)
	if Global.tenRollSpeed:
		SkinHandler.UNLOCKSKIN(7)
	
	var value = time - (int(time/60.0)*60)
	var string = str( value )
	if value < 10.0:
		string = "0" + string
		
	string = string.left(5)

	$score.text = tr("COURSE_TIME") + ": " + str( int(time/60.0) ) + ":" + string
	
	var record = false
	if !disqualify:
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
	
	if !disqualify:
		if $Grades.frame == 0:
			SkinHandler.UNLOCKSKIN(4)
			# check for all S rank
			var e = Saving.getValue("course1_EasyPB")
			var m = Saving.getValue("course1_MeedPB")
			var h = Saving.getValue("course1_HardPB")
			# this is gonna have to be hard coded for now
			if e == null or m == null or h == null:
				pass
			else: ## BE SURE TO SET THESE CORRECTLY!!
				if e <= 750.0 and m <= 1100.0 and h <= 1000.0:
					SkinHandler.UNLOCKSKIN(5)
	
	$Background.visible = true
	$courseComplete.visible = true
	await get_tree().create_timer(2.0).timeout
	
	var tween = get_tree().create_tween()
	tween.set_parallel()
	tween.tween_property($courseComplete,"size:x",320,0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property($courseComplete,"position:y",12,0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Wipe,"position:y",-500,0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(0.75).timeout
	
	
	## SHOW TIME
	$score.visible = true 
	await get_tree().create_timer(0.5).timeout
	
	## SHOW DEATHS
	$score.text = tr("COURSE_TIME") + ": " + str( int(time/60.0) ) + ":" + string +"\n" +tr("COURSE_DEATHS")+ ": " + str(deaths)
	await get_tree().create_timer(0.5).timeout
	
	
	if !disqualify:
		## SHOW GRADE
		$Grades.visible = true
	
		#insert grade sound
		#hold for impact
		
		await get_tree().create_timer(1.0).timeout
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
		
	
	$select.visible = true
	set_process(true)
	get_parent().courseCompleteMusic.playing = true
	beat()
	
func _process(delta):
	
	tick += 1
	songBeat += delta
	if songBeat >= 0.727272:
		# on beat
		songBeat -= 0.727272
		beat()
	
	$select/retry.position.y = lerp($select/retry.position.y,0.0,0.2  )
	$select/menu.position.y = lerp($select/menu.position.y,23.0,0.2  )
	$Grades.scale = lerp($Grades.scale,Vector2(1.0,1.0),0.2)
	$Grades.position.y = sin(tick*0.01) + 127
	$Grades.position.x = (sin(tick*0.005) * 2.0) + 372
	
	if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("move_down_joy"):
		flip(1)
	elif Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("move_up_joy"):
		flip(-1)
	
	if Input.is_action_just_pressed("menuSelect"):
		if selectingRetry:
			get_tree().reload_current_scene()
		else:
			get_tree().change_scene_to_file("res://main_scenes/mainMenu/main_menu.tscn")
	
	
func flip(nudge):
	selectingRetry = !selectingRetry
	if selectingRetry:
		$select/retry.modulate = Color(0.6,0.588,0.655)
		$select/menu.modulate = Color.WHITE
		$select/retry.position.y += 2 * nudge
	else:
		$select/retry.modulate = Color.WHITE
		$select/menu.modulate = Color(0.6,0.588,0.655)
		$select/menu.position.y += 2 * nudge

func beat():
	$Grades.scale = Vector2(0.95,0.95)
	$select/menu.position.y += 3
	$select/retry.position.y += 2
