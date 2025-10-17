extends Node3D
class_name Compartment

@export var max_volume : float = 10.0
@export var fill_percentage : float = 0.0

func set_fill_percentage(value: float) -> void:
	fill_percentage = clamp(value, 0.0, 1.0)

func add_water(amount: float) -> void:
	set_fill_percentage(fill_percentage + amount / max_volume)

func remove_water(amount: float) -> void:
	set_fill_percentage(fill_percentage - amount / max_volume)

func get_effective_buoyancy() -> float:
	# Full = 0 buoyancy, empty = full buoyancy
	return 1.0 - fill_percentage

func get_flooded() -> bool:
	if get_effective_buoyancy():
		return true
	else:
		return false
	
