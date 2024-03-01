extends CharacterBody3D

signal nav_target(target)

const SPEED = 2
const JUMP_VELOCITY = 4.5


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	pass
	#nav_target.connect(_nav_target())
	

func _physics_process(delta):
	
	var noises = $NoiseListener.get_overlapping_areas()
	if noises:
		$NavAgent.target_position = noises[0].global_position
	
	if not $NavAgent.is_navigation_finished():
		velocity = position.direction_to($NavAgent.get_next_path_position()).normalized() * SPEED
		look_at(Vector3($NavAgent.get_next_path_position().x, position.y, $NavAgent.get_next_path_position().z))
	else: 
		velocity = Vector3(0,0,0)
		#print(velocity)

	if not is_on_floor():
		velocity.y -= gravity * delta

	
	move_and_slide()
