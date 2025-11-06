extends Node3D

@export var orbit_camera: Node3D
@export var cell_size := 2.0

var current_cell := Vector3.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("forward"):
		_move_relative(-orbit_camera.global_transform.basis.z)
	elif event.is_action_pressed("back"):
		_move_relative(orbit_camera.global_transform.basis.z)
	elif event.is_action_pressed("left"):
		_move_relative(-orbit_camera.global_transform.basis.x)
	elif event.is_action_pressed("right"):
		_move_relative(orbit_camera.global_transform.basis.x)
	elif event.is_action_pressed("jump"):
		current_cell.y += cell_size
	elif event.is_action_pressed("crouch"):
		current_cell.y -= cell_size

func _move_relative(direction: Vector3) -> void:
	# Ignore camera pitch — stay horizontal
	direction.y = 0
	direction = direction.normalized()

	# Move exactly one grid cell
	current_cell += direction * cell_size

	# Snap to grid
	current_cell = current_cell.snapped(Vector3.ONE * cell_size)

	# Apply
	global_position = current_cell
