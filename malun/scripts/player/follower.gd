extends Node3D

func _process(delta):
		
	var look_dir = Input.get_vector("p_lookr", "p_lookl", "blank", "blank")
	if look_dir:
		rotation.y = (look_dir.x * 0.025) + rotation.y
	
		
