extends Node3D

@export_node_path var step_target_path
@onready var step_target = get_node(step_target_path)

@export var step_distance: float = 5

func _process(delta):
	var dist := global_position.distance_to(step_target.global_position)
	if dist > step_distance: 
		tween_step(step_target.global_position)
		print("Step target too far, changing position...")
	
func tween_step(target_pos: Vector3): 
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	tween.tween_property(self, "global_position:x", target_pos.x, 0.25)
	tween.tween_property(self, "global_position:x", target_pos.z, 0.25)
	tween.tween_property(self, "global_position:x", target_pos.y, 0.25)
	#tween.set_parallel(true)
	#tween.tween_property(self, "global_position:x", target_pos.y, 0.1)
