extends Node3D
class_name Buoyancy

@export var sub_rigid: RigidBody3D

# Water surface (world Y)
@export var water_height: float = 0.0

# Target depth (meters below surface, positive = deeper)
@export var desired_depth: float = 10.0
@export var depth: float = 0.0

# --- Weak depth bias (NOT a hold) ---
@export var depth_bias_strength: float = 6.0
@export var depth_deadzone: float = 1.0

# --- Compartment forces ---
@export var buoyancy_strength: float = 12.0      # upward force per dry compartment
@export var flood_weight_strength: float = 35.0  # downward force per flooded compartment

# --- Orientation assist (very soft) ---
@export var pitch_assist: float = 10.0
@export var roll_assist: float = 10.0
@export var assist_multiplier: float = 0.35

@export var max_pitch_deg: float = 30.0
@export var max_roll_deg: float = 30.0

# --- Ballast trim ---
@export var ballast_trim_rate := 0.25   # m³ per second (slow!)
@export var tilt_deadzone := 0.03        # how tilted before we act

# --- Water drag (force-based) ---
@export var linear_drag: float = 0.8
@export var angular_drag: float = 0.6

@export var base_mass: float = 50.0

# Optional named compartments (for bias only)
@export var bow: Compartment
@export var stern: Compartment
@export var port: Compartment
@export var star: Compartment

@export var mid: Compartment

# Debug
@export var debug_pos: Node3D
@export var debug_pos2: Node3D
@export var draw_debug := true

@onready var compartments: Array = get_tree().get_nodes_in_group("Compartments")
@onready var ballasts: Array = get_tree().get_nodes_in_group("ballasts")

# --------------------------------------------------------------------

func _ready() -> void:
	if not sub_rigid:
		push_warning("Buoyancy: sub_rigid not assigned.")
		return

	sub_rigid.mass = base_mass
	sub_rigid.gravity_scale = 0.0   # we simulate gravity ourselves via flooding
	for b in ballasts:
		compartments.append(b)

# --------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if not sub_rigid:
		return
		
	var _a = DebugDraw3D.new_scoped_config().set_thickness(0.01)
	
	# Depth (positive underwater)
	depth = water_height - sub_rigid.global_position.y

	_auto_trim_ballasts(delta)
	_apply_compartment_forces()
	_apply_depth_bias()
	#_apply_orientation_assist()
	_apply_water_drag()
	
	if draw_debug:
		_draw_debug()
		
		for c in compartments:
			var fill : float = (c.get_fill_percentage())
			DebugDraw3D.draw_text(c.global_position, "%s: %.2f"%[c.name, fill * 100],10, Color.RED)
			var mapped :float= -((fill * 2.0) - 1.0)
			var b_vec :Vector3= Vector3(0.0, mapped, 0.0)
			var c_color :Color= Color.RED if mapped < 0.0 else Color.GREEN
			DebugDraw3D.draw_line(c.global_position, c.global_position + (b_vec), c_color)
		for b in ballasts:
			var fill : float = (b.get_fill_percentage())
			DebugDraw3D.draw_text(b.global_position, "%s: %.2f"%[b.name, fill * 100],10, Color.RED)

# --------------------------------------------------------------------
# CORE BEHAVIOR
# --------------------------------------------------------------------

func _apply_compartment_forces() -> void:
	for c in compartments:
		var comp := c as Compartment
		if not comp:
			continue

		var offset := comp.global_position - sub_rigid.global_position
		var fill :float= comp.get_effective_buoyancy()

		# Upward buoyancy from air
		var buoyancy_force := Vector3.UP * fill * buoyancy_strength
		sub_rigid.apply_force(buoyancy_force, offset)

		# Downward weight from flooding
		var flood_force := Vector3.DOWN * (1-fill) * (comp.max_volume * 2)
		sub_rigid.apply_force(flood_force, offset)

# --------------------------------------------------------------------

func _apply_depth_bias() -> void:
	var error := desired_depth - depth

	# Weak suggestion only
	#var bias_force := Vector3.UP * (-error * depth_bias_strength)
	#sub_rigid.apply_central_force(bias_force)
	
	if not mid:
		return
		
	var depth_adj :float= ballast_trim_rate * 2
	
	if error > 0:
		mid.modify_water(depth_adj)
	if error < 0:
		mid.modify_water(-depth_adj)

# --------------------------------------------------------------------

func _apply_orientation_assist() -> void:
	var basis := sub_rigid.global_transform.basis

	# Adjust axes if your model differs
	var forward := -basis.x
	var right := -basis.z

	var pitch_error := forward.y
	var roll_error := right.y

	# Small bias from asymmetric flooding
	if bow and stern:
		pitch_error += (stern.get_fill_percentage() - bow.get_fill_percentage()) * 0.4
	if port and star:
		roll_error += (star.get_fill_percentage() - port.get_fill_percentage()) * 0.4

	var torque := Vector3(
		-pitch_error * pitch_assist,
		0.0,
		-roll_error * roll_assist
	) * assist_multiplier

	sub_rigid.apply_torque(torque)

	# Soft safety clamp (not correction)
	var euler := basis.get_euler()
	if abs(euler.x) > deg_to_rad(max_pitch_deg):
		sub_rigid.angular_velocity.x *= 0.7
	if abs(euler.z) > deg_to_rad(max_roll_deg):
		sub_rigid.angular_velocity.z *= 0.7

# --------------------------------------------------------------------

func _auto_trim_ballasts(delta: float) -> void:
	if not bow or not stern or not port or not star:
		return
	sub_rigid.angular_velocity *= Vector3(0.92, 1.0, 0.92)
	
	var basis := sub_rigid.global_transform.basis
	var forward := -basis.x
	var right := -basis.z

	var pitch := forward.y   # >0 nose up
	var pitch_mag :float= abs(pitch)
	var pitch_factor :float= clamp(
		(pitch_mag - tilt_deadzone) / 0.25,
		0.0, 1.0
	)
	var pitch_adj :float= pitch_factor * ballast_trim_rate * delta
	
	var roll := right.y     # >0 right side up
	var roll_mag :float= abs(roll)
	var roll_factor :float= clamp(
		(roll_mag - tilt_deadzone) / 0.25,
		0.0, 1.0
	)
	var roll_adj :float= roll_factor * ballast_trim_rate * delta

	# ---- PITCH TRIM ----
	if abs(pitch) > tilt_deadzone:
		if pitch >= 0.0:
			# Nose up → add water to bow, remove from stern
			bow.modify_water(pitch_adj)
			stern.modify_water(-pitch_adj)
		else:
			# Nose down → add water to stern, remove from bow
			bow.modify_water(-pitch_adj)
			stern.modify_water(pitch_adj)

	# ---- ROLL TRIM ----
	if abs(roll) > tilt_deadzone:	
		if roll >= 0.0:
			# Right side up → add water right, remove left
			star.modify_water(roll_adj)
			port.modify_water(-roll_adj)
		else:
			# Left side up → add water left, remove right
			star.modify_water(-roll_adj)
			port.modify_water(roll_adj)

# --------------------------------------------------------------------

func _apply_water_drag() -> void:
	if sub_rigid.global_position.y > water_height:
		return

	sub_rigid.apply_central_force(-sub_rigid.linear_velocity * linear_drag)
	sub_rigid.apply_torque(-sub_rigid.angular_velocity * angular_drag)

# --------------------------------------------------------------------
# PUBLIC API
# --------------------------------------------------------------------

func return_depth() -> float:
	return depth

func return_desired_depth() -> float:
	return desired_depth

func set_desired_depth(d: float) -> void:
	desired_depth = max(d, 0.0)

func set_water_h(h: float) -> void:
	water_height = h
	
func _draw_debug() -> void:
	var basis := sub_rigid.global_transform.basis
	var forward := -basis.x
	var right := -basis.z
	var up := basis.y

	var pitch_rad := asin(clamp(forward.y, -1.0, 1.0))
	var roll_rad := asin(clamp(right.y, -1.0, 1.0))

	var pitch_deg := rad_to_deg(pitch_rad)
	var roll_deg := rad_to_deg(roll_rad)

	# --- 3D axis indicators ---
	if debug_pos:
		DebugDraw3D.draw_line(debug_pos.global_position, debug_pos.global_position + forward, Color.GREEN)
		DebugDraw3D.draw_line(debug_pos.global_position, debug_pos.global_position + up, Color.BLUE)
		DebugDraw3D.draw_line(debug_pos.global_position, debug_pos.global_position + right, Color.RED)

		# Pitch & Roll indicators
		DebugDraw3D.draw_line(
			debug_pos.global_position,
			debug_pos.global_position + Vector3(0, pitch_error_clamped(forward), 0),
			Color.ORANGE
		)

	# --- Text readout ---
	if debug_pos2:
		DebugDraw3D.draw_text(debug_pos2.global_position,
			"Depth: %.2f" % depth, 10, Color.AQUA)

		DebugDraw3D.draw_text(debug_pos2.global_position + Vector3(0, 0.25, 0),
			"Desired: %.2f" % desired_depth, 10, Color.WHITE)
			
		var error := desired_depth - depth
		DebugDraw3D.draw_text(debug_pos2.global_position + Vector3(0, 0.5, 0),
			"D-Error: %.2f" % error, 10, Color.SKY_BLUE)
		
		DebugDraw3D.draw_text(debug_pos2.global_position + Vector3(0, 0.75, 0),
			"V-Speed: %.2f" % sub_rigid.linear_velocity.y, 10, Color.SKY_BLUE)

		DebugDraw3D.draw_text(debug_pos2.global_position + Vector3(0, 1, 0),
			"Pitch: %.1f°" % pitch_deg, 10, Color.ORANGE)

		DebugDraw3D.draw_text(debug_pos2.global_position + Vector3(0, 1.25, 0),
			"Roll: %.1f°" % roll_deg, 10, Color.YELLOW)

func pitch_error_clamped(forward: Vector3) -> float:
	return clamp(forward.y, -1.0, 1.0)
