extends CharacterBody3D


const SPEED = 3.5
const RAY_LENGTH = 256
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
#
var space_state

func _ready():
	space_state = get_world_3d().direct_space_state

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var walk_dir = Input.get_vector("p_left", "p_right", "p_up", "p_down")
	var direction = (transform.basis * Vector3(walk_dir.x, 0, walk_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	
	# Make the character mesh point towards the mouse
	# We do this by casting a ray based off the given mouse position in the screen 
	var cam = $Detatched/Follower/ThirdPerson
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	
	look_at(result.position)
	$Detatched/Follower.position.x = position.x
	$Detatched/Follower.position.z = position.z
	 
	
	move_and_slide()
