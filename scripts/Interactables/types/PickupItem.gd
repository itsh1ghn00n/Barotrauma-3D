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
	print("Tried to interact", inventory)
	if inventory:
		if inventory.add_item(base_item.item_data):
			#print("Picked up:", base_item.item_data.name)
			if multiplayer.is_server():
				rpc("remove_item")
		else:
			print("Inventory full!")
