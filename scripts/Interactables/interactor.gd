extends RayCast3D
class_name Interactor

var current_target: Interactable = null
var last_target: Node = null

func _physics_process(_delta: float) -> void:
	if is_colliding():
		var target: Node = get_collider()
		#print("Got interactable: ", target)
		
		# Walk up the parent chain until an Interactable is found
		while target and not (target is Interactable):
			target = target.get_parent()
		if target and target is Interactable:
			current_target = target
		else:
			current_target = null
	else:
		current_target = null
	last_target = current_target

func try_interact(player: Node) -> void:
	if not current_target:
		return
	# If this client IS the server, we can interact directly
	if multiplayer.is_server():
		current_target.request_interact(player.get_path())
	else:
		# Otherwise, ask the server to handle the interaction
		current_target.rpc_id(1, "request_interact", player.get_path())
