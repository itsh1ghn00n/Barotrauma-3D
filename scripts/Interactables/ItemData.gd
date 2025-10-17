# ItemData.gd

extends Resource
class_name ItemData

@export var name: String
@export var icon: Texture2D
@export var stack_size: int = 1
@export var scene_resource: String

func create_instance() -> Node3D:
	var scene = load(scene_resource) as PackedScene
	return scene.instantiate()
