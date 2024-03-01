extends Node



# The Sector Map, is refreshed and loaded every time that Sector is started.
var s_map : Dictionary
const SECTOR_MAX_SIZE = 128
const SECTOR_ROOM_TRY = 256
enum SECTOR_TILE_TYPE {FLOOR, WALL, BLANK, DOOR}

#Base RPG Elements that the story side of the game uses

# Multplayer data. 
# "type" : String
# "name" : String
# "id"	 : String

var MULTI_ADDRESS = "localhost"
var MULTI_PORT    = 65256 

var multidata : Dictionary
var multipeer : ENetMultiplayerPeer

# The list of multidatas of connected peers.
var multilist : Dictionary


# Create a program to load and write saved data from our save file
