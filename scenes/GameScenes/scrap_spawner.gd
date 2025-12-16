extends Node3D

@export var sceneArray : Array[ItemData] = []
@export var spawnedItemsID : Array[int] = []

@export var ray : RayCast3D
@export var maxItems: int = 10
# Need to spawn items all around
# Use a temp raycast at spawn at a x height to raycast down
# If we hit a mesh spawn an item

func _ready() -> void:
	if not multiplayer.is_server():
		return
		
	await multiplayer.peer_connected
	await get_tree().process_frame
	
	spawn_scrap()

func spawn_scrap() -> void:
	randomize()
	print("Spawning Scrap")

	for i in range(maxItems):
		print("Loop index:", i)
		var attempts := 0
		var temp_pos: Vector3 = newPos()

		while not checkPosition(temp_pos) and attempts < 20:
			temp_pos = newPos()
			attempts += 1
			
		if attempts >= 20:
			push_warning("Could not find valid spawn position for item " + str(i))
			continue
		
		spawnItem(temp_pos)
	
func checkPosition(position : Vector3) -> bool:
	# at position raycast down
	ray.global_position = global_position + Vector3.UP * 10.0
	#ray.target_position = Vector3.DOWN * 20.0
	
	ray.force_raycast_update()
	
	return ray.is_colliding()

func newPos() -> Vector3:
	var randx = randi_range(0, 10)
	#var randy = randi_range(0, 2)
	var randz = randi_range(0, 10)
	var pos : Vector3 =  global_position + Vector3(randx, 20, randz)
	return pos
	
func spawnItem(pos : Vector3) -> void:
	var index := randi_range(0, sceneArray.size() - 1) # Grab a rand scene from sceneArray 0-max item
	var item_data : ItemData = sceneArray[index]
	
	print("Pos: ", pos, "Item: ", item_data.name)
	var id : int = ItemAPI.get_item_manager().spawn_item(pos, item_data)
	if id == -1:
		print("ItemManager failed to spawn item.")
		return
	
	spawnedItemsID.append(id)
	print("Spawned Item ID:", id, "Name:", item_data.name)
