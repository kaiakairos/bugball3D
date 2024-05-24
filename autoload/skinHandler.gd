extends Node

signal skinChanged

var currentBallTexture :Texture = null
var currentWormTexture :Texture = null

func _ready():
	UNLOCKSKIN(0)

var skins :Array[Dictionary]= [
	{
		"name":"default",
		"ballTex":"res://object_scenes/entity/player/ballTexture.png",
		"wormTex":"res://object_scenes/entity/player/gradient.png",
		"mustHaveSaveKey":"default", # will always have it
		"unlockInfo":"open the game!",
		"ngMedal":78897,
	},
	{
		"name":"yellow",
		"ballTex":"res://object_scenes/entity/player/skins/yellow.png",
		"wormTex":"res://object_scenes/entity/player/skins/yellowWorm.png",
		"mustHaveSaveKey":"yellowSkin", 
		"unlockInfo":"complete the forest course on easy!",
		"ngMedal":78898,
	},
	{
		"name":"red",
		"ballTex":"res://object_scenes/entity/player/skins/red.png",
		"wormTex":"res://object_scenes/entity/player/skins/redWorm.png",
		"mustHaveSaveKey":"redSkin",
		"unlockInfo":"complete the forest course on medium!",
		"ngMedal":78899,
	},
	{
		"name":"beach",
		"ballTex":"res://object_scenes/entity/player/skins/beach.png",
		"wormTex":"res://object_scenes/entity/player/skins/beachWorm.png",
		"mustHaveSaveKey":"beachSkin",
		"unlockInfo":"complete the forest course on hard!",
		"ngMedal":78900,
	},
	{
		"name":"dodgeball",
		"ballTex":"res://object_scenes/entity/player/skins/dodgeball.png",
		"wormTex":"res://object_scenes/entity/player/skins/dodge.png",
		"mustHaveSaveKey":"dodgeSkin",
		"unlockInfo":"get an S rank on any course",
		"ngMedal":78901,
	},
	{
		"name":"8 ball",
		"ballTex":"res://object_scenes/entity/player/skins/8Ball.png",
		"wormTex":"res://object_scenes/entity/player/skins/8worm.png",
		"mustHaveSaveKey":"poolSkin",
		"unlockInfo":"achieve an S rank on all forest courses",
		"ngMedal":78902,
	},
	{
		"name":"glass",
		"ballTex":"res://object_scenes/entity/player/skins/chromeBall.png",
		"wormTex":"res://object_scenes/entity/player/skins/chromeWorm.png",
		"mustHaveSaveKey":"glassSkin",
		"unlockInfo":"complete any course with the 'mirror world' modifier enabled",
		"ngMedal":78903,
	},
	{
		"name":"tennis ball",
		"ballTex":"res://object_scenes/entity/player/skins/tennis.png",
		"wormTex":"res://object_scenes/entity/player/skins/tenWorm.png",
		"mustHaveSaveKey":"tennisSkin",
		"unlockInfo":"complete any course with the 'overdrive' modifier enabled",
		"ngMedal":78904,
	},
	{
		"name":"da bron",
		"ballTex":"res://object_scenes/entity/player/skins/basketball.png",
		"wormTex":"res://object_scenes/entity/player/skins/bron.png",
		"mustHaveSaveKey":"basketSkin",
		"unlockInfo":"read the credits",
		"ngMedal":78905,
	},
	
]

var medalUnlockId = 78897

func setSkin(id):
	if Saving.hasKey(skins[id]["mustHaveSaveKey"]):
		currentBallTexture = load(skins[id]["ballTex"])
		currentWormTexture = load(skins[id]["wormTex"])
		emit_signal("skinChanged")
		return true
	return false

func getName(id):
	return skins[id]["name"]

func getInfo(id):
	return skins[id]["unlockInfo"]

func UNLOCKSKIN(id):
	
	#put info about da medal and stuff yadda
	Ngio.request("Medal.unlock", {"id": skins[id]["ngMedal"] })
	medalUnlockId = skins[id]["ngMedal"]
	if Saving.setValue(skins[id]["mustHaveSaveKey"],true):
		return
	Saving.write_save()
	
	#insert cool sound here
	
	#create label
	var label = Label.new()
	label.label_settings = load("res://ui_scenes/skinSelect/skinUnlockedlabel.tres")
	label.position = Vector2(10,-200)
	label.text = "new skin unlocked!: " + skins[id]["name"]
	label.z_index = 4096
	add_child(label)
	
	var tween = get_tree().create_tween()
	tween.tween_property(label,"position:y",6.0,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(2.0).timeout
	var tween2 = get_tree().create_tween()
	tween2.tween_property(label,"modulate:a",0.0,0.5)
	await get_tree().create_timer(0.8).timeout
	label.queue_free()
