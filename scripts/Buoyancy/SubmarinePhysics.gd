extends RigidBody3D
class_name SubmarinePhysics

@export var mass_override: float = 1000.0
@export var inertia_override: Vector3 = Vector3(500, 500, 500)

@export var linear_damping_custom := 0.1
@export var angular_damping_custom := 0.1

var accumulated_forces: Array[ForceEntry] = []
var accumulated_torques: Array[Vector3] = []

func add_force(force: Vector3, world_pos: Vector3) -> void:
	accumulated_forces.append(ForceEntry.new(force, world_pos))

func add_torque(torque: Vector3) -> void:
	accumulated_torques.append(torque)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var total_force := Vector3.ZERO
	var total_torque := Vector3.ZERO

	var com := state.transform.origin

	# Sum forces
	for f in accumulated_forces:
		total_force += f.force
		var r := f.position - com
		total_torque += r.cross(f.force)

	for t in accumulated_torques:
		total_torque += t

	accumulated_forces.clear()
	accumulated_torques.clear()

	# ----------------------------
	# LINEAR INTEGRATION
	# ----------------------------
	var velocity := state.linear_velocity
	var accel := total_force / mass_override
	velocity += accel * state.step
	velocity *= (1.0 - linear_damping_custom * state.step)
	state.linear_velocity = velocity

	# ----------------------------
	# ANGULAR INTEGRATION
	# ----------------------------
	var ang_vel := state.angular_velocity
	var ang_accel := Vector3(
		total_torque.x / inertia_override.x,
		total_torque.y / inertia_override.y,
		total_torque.z / inertia_override.z
	)

	ang_vel += ang_accel * state.step
	ang_vel *= (1.0 - angular_damping_custom * state.step)

	state.angular_velocity = ang_vel

class ForceEntry:
	var force: Vector3
	var position: Vector3
	func _init(f: Vector3, p: Vector3) -> void:
		force = f
		position = p
