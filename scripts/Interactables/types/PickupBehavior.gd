extends InteractionBehavior
class_name PickupBehavior

func execute(player: Node, interactable: Node):
	var hotbar = player.get_node_or_null("Hotbar")
	if not hotbar:
		return
	print("Attaching Item: ", interactable)
	# Move to hand on server
	hotbar.attach(interactable)
	
	var InventoryAdd : InventoryAddBehavior = interactable.get_node_or_null("Behaviors/InventoryAddBehavior")
	if InventoryAdd:
		var id = InventoryAdd.get_item_id()
		if id:
			hotbar.held_item_id = id
			print("Hotbar ID: ", hotbar.held_item_id)
		else:
			push_warning("Couldnt find ID!")
