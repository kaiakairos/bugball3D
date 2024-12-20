extends Node

signal skinChanged

var currentBallTexture :Texture = null
var currentWormTexture :Texture = null

func _ready():
	UNLOCKSKIN(0)

var skins :Array[Dictionary]= [
	{
		"name":"SKIN_DEFAULT",
		"ballTex":"res://object_scenes/entity/player/ballTexture.png",
		"wormTex":"res://object_scenes/entity/player/gradient.png",
		"mustHaveSaveKey":"default", # will always have it
		"unlockInfo":"SKIN_DEFAULT_UNLOCK",
		"ngMedal":78897,
		"steamach":null,
	},
	{
		"name":"SKIN_YELLOW",
		"ballTex":"res://object_scenes/entity/player/skins/yellow.png",
		"wormTex":"res://object_scenes/entity/player/skins/yellowWorm.png",
		"mustHaveSaveKey":"yellowSkin", 
		"unlockInfo":"SKIN_YELLOW_UNLOCK",
		"ngMedal":78898,
		"steamach":"SKIN_YELLOW",
	},
	{
		"name":"SKIN_RED",
		"ballTex":"res://object_scenes/entity/player/skins/red.png",
		"wormTex":"res://object_scenes/entity/player/skins/redWorm.png",
		"mustHaveSaveKey":"redSkin",
		"unlockInfo":"SKIN_RED_UNLOCK",
		"ngMedal":78899,
		"steamach":"SKIN_RED",
	},
	{
		"name":"SKIN_BEACH",
		"ballTex":"res://object_scenes/entity/player/skins/beach.png",
		"wormTex":"res://object_scenes/entity/player/skins/beachWorm.png",
		"mustHaveSaveKey":"beachSkin",
		"unlockInfo":"SKIN_BEACH_UNLOCK",
		"ngMedal":78900,
		"steamach":"SKIN_BEACH",
	},
	{
		"name":"SKIN_DODGEBALL",
		"ballTex":"res://object_scenes/entity/player/skins/dodgeball.png",
		"wormTex":"res://object_scenes/entity/player/skins/dodge.png",
		"mustHaveSaveKey":"dodgeSkin",
		"unlockInfo":"SKIN_DODGEBALL_UNLOCK",
		"ngMedal":78901,
		"steamach":"SKIN_DODGE",
	},
	{
		"name":"SKIN_POOL",
		"ballTex":"res://object_scenes/entity/player/skins/8Ball.png",
		"wormTex":"res://object_scenes/entity/player/skins/8worm.png",
		"mustHaveSaveKey":"poolSkin",
		"unlockInfo":"SKIN_POOL_UNLOCK",
		"ngMedal":78902,
		"steamach":"SKIN_POOL",
	},
	{
		"name":"SKIN_GLASS",
		"ballTex":"res://object_scenes/entity/player/skins/chromeBall.png",
		"wormTex":"res://object_scenes/entity/player/skins/chromeWorm.png",
		"mustHaveSaveKey":"glassSkin",
		"unlockInfo":"SKIN_GLASS_UNLOCK",
		"ngMedal":78903,
		"steamach":"SKIN_GLASS",
	},
	{
		"name":"SKIN_TENNIS",
		"ballTex":"res://object_scenes/entity/player/skins/tennis.png",
		"wormTex":"res://object_scenes/entity/player/skins/tenWorm.png",
		"mustHaveSaveKey":"tennisSkin",
		"unlockInfo":"SKIN_TENNIS_UNLOCK",
		"ngMedal":78904,
		"steamach":"SKIN_TENNIS",
	},
	{
		"name":"SKIN_LEBRON",
		"ballTex":"res://object_scenes/entity/player/skins/basketball.png",
		"wormTex":"res://object_scenes/entity/player/skins/bron.png",
		"mustHaveSaveKey":"basketSkin",
		"unlockInfo":"SKIN_LEBRON_UNLOCK",
		"ngMedal":78905,
		"steamach":"SKIN_BRON",
	},
	
	{
		"name":"SKIN_SKY", # 9
		"ballTex":"res://object_scenes/entity/player/skins/skyball.png",
		"wormTex":"res://object_scenes/entity/player/skins/sky.png",
		"mustHaveSaveKey":"skinSky",
		"unlockInfo":"SKIN_SKY_UNLOCK",
		"ngMedal":78905,
		"steamach":"SKIN_SKY",
	},
	
	{ 
		"name":"SKIN_UN", # 10
		"ballTex":"res://object_scenes/entity/player/skins/unball.png",
		"wormTex":"res://object_scenes/entity/player/skins/un.png",
		"mustHaveSaveKey":"skinUN",
		"unlockInfo":"SKIN_UN_UNLOCK",
		"ngMedal":78905,
		"steamach":"SKIN_UN",
	},
	
	{
		"name":"SKIN_RAINBOW", # 11
		"ballTex":"res://object_scenes/entity/player/skins/rainbowball.png",
		"wormTex":"res://object_scenes/entity/player/skins/rainbow.png",
		"mustHaveSaveKey":"skinRainbow",
		"unlockInfo":"SKIN_RAINBOW_UNLOCK",
		"ngMedal":78905,
		"steamach":"SKIN_RAINBOW",
	},
	
	{
		"name":"SKIN_SPACE", # 12
		"ballTex":"res://object_scenes/entity/player/skins/spaceBall.png",
		"wormTex":"res://object_scenes/entity/player/skins/space.png",
		"mustHaveSaveKey":"skinSpace",
		"unlockInfo":"SKIN_SPACE_UNLOCK",
		"ngMedal":78905,
		"steamach":"SKIN_SPACE",
	},
	
	{
		"name":"SKIN_FLAME", # 13
		"ballTex":"res://object_scenes/entity/player/skins/flameBall.png",
		"wormTex":"res://object_scenes/entity/player/skins/flame.png",
		"mustHaveSaveKey":"skinFlame",
		"unlockInfo":"SKIN_FLAME_UNLOCK",
		"ngMedal":78905,
		"steamach":"SKIN_FLAME",
	},
	
	{
		"name":"SKIN_GUM", # 14
		"ballTex":"res://object_scenes/entity/player/skins/gumBall.png",
		"wormTex":"res://object_scenes/entity/player/skins/gum.png",
		"mustHaveSaveKey":"skinGum",
		"unlockInfo":"SKIN_GUM_UNLOCK",
		"ngMedal":78905,
		"steamach":"SKIN_GUM",
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
	return tr(skins[id]["name"])

func getInfo(id):
	return tr(skins[id]["unlockInfo"])

func UNLOCKSKIN(id):
	
	#Ngio.request("Medal.unlock", {"id": skins[id]["ngMedal"] })
	medalUnlockId = skins[id]["ngMedal"]
	
	var steamID = skins[id]["steamach"]
	if steamID != null:
		Steam.setAchievement(steamID)
		Steam.storeStats()
	
	if Saving.setValue(skins[id]["mustHaveSaveKey"],true):
		return
	Saving.write_save()
	
	
	#insert cool sound here
	
	#create label
	var label = Label.new()
	label.label_settings = load("res://ui_scenes/skinSelect/skinUnlockedlabel.tres")
	label.position = Vector2(10,-200)
	label.text =  tr("NEW_SKIN") + ": " + tr(skins[id]["name"])
	label.z_index = 4096
	add_child(label)
	
	var tween = get_tree().create_tween()
	tween.tween_property(label,"position:y",6.0,0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(2.0).timeout
	var tween2 = get_tree().create_tween()
	tween2.tween_property(label,"modulate:a",0.0,0.5)
	await get_tree().create_timer(0.8).timeout
	label.queue_free()
