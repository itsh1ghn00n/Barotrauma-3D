extends RigidBody3D
class_name BaseItem

@export var item_data: ItemData
@onready var mesh: MeshInstance3D = $MeshInstance3D

var original_material: StandardMaterial3D
var highlight_material: StandardMaterial3D

func _ready():
	if mesh and mesh.get_surface_override_material_count() > 0:
		original_material = mesh.get_surface_override_material(0)
		highlight_material = original_material.duplicate()
		highlight_material.albedo_color = original_material.albedo_color.lightened(0.5)

func set_highlighted(state: bool):
	if not mesh or not original_material:
		return
	mesh.set_surface_override_material(0, highlight_material if state else original_material)
		
func interact(player: Node):
	if get_parent() and get_parent().has_method("interact"):
		get_parent().interact(player)
