# This is the main controller Node, so we can easily handle exiting and switching from the title menu to settings. 
# This will also have the controller to show the Escape menu settings.
extends Node

var title_screen_scn
var game_scn
var escape_screen_scn

func _ready():
	title_screen_scn = ResourceLoader.load("res://scenes/gui/title_screen.tscn")
	game_scn = ResourceLoader.load("res://scenes/base/game.tscn")
	
	_load_title()
	
func _process(delta):
	pass
	
func _load_title():
	clear_children()
	
	var n = title_screen_scn.instantiate()
	n.get_node("ServerWindow/StartServer").connect("pressed", _load_game_server)
	n.get_node("ClientWindow/StartClient").connect("pressed", _load_game_client)
	add_child(n)
	
func _load_game_server():
	clear_children()
	Data.multidata["type"] = "server"
	var n = game_scn.instantiate()
	add_child(n)
	
func _load_game_client():
	clear_children()
	Data.multidata["type"] = "client"
	var n = game_scn.instantiate()
	add_child(n)
	
	
func clear_children():
	for n in self.get_children():
		self.remove_child(n)
		n.queue_free()
