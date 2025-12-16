extends CSGCylinder3D
class_name FuelTank

var current_fuel: float = 0.0
var target_fuel: float = 0.0
@export var max_fuel: float = 1.5

var base_fill_speed: float = 0.1
var max_fill_speed: float = 2.0

var fuel_mat: ShaderMaterial

func _ready() -> void:
	fuel_mat = material.duplicate() as ShaderMaterial
	material = fuel_mat
	set_fuel(max_fuel)
	_update_shader_fill()

func _process(delta: float) -> void:
	if abs(current_fuel - target_fuel) > 0.001:
		# Smoothly animate fuel toward target
		var diff = abs(current_fuel - target_fuel)
		var dynamic_speed = lerp(base_fill_speed, max_fill_speed, clamp(diff / max_fuel, 0.0, 1.0))
		current_fuel = move_toward(current_fuel, target_fuel, dynamic_speed * delta)
		_update_shader_fill()
	elif target_fuel == 0.0 and current_fuel != 0.0:
		current_fuel = 0.0
		_update_shader_fill()

# --- Public API ---

func set_fuel(val: float) -> void:
	target_fuel = clamp(val, 0.0, max_fuel)
	_update_shader_fill()

func add_fuel(val: float) -> void:
	# Add fuel but keep visual interpolation working
	if val <= 0.0:
		return
	target_fuel = clamp(target_fuel + val, 0.0, max_fuel)

func remove_fuel(val: float) -> void:
	# Remove fuel but keep smooth visuals
	if val <= 0.0:
		return
	target_fuel = clamp(target_fuel - val, 0.0, max_fuel)

func set_max() -> void:
	set_fuel(max_fuel)

# --- Helper for instant update (optional) ---
func force_update() -> void:
	current_fuel = target_fuel
	_update_shader_fill()

# --- Visual update ---
func _update_shader_fill() -> void:
	if fuel_mat:
		var normalized_fill: float = clamp(current_fuel / max_fuel, 0.0, 1.0)
		fuel_mat.set_shader_parameter("water_level", normalized_fill)
