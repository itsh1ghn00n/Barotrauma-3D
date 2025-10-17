extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity: float = 9.8

const water_height := 0.0

var submerged := false

func _ready():
	pass
	
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var depth = water_height - global_position.y
	if depth > 0:
		apply_central_force(Vector3.UP * float_force * gravity * depth)
		
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if submerged:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag
