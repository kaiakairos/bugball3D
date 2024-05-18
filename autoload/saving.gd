extends Node

var key = "kaiakairos_bugball"

var defaultData = {
	#Options
	"rollToggle":false,
	"musicVol":1.0,
	"sfxVol":1.0,
	"showDecor":true,
	"showClouds":true,
	"lang":"en",
}

var data = {}

var music = AudioServer.get_bus_index("Music")
var sound = AudioServer.get_bus_index("Sound")

func _ready():
	var newData = read_save()
	if newData == null:
		data = defaultData.duplicate(true)
	else:
		data = newData.duplicate(true)
	
	var lang = getValue("lang")
	if lang == null:
		setValue("lang","en") # sets language to english
	else:
		TranslationServer.set_locale(lang)
	
	AudioServer.set_bus_volume_db(sound, linear_to_db( data["sfxVol"] ) )
	AudioServer.set_bus_volume_db(music, linear_to_db( data["musicVol"] ) )

func read_save():
	if OS.has_feature('web'):
		var JSONstr = JavaScriptBridge.eval("window.localStorage.getItem('" + key + "');")
		if (JSONstr):
			return JSON.parse_string(JSONstr)
		else:
			return null
	else:
		var file = FileAccess.open("user://" + key + ".save", FileAccess.READ)
		if not file:
			return null
		var newData = JSON.parse_string(file.get_as_text())
		file.close()
		return newData

func write_save():
	if OS.has_feature('web'):
		JavaScriptBridge.eval("window.localStorage.setItem('" + key + "', '" + JSON.stringify(data) + "');")
	else:
		var file = FileAccess.open("user://" + key + ".save", FileAccess.WRITE)
		file.store_line(JSON.stringify(data))
		file.close()

func clearSave(inMenu):
	
	if OS.has_feature('web'):
		var JSONstr = JavaScriptBridge.eval("window.localStorage.getItem('" + key + "');")
		if (JSONstr):
			JavaScriptBridge.eval("window.localStorage.removeItem('" + key + "');")
		else:
			return null
	else:
		var file = FileAccess.open("user://" + key + ".save", FileAccess.READ)
		if not file:
			return null
		file.close()
		var dir = DirAccess.open("user://")
		dir.remove(key + ".save")
		data = defaultData.duplicate(true)
	
func open_site(url):
	if OS.has_feature('web'):
		JavaScriptBridge.eval("window.open(\"" + url + "\");")
	else:
		print("Could not open site " + url + " without an HTML5 build")

func switchToSite(url):
	if OS.has_feature('web'):
		JavaScriptBridge.eval("window.open(\"" + url + "\", \"_parent\");")
	else:
		print("Could not switch to site " + url + " without an HTML5 build")

func getValue(s):
	if data.has(s):
		return data[s]
	else:
		printerr("Attepted to read line '" + str(s) + "' from save data, but line doesn't exist!")
		return null

func setValue(s,value):
	if data.has(s):
		data[s] = value
	else:
		printerr("Attepted to write line '" + str(s) + "' to save data, but line doesn't exist!\nI wrote it anyways though!")
		data[s] = value
