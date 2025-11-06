extends Node3D

@export var distance := 10.0
@export var rotation_speed := 0.3
@export var min_pitch := -1.2
@export var max_pitch := 1.2

@onready var camera := $Camera3D
@onready var cursor := $"../Cursor"

var yaw := 0.0
var pitch := 0.0

func _unhandled_input(event):
	if event is InputEventMouseMotion && Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if Input.is_key_pressed(KEY_SHIFT):
			yaw -= event.relative.x * rotation_speed * 0.01
			pitch = clamp(pitch - event.relative.y * rotation_speed * 0.01, min_pitch, max_pitch)

func _process(_delta):
	# Position orbit around the cursor
	global_position = cursor.global_position

	# --- Correct rotation order ---
	# First yaw around global Y
	var rot_y := Basis(Vector3.UP, yaw)
	# Then pitch around the camera's local X (so it tilts properly)
	var rot_x := Basis(Vector3.RIGHT, pitch)
	var rotation := rot_y * rot_x   # order matters!

	# Position the camera
	var offset := rotation * Vector3(0, 0, distance)
	camera.global_position = global_position + offset

	# Look back at the target
	camera.look_at(global_position, Vector3.UP)
