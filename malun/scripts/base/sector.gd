extends Node3D

var rng

# Room Designation Dictionary
# Contains the starting corner location of every room and it's X and Y size
# This is used for the creation of paths and other base elements of the sector that are not contained in the room nodes themselves.
var rdd : Dictionary

# Built-In ready function that runs when the Node is placed in the scene for the first time.
# Yes, I typed this out by hand.
func _ready():
	rng = RandomNumberGenerator.new()
	
	build_sector()

# Sector building algorithm
# Does not require any input.
func build_sector():
	#Clear the global Sector map
	Data.s_map.clear()
	for i in Data.SECTOR_MAX_SIZE:
		for j in Data.SECTOR_MAX_SIZE:
			Data.s_map[Vector2(i, j)] = 3
	
	# Generate a room of a random size, and a random spot to place it at. If it doesn't fit, drop it.
	# Do this the number of specified times. 
	var ec = 0
	for i in Data.SECTOR_ROOM_TRY:
		var sx = rng.randi_range(6,18)
		var sy = rng.randi_range(6,18)
		
		var px = rng.randi_range(0,Data.SECTOR_MAX_SIZE-16)
		var py = rng.randi_range(0,Data.SECTOR_MAX_SIZE-16)
		
		#print("New room to test:\n", "SIZE: ", sx, "x", sy, "\n", "POS: ", px, "-", py)
		
		# Determine if the room is viable
		var viable = true
		for c in sx+2: 
			for v in sy+2:
				var t = Vector2(px-1 + c, py-1 + v)
				if Data.s_map.has(t):
					#print(t, ' = ', Data.s_map[t])
					if Data.s_map[t] != 3:
						#print("Non-viable Room Found.")
						viable = false
				
		# If it is not viable, drop. 
		if viable == false:
			#print("Non-viable Room Found.")
			continue
		else: 
			#print("Viable room found at: ", px, "-", py)
			ec = ec + 1
		
		# Build the room.
		build_room(px, py, sx, sy)
		# Add the room to the RDD
		rdd[i] = {
		"px" : px,
		"py" : py,
		"sx" : sx,
		"sy" : sy	
		}
	print("Finished Rooms.")	
	
	for c in 2:
		# Now loop through all the rooms, and place paths with doors.
		for i in rdd:
			# Decide where we want our path out to be
			var dr = rng.randi_range(1,4)
			match dr:
				# North wall
				1: 
					build_path(Vector2(randi_range(rdd[i]["px"]+1, rdd[i]["px"] + rdd[i]["sx"]-1), rdd[i]["py"] + rdd[i]["sy"]), 1) 
				# South wall
				2:
					build_path(Vector2(randi_range(rdd[i]["px"]+1, rdd[i]["px"] + rdd[i]["sx"]-1), rdd[i]["py"]), 2)
				# East wall
				3:
					build_path(Vector2(rdd[i]["px"] + rdd[i]["sx"], randi_range(rdd[i]["py"]+1, rdd[i]["py"] + rdd[i]["sy"]-1)), 3) 
				# West wall
				4:
					build_path(Vector2(rdd[i]["px"], randi_range(rdd[i]["py"], rdd[i]["py"]+1 + rdd[i]["sy"]-1)), 4)
	print("Finished Paths.")
	
	
	# Sector generation finalization
	# Build the world outline
	for c in Data.SECTOR_MAX_SIZE:
		Data.s_map[Vector2(c, 0)] = 1
	for c in Data.SECTOR_MAX_SIZE:
		Data.s_map[Vector2(c, Data.SECTOR_MAX_SIZE)] = 1
	for c in Data.SECTOR_MAX_SIZE:
		Data.s_map[Vector2(0, c)] = 1
	for c in Data.SECTOR_MAX_SIZE:
		Data.s_map[Vector2(Data.SECTOR_MAX_SIZE, c)] = 1
	
	# Make anything that hasn't been assigned yet a wall tile
	for c in Data.SECTOR_MAX_SIZE:
		for v in Data.SECTOR_MAX_SIZE:
			if Data.s_map[Vector2(c, v)] == 3:
				Data.s_map[Vector2(c, v)] = 1
	

	# BEGIN DEBUG
	#  Try building a path in the middle of the sector
	# build_path(Vector2(32, 32), 1)
	#  This works. Onto the next problem.
	# END DEBUG 
	

	# Place the sector down into the gridmap
	for c in Data.s_map:
		$Map/NavigationRegion3D/Grid.set_cell_item(Vector3(c.x, 0, c.y), Data.s_map[c])
	
	# Bake the navmesh. This is the slowest method out of the entire process.
	# Is there a button for multithreading?
	$Map/NavigationRegion3D.bake_navigation_mesh()


# Fill a room with props and give it doors.
# Takes [Corner Position] and [Size]
# TODO: 
#	- Give all rooms their own Area3D node within $Map/Rooms
#	- Add a check to create doors once all the paths are complete
func build_room(px, py, sx, sy):
	# Fill the room with floors. Outline with walls.
	for c in sx: 
		for v in sy:
			var p = Vector2(px + c, py + v)
			Data.s_map[p] = 0
	
	# Outlining and placing path
	# North Wall
	for c in sx: 
		var p = Vector2(px + c, py)
		Data.s_map[p] = 1
	# East Wall
	for c in sy: 
		var p = Vector2(px, py + c)
		Data.s_map[p] = 1
	# South Wall
	for c in sx: 
		var p = Vector2(px + c, py + sy)
		Data.s_map[p] = 1
	# West Wall
	for c in sy: 
		var p = Vector2(px + sx, py + c)
		Data.s_map[p] = 1
	# Fill in the corner piece that doesn't want to be filled in normally
	Data.s_map[Vector2(px + sx, py + sy)] = 1


# Build a path extending out from a position in a N, S, W, or E direction.
# Takes [Starting Position] and [Direction]
# TODO:
#  - Add chance to create path offshoots.
#  - Make it more efficient. Possible multithreading.
func build_path(spo : Vector2, dir : int):
	# Nuke whatever we're currently on. 
	Data.s_map[spo] = 0
	
	# Check the direction
	match dir:
		# Build a north path
		1:
			# Start the path building loop, check to make sure we aren't at the border.
			while spo.y < Data.SECTOR_MAX_SIZE:
				# Create our new test position in the correct direction. Reuse starting position variable.				
				var tpos = Vector2(spo.x, spo.y)
				# Create walls on either side of our position.
				#Data.s_map[Vector2(tpos.x-1, tpos.y)] = 1
				#Data.s_map[Vector2(tpos.x+1, tpos.y)] = 1
				# If we hit a wall, end the path and punch a hole into the wall.
				if Data.s_map[tpos] == 1:
					Data.s_map[tpos] = 0
					Data.s_map[Vector2(spo.x, spo.y + 1)] = 0
					break
				else:
					Data.s_map[tpos] = 0
				# In this instance the direction is North or Positive Y.
				spo.y = spo.y + 1 
		# Build a south path
		2: 
			# Start the path building loop, check to make sure we aren't at the border.
			while spo.y > 0:
				# Create our new test position in the correct direction. Reuse starting position variable.
				var tpos = Vector2(spo.x, spo.y)
				# Create walls on either side of our position.
				#Data.s_map[Vector2(tpos.x-1, tpos.y)] = 1
				#Data.s_map[Vector2(tpos.x+1, tpos.y)] = 1
				# If we hit a wall, end the path and punch a hole into the wall.
				if Data.s_map[tpos] == 1:
					Data.s_map[tpos] = 0
					Data.s_map[Vector2(spo.x, spo.y - 1)] = 0
					break
				else:
					Data.s_map[tpos] = 0
				# In this instance the direction is South  or Negative Y.
				spo.y = spo.y - 1
				
		# Build an east path
		3: 
			# Start the path building loop, check to make sure we aren't at the border.
			while spo.x < Data.SECTOR_MAX_SIZE:
				# Create our new test position in the correct direction. Reuse starting position variable.
				var tpos = Vector2(spo.x, spo.y)
				# Create walls on either side of our position.
				#Data.s_map[Vector2(tpos.x, tpos.y-1)] = 1
				#Data.s_map[Vector2(tpos.x, tpos.y+1)] = 1
				# If we hit a wall, end the path and punch a hole into the wall.
				if Data.s_map[tpos] == 1:
					Data.s_map[tpos] = 0
					Data.s_map[Vector2(spo.x + 1, spo.y)] = 0
					break
				else:
					Data.s_map[tpos] = 0
				# In this instance the direction is East or Positive X.
				spo.x = spo.x + 1 
		# Build a west path
		4:
			# Start the path building loop, check to make sure we aren't at the border.
			while spo.x > 0:
				# Create our new test position in the correct direction. Reuse starting position variable.
				var tpos = Vector2(spo.x, spo.y)
				# Create walls on either side of our position.
				#Data.s_map[Vector2(tpos.x, tpos.y-1)] = 1
				#Data.s_map[Vector2(tpos.x, tpos.y+1)] = 1
				# If we hit a wall, end the path and punch a hole into the wall.
				if Data.s_map[tpos] == 1:
					Data.s_map[tpos] = 0
					Data.s_map[Vector2(spo.x - 1, spo.y)] = 0
					break
				else:
					Data.s_map[tpos] = 0
				# In this instance the direction is East or Positive X.
				spo.x = spo.x - 1

	#print("Completed a path.")	

















