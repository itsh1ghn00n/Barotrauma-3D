extends MultiplayerSpawner
@export var map : PackedScene
@export var map_path : String = "res://scenes//map.tscn"
func _ready() -> void:
	spawn_function = spawn_map
	
func spawn_map(data) -> Node:
	var new_map = (load(data) as PackedScene).instantiate()
	return new_map
