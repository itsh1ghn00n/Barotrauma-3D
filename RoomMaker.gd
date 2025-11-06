extends Node3D

@onready var cursor: Node3D = $Cursor
@onready var compartments_root: Node3D = $CompartmentsRoot

# Array of preloaded compartment scenes
@export var compartments: Array[PackedScene] = []

var current_index := 0
var rotation_index := 0
@export var grid_size := Vector3(1.0, 1.0, 3)  # X = width, Z = length
var cell_size:= 3

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		# Select compartment with 1–9
		if event.keycode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9]:
			current_index = event.keycode - KEY_1
			print("Selected compartment:", current_index)
		
		# Rotate with Q/E
		if event.keycode == KEY_Q:
			rotation_index = (rotation_index - 1) % 4
			_update_cursor_rotation()
		elif event.keycode == KEY_E:
			rotation_index = (rotation_index + 1) % 4
			_update_cursor_rotation()

		# Place compartment
		if event.keycode == KEY_ENTER:
			place_compartment()
		
		# Delete compartment (based on proximity to cursor)
		elif event.keycode == KEY_DELETE:
			remove_nearby_compartment()

func place_compartment():
	if current_index < 0 or current_index >= compartments.size():
		print("Invalid compartment index.")
		return

	var compartment_scene = compartments[current_index]
	if not compartment_scene:
		print("No compartment scene assigned at index:", current_index)
		return

	var instance = compartment_scene.instantiate()
	
	compartments_root.add_child(instance)
	
	instance.global_transform = cursor.global_transform

	# Snap position
	instance.global_position = instance.global_position.snapped(grid_size)
	
	# Apply rotation (in 90° increments)
	instance.rotate_y(deg_to_rad(rotation_index * 90))
	
	print("Placed compartment:", instance.name, "at", instance.global_position)

func remove_nearby_compartment():
	var threshold := cell_size * 0.5
	for child in compartments_root.get_children():
		if child.global_position.distance_to(cursor.global_position) < threshold:
			child.queue_free()
			print("Removed compartment at", child.global_position)
			return
	print("No compartment found near cursor")

func _update_cursor_rotation():
	cursor.rotation_degrees.y = rotation_index * 90
