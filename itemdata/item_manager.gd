extends MultiplayerSpawner

@export var items: Dictionary = {}
var next_id := 1

signal item_spawned(id, node)
signal item_removed(id)
var items_root

func _ready():
	spawn_limit = 0
	spawn_function = _server_spawn
	items_root = get_node(spawn_path)

	await get_tree().process_frame  # important
	if multiplayer.is_server():
		_register_existing_items()

# Internal mediary function for spawning
func _server_spawn(data):
	var scene: PackedScene = load(data["scene_path"])
	print("Intantiating scene: ",scene)
	var pos: Vector3 = data["pos"]

	var node = scene.instantiate()
	node.global_position = pos

	items_root.add_child(get_node(spawn_path), true)

	# assign id
	var InventoryAdd : InventoryAddBehavior = node.get_node_or_null("Behaviors/InventoryAddBehavior")
	var id = next_id
	next_id += 1
	InventoryAdd.set_item_id(id)
	items[id] = node

	return node

# Call this external
func spawn_item(pos: Vector3, item_data: ItemData) -> int:
	var data = {
		"scene_path": item_data.scene_path,
		"pos": pos
	}

	var node = spawn(data)
	var InventoryAdd : InventoryAddBehavior = node.get_node_or_null("Behaviors/InventoryAddBehavior")
	print(node)
	if node == null:
		push_error("MultiplayerSpawner failed to create node!")
		return -1
	return InventoryAdd.get_item_id()

func remove_item(id: int) -> void:
	items[id] = null # remove at id position

func get_item_node(id: int) -> Node3D:
	return items.get(id)

func get_item_data(id: int) -> ItemData:
	var node = items.get(id)
	var InventoryAdd : InventoryAddBehavior = node.get_node_or_null("Behaviors/InventoryAddBehavior")
	return InventoryAdd.get_data()

func _register_existing_items():
	for node in items_root.get_children():
		if not (node is RigidBody3D):
			continue
		var InventoryAdd : InventoryAddBehavior = node.get_node_or_null("Behaviors/InventoryAddBehavior")
		if not InventoryAdd:
			return
		var id = next_id
		next_id += 1
		InventoryAdd.set_item_id(id)
		items[id] = node
		item_spawned.emit(id, node)

	print("Autoregistered ", items.size(), " existing items.")
