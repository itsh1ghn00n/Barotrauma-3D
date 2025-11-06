extends Node3D

@export var vert: Array[Marker3D]

@export var room_material: Material

@export var mesh_parent_path: NodePath = ^"MeshParent"

func _ready() -> void:
	if vert.size() < 3:
		push_error("Need at least 3 vertices to make a mesh.")
		return

	var vertices = PackedVector3Array()
	for marker in vert:
		vertices.push_back(marker.position)

	var indices = PackedInt32Array([
		0, 2, 1,  2, 3, 1,
		4, 5, 6,  6, 5, 7,
		1, 4, 0,  5, 4, 1,
		2, 6, 3,  3, 6, 7,
		0, 4, 2,  2, 4, 6,
		3, 5, 1,  7, 5, 3
	])
	
	for v in vert:
		var s = MeshInstance3D.new()
		s.scale = Vector3(0.002, 0.002, 0.002)
		s.mesh = SphereMesh.new()
		s.global_position = v.position
		add_child(s)

	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

	var m = MeshInstance3D.new()
	m.mesh = arr_mesh
	
	var mat = StandardMaterial3D.new() 
	mat.albedo_color = Color(0.8, 0.2, 0.1) 
	m.material_override = mat
	
	#var mat = room_material.duplicate()
	#if room_material:
		#m.set_surface_override_material(0, mat)
	
	var mesh_parent = get_node_or_null(mesh_parent_path)
	if mesh_parent:
		mesh_parent.add_child(m)
