extends CharacterBody3D


const SPEED = 4
const RAY_LENGTH = 256
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Custom player data
@export var personal_data : Dictionary

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	debug_update()

func _physics_process(delta):
	# Make the character mesh point towards the mouse
	# We do this by casting a ray based off the given mouse position in the screen 
	# var cam = $Detatched/Follower/FirstPerson
	# var mousepos = get_viewport().get_mouse_position()

	# var origin = cam.project_ray_origin(mousepos)
	# var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	# var query = PhysicsRayQueryParameters3D.create(origin, end)
	# query.collide_with_areas = true

	# var result = space_state.intersect_ray(query)
	# if result:
		# pass
		# $Detatched/Mesh/Torso.look_at(result.position)

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var walk_dir = Input.get_vector("p_right", "p_left", "p_down", "p_up")
	var direction = (transform.basis * Vector3(walk_dir.x, 0, walk_dir.y)).normalized()
	if direction:
		rotation.y = $Detatched/Mesh/Torso.rotation.y
		$Detatched/Mesh/Legs.rotation.y = lerp($Detatched/Mesh/Legs.rotation.y, $Detatched/Mesh/Torso.rotation.y, 0.25)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	#Update the position of our camera follower.
	$Detatched/Follower.position.x = position.x
	$Detatched/Follower.position.z = position.z

	$Detatched/Mesh.position = position
	
	move_and_slide()

func _input(event):
	# Handle mose look 
	if event is InputEventMouseMotion and Input.MOUSE_MODE_CAPTURED:
		$Detatched/Mesh/Torso.rotate_y(-event.relative.x * 0.02)
		$Detatched/Mesh/Torso/FirstPerson.rotate_x(event.relative.y * 0.01)
		$Detatched/Mesh/Torso/FirstPerson.rotation.x = clampf($Detatched/Mesh/Torso/FirstPerson.rotation.x, -deg_to_rad(45), deg_to_rad(45))

func debug_update(): 
	$UI/debug/pos.text = var_to_str(position)
