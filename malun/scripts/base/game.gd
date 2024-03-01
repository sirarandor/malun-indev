extends Node

# This is the controller for the main game's actions, and syncing multiplayer.

signal peer_connected(peer_id, peer_info)
signal peer_disconnected(peer_id)
signal server_disconnected

func _ready():
	# Initalize multiplayer
	Data.multipeer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(p_connected)
	if Data.multidata['type'] == "server":
		bootstrap_server()
	else:
		bootstrap_client()
	# Add ourselves to the multilist. 
	Data.multilist[multiplayer.get_unique_id()] = Data.multidata

func bootstrap_client(): 
	$LoadSplash.visible = true
	
	Data.multipeer.create_client(Data.MULTI_ADDRESS, Data.MULTI_PORT)
	multiplayer.multiplayer_peer = Data.multipeer
	Data.multidata['id'] = multiplayer.get_unique_id()
	pass 

func bootstrap_server():
	$LoadSplash.visible = true
	
	Data.multipeer.create_server(Data.MULTI_PORT, 4)
	multiplayer.multiplayer_peer = Data.multipeer
	Data.multidata['id'] = multiplayer.get_unique_id()
	# Change ourselves to the lobby now that we are finished.
	c_changescn(0)
	pass



# Peer functions


# Send the peer our data when they connect 
func p_connected(id):
	print("Connected...")
	p_register.rpc_id(id, Data.multidata)
	
	if multiplayer.is_server():
		c_changescn.rpc_id(id, 0)
	
# Recieve the data from the peer when they connect
@rpc("any_peer", "reliable")
func p_register(peer_info): 
	Data.multilist[multiplayer.get_remote_sender_id()] = peer_info
	print(multiplayer.get_unique_id())
	print(Data.multilist)

# Client to Server functions

# Server to Client functions

# Change the preloader scene
@rpc("authority", "reliable")
func c_changescn(scn):
	$LoadSplash.visible = true
	# Clear all the scenes we might have loaded
	for n in $Preloader.get_children():
		$Preloader.remove_child(n)
		n.queue_free()
	# Add the scene that has been asked
	match scn: 
		0:
			var n = ResourceLoader.load("res://scenes/base/lobby.tscn")
			$Preloader.add_child(n.instantiate())
		1:
			var n = ResourceLoader.load("res://scenes/base/sector.tscn")
			$Preloader.add_child(n.instantiate())
	$LoadSplash.visible = false
	
# Recieve the sector data.
@rpc("authority", "reliable")
func c_sector_recieve():
	pass
	
