extends InteractionBehavior
class_name InventoryAddBehavior

@export var item_data: ItemData
@export var item_id: int = -1
@onready var parent_node : RigidBody3D = $"../.."
@export var item_collision_layer : int

func _ready() -> void:
	item_collision_layer = parent_node.collision_layer

func execute(player: Node, interactable: Node) -> void:
	var inventory: Inventory = player.get_node_or_null("Hotbar/Inventory")
	if not inventory:
		return
	var hotbar : Hotbar = player.get_node_or_null("Hotbar")
	if not hotbar:
		return
	var current_index = hotbar.current_index
	print("Execute inventory add on peer: ", player.multiplayer.get_unique_id(), " Server:", player.multiplayer.is_server())
	
	if player.multiplayer.is_server():
		if inventory.add_item(item_id, item_data, current_index):
			print("Added to inventory:", item_data.name)
	else:
		#Rpc to server telling the rest of the scene to add it to this players inventory
		pass

func set_item_id(id: int) -> void:
	item_id = id

func get_item_id() -> int:
	return item_id

func get_data():
	return item_data
