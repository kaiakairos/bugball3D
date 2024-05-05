extends Node

var key = "kaiakairos_bugball"

var defaultData = {
	"ForestEasyPB":null,
	"ForestMedmPB":null,
	"ForestHardPB":null,
	
	
	
	#Options
	"rollToggle":false,
	"musicVol":0.0,
	"sfxVole":0.0,
}

var data = {}

func _ready():
	data = defaultData.duplicate(true)

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
	
	if inMenu:
		Sound.playSound("activate",0,Global.camera.global_position,0.0)
		
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
