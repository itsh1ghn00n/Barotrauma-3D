extends Interactable
class_name PickupItem

@onready var base_item: BaseItem = $BaseItem
var held : bool = false

@rpc("authority", "call_local")
func remove_item():
	queue_free()

func interact(player: Node) -> void:
	if not base_item:
		return
	
	var inventory = player.get_node_or_null("Hotbar/Inventory")
	if not inventory:
		return
		
	if multiplayer.is_server():
		_handle_interaction(player)
	else:
		rpc_id(1, "request_interact", player.get_path(), base_item.get_path())

func _handle_interaction(player: Node) -> void:
	var inventory = player.get_node_or_null("Hotbar/Inventory")
	if inventory and inventory.add_item(base_item.item_data):
		print("Picked up:", base_item.item_data.name)
		rpc("remove_item")  # remove the item on all clients
	else:
		print("Inventory full!")
