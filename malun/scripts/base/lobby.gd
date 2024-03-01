extends Control

var multilist_old

func _process(delta):
	# Check to see if the multilist has changed. If it has, rebuild it.
	if multilist_old != Data.multilist:
		pass
	# Rebuild the list every frame because that's how we do it here.
	# Later, we'll do this based off a signal update
	rebuild_playerlist()
	
func rebuild_playerlist():
	var pl = get_node("TabContainer/Squad/PlayerList")
	var ls = LabelSettings.new()
	ls.font_size = 32
	# Clear the list
	for n in pl.get_children():
		pl.remove_child(n)
		n.queue_free()
	for i in Data.multilist:
		var l = Label.new()
		l.label_settings = ls
		l.text = Data.multilist[i]["name"]
		pl.add_child(l)
	multilist_old = Data.multilist
	#print(multiplayer.get_unique_id(), " rebuilt it's multiplayer list.")

