extends Compartment
class_name AirlockCompartment

@export var door1: Interactable
var door1_behavior : InteractionBehavior
@export var door2: Interactable
var door2_behavior : InteractionBehavior

func _physics_process(delta: float) -> void:
	if not physics_body: return
	if is_full:
		var full : Vector3 = Vector3.DOWN * max_volume
		physics_body.apply_force(full, global_position)
		return
	var air_volume = get_air_volume()
	
	var buoyancy_force = Vector3.UP * (air_volume * buoyancy_s)
	physics_body.apply_force(buoyancy_force, global_position)
	
	if (door1_behavior.is_open && door1_behavior.is_external || door2_behavior.is_open && door2_behavior.is_external):
		# Slowly flood compartment
		pass
	else: #External doors arent open
		# Slowly bail compartment
		pass
	
	if water_mat:
		water_mat.set_shader_parameter("water_level", fill_percentage)
