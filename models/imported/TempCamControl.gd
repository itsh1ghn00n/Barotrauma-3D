extends Camera3D

@export var move_speed := 6.0
@export var mouse_sensitivity := 0.15
@export var min_pitch := -80.0
@export var max_pitch := 80.0

var yaw := 0.0
var pitch := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity * 0.01
		pitch -= event.relative.y * mouse_sensitivity * 0.01
		pitch = clamp(pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

		# Apply yaw around global Y
		rotation.y = yaw
		
		# Apply pitch locally
		rotation.x = pitch

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("backward"):
		input_dir.z += 1
	if Input.is_action_pressed("left"):
		input_dir.x -= 1
	if Input.is_action_pressed("right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	# Use global basis (not local) to avoid tilt from pitch
	var forward = global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()

	var right = global_transform.basis.x
	right.y = 0
	right = right.normalized()

	var movement = (forward * input_dir.z) + (right * input_dir.x)
	global_translate(movement * move_speed * delta)
