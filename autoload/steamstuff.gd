extends Node

var is_on_steam_deck: bool = false
var is_online: bool = false
var is_owned: bool = false
var steam_id: int = 2976450 # put that id right here dawg
var steam_username: String = "poop pee"

func _ready():
	
	return # remove later to add steam api
	
	OS.set_environment("SteamAppId", str(steam_id))
	OS.set_environment("SteamGameId", str(steam_id))
	initialize_steam()
	
	is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()
	is_online = Steam.loggedOn()
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()

	if is_owned == false:
		print("Erm... you don't own this game on steam :/")
		get_tree().quit()
	
	
func initialize_steam():
	var response: Dictionary = Steam.steamInitEx()
	print( "steam initialized?: %s" % response )
	
	if response["status"] > 0:
		print("Failed to init steam.")
		get_tree().quit()
