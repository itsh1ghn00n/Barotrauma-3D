extends MeshInstance3D

@export var min_fill: float = 0.0
@export var max_fill: float = 1.0
@export var speed: float = 1.0  # How fast it cycles

var direction: int = 1  # 1 = filling, -1 = emptying

func _process(delta):
	var mat := self.get_surface_override_material(0)
	if mat == null:
		return
	# Read current fill amount
	var fill = mat.get_shader_parameter("fill_amount")
	# Animate it up and down
	fill += direction * speed * delta
	
	if fill >= max_fill:
		fill = max_fill
		direction = -1
	elif fill <= min_fill:
		fill = min_fill
		direction = 1
	# Apply back to shader
	mat.set_shader_parameter("fill_amount", fill)
	
	rotation.z += speed/3 * delta
