extends Node

var title_screen_scn
var city_scn
var sector_scn

func _ready():
	title_screen_scn = ResourceLoader.load("res://scenes/base/title_screen.tscn")
	city_scn = ResourceLoader.load("res://scenes/base/city.tscn")
	sector_scn = ResourceLoader.load("res://scenes/base/sector.tscn")
	
	_load_title()
	
func _process(delta):
	pass
	
func _load_title():
	clear_children()
	
	var n = title_screen_scn.instantiate()
	n.get_node("Label/Begin").connect("pressed", _load_sector)
	add_child(n)
	
func _load_city(): 
	clear_children()
	
	var n = city_scn.instantiate()
	
	add_child(n)
	
	
func _load_sector():
	clear_children()
	var n = sector_scn.instantiate()
	add_child(n)
	
func clear_children():
	for n in self.get_children():
		self.remove_child(n)
		n.queue_free()
