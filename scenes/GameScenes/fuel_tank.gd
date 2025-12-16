extends StaticBody3D

@export var AttachPoint: Node3D
@export var AttachZone: Area3D
@export var FuelPort: RigidBody3D

@export var magnet_strength: float = 7.0       # how strongly it pulls
@export var stop_distance: float = 0.05        # how close before snapping
@export var align_rotation: bool = true        # whether to align rotation

@export var Fueltank: FuelTank                 # main large tank
var attachedBody: RigidBody3D                  # attached rigidbody (fuel cell)
var attached_fuel: FuelTank                    # internal fuel script on that body

@export var fill_speed: float = 1.0            # transfer rate in fuel units per second
var magnetizing := false
var is_attached := false

func _ready() -> void:
	AttachZone.body_entered.connect(_on_body_entered)
	AttachZone.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	# --- Magnetic attraction ---
	if magnetizing and attachedBody:
		var target_pos := AttachPoint.global_position
		var current_pos := attachedBody.global_position
		var to_target := target_pos - current_pos
		var dist := to_target.length()

		if dist > stop_distance:
			to_target = to_target.normalized()
			var force := to_target * magnet_strength
			attachedBody.apply_central_force(force)
		else:
			# Snap & freeze once close enough
			attachedBody.global_transform = AttachPoint.global_transform
			_freeze_rigidbody(attachedBody, true)
			magnetizing = false
			is_attached = true
			print("Body attached!")

	# --- Fuel transfer ---
	if is_attached and Fueltank:
		if attached_fuel:
			# Transfer fuel between tank
			var transfer_amount = fill_speed * delta
			Fueltank.add_fuel(transfer_amount)
			attached_fuel.remove_fuel(transfer_amount)
			
			# Detach or destroy when empty
			if attached_fuel.current_fuel <= 0.001:
				print("Attached fuel tank emptied — detaching.")
				attachedBody.queue_free()
				attachedBody = null
				attached_fuel = null
				is_attached = false
				magnetizing = false
		else:
			# Auto-fill the main tank if nothing is attached
			var transfer_amount = fill_speed * delta
			Fueltank.add_fuel(transfer_amount)

func _on_body_entered(body: Node) -> void:
	if body == FuelPort:
		attachedBody = body
		magnetizing = true
		_freeze_rigidbody(FuelPort, false)

	elif body.has_node("Mesh/Fuel"):
		attachedBody = body
		attached_fuel = body.get_node("Mesh/Fuel") as FuelTank
		magnetizing = true
		_freeze_rigidbody(body, false)
		print("Detected and magnetized fuel cell.")

func _on_body_exited(body: Node) -> void:
	if body == FuelPort or body == attachedBody:
		magnetizing = false
		is_attached = false
		print("Detached:", body.name)
		if body == attachedBody:
			attachedBody = null
			attached_fuel = null

# Helper to lock or unlock rigidbody motion
func _freeze_rigidbody(body: RigidBody3D, state: bool) -> void:
	if not body:
		return
	body.freeze = state
	if state:
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO
