extends Node3D
class_name Compartment

@export var max_volume: float = 10.0     # in cubic meters
@export var fill_percentage: float = 0.0 # 0.0 = empty, 1.0 = full
var physics_body: RigidBody3D = null
var buoyancy_s: float = 0.0
var water_height : float = 0.0
@export var is_full = false

@export var water_node: GeometryInstance3D = null # The mesh we use for water display and for detecting when water is poured in
var water_mat: ShaderMaterial

func _ready() -> void:
	if water_node:
		water_mat = water_node.material_override.duplicate() as ShaderMaterial
		water_node.material_override = water_mat
# Eventually change to just CollisionMesh3D
func _physics_process(delta: float) -> void:
	if not physics_body: return
	
	if water_mat:
		water_mat.set_shader_parameter("water_level", fill_percentage)

func set_fill_percentage(value: float) -> void:
	fill_percentage = clamp(value, 0.0, 1.0)
	
func get_fill_percentage() -> float:
	return fill_percentage

func modify_water(amount: float) -> void:
	# amount is in cubic meters
	set_fill_percentage(fill_percentage + (amount / max_volume))
	
func get_air_volume() -> float:
	return max_volume * (1.0 - fill_percentage)

func get_water_volume() -> float:
	return max_volume * fill_percentage

func get_effective_buoyancy() -> float:
	# Buoyancy contribution is proportional to AIR volume only
	# Full = 0 buoyancy, empty = full buoyancy
	return get_air_volume() / max_volume

func get_water_mass() -> float:
	# Water mass = density * volume
	return get_water_volume()

func get_total_mass() -> float:
	# If the compartment has additional structural mass, add it here later
	return get_water_mass()

func is_flooded() -> bool:
	# Flooded when any amount of water is present
	return fill_percentage > 0.01
	
