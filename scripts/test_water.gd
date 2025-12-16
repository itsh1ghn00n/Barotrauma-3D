extends Node3D
class_name test_water

@export var min_fill: float = 0.0
@export var max_fill: float = 1.0
@export var speed: float = 1.0  # How fast it cycles

@export var targetMesh: MeshInstance3D

var direction: int = 1  # 1 = filling, -1 = emptying
var mat: Material

func _enter_tree():
	child_entered_tree.connect(_on_child_entered_tree)
	
func _on_child_entered_tree(child: Node):
	if child is MeshInstance3D:
		targetMesh = child
		mat = targetMesh.get_surface_override_material(0)
		print("targetMesh found: %s" % targetMesh.name)
		
func _input(event: InputEvent) -> void:
	pass
	#if event.is_action_pressed("test_1"):
		#mat.set_shader_parameter("fill_amount", max_fill)
		#print("Fill set to full")
	#if event.is_action_pressed("test_2"):
		#mat.set_shader_parameter("fill_amount", 0.5)
		#print("Fill set to half")
	#if event.is_action_pressed("test_3"):
		#mat.set_shader_parameter("fill_amount", min_fill)
		#print("Fill set to empty")

func _process(delta):
	if targetMesh == null:
		return
	if mat == null:
		return

	# --- Keyboard controls for manual fill ---
	#if Input.is_action_just_pressed("test_1"):  # key '1'
		#mat.set_shader_parameter("fill_amount", max_fill)
		#print("Fill set to full")
	#elif Input.is_action_just_pressed("test_2"):  # key '2'
		#mat.set_shader_parameter("fill_amount", 0.5)
		#print("Fill set to half")
	#elif Input.is_action_just_pressed("test_3"):  # key '3'
		#mat.set_shader_parameter("fill_amount", min_fill)
		#print("Fill set to empty")

	# --- Automatic wave animation ---
	var fill = mat.get_shader_parameter("fill_amount")
	fill += direction * speed * delta

	if fill >= max_fill:
		fill = max_fill
		direction = -1
	elif fill <= min_fill:
		fill = min_fill
		direction = 1

	mat.set_shader_parameter("fill_amount", fill)
	rotation.z += speed / 3 * delta
