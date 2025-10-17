# Buoyancy.gd
extends RigidBody3D
class_name Buoyancy

@export var buoyancy_strength := 10.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05
@export var gravity := 9.8
@export var water_height := 0.0
@export var leveling_force := 2.0 # keeps the sub upright

@onready var compartments := get_tree().get_nodes_in_group("Compartments")

func _physics_process(delta: float) -> void:
	for c in compartments:
		var depth : float = water_height - c.global_position.y
		if depth <= 0:
			continue

		var factor := 1.0
		if c.has_method("get_effective_buoyancy"):
			factor = c.get_effective_buoyancy()

		var force := Vector3.UP * buoyancy_strength * factor
		apply_force(force, c.global_position - global_position)

	# Leveling force to keep upright
	var upright := global_transform.basis.y
	var tilt_correction := upright.cross(Vector3.UP) * leveling_force
	apply_torque_impulse(tilt_correction)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var submerged_any := false
	for c in compartments:
		if water_height - c.global_position.y > 0:
			submerged_any = true
			break
	if submerged_any:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag
