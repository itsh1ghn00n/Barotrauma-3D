extends Node3D
class_name Mass

func _physics_process(delta: float) -> void:
	pass
	#if not physics_body:
		#return
	#if is_full:
		#var full : Vector3 = Vector3.DOWN * 9.8
		#physics_body.apply_force(full, global_position)
		#return
	#var comp_depth := water_height - global_position.y
	#if comp_depth <= 0.0:
		#return
	#var factor := get_effective_buoyancy()
	#if factor <= 0.0:
		#return
	#var force : Vector3 = Vector3.UP * buoyancy_s * factor
	#physics_body.apply_force(force, global_position)
