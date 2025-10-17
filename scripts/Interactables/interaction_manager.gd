extends Node
class_name interaction_manager

@rpc("any_peer","call_local")
func request_interact(player_path: NodePath, target_path: NodePath) -> void:
	var player = get_node_or_null(player_path)
	var target = get_node_or_null(target_path)
	
	if not player or not target:
		return
	# SERVER validates
	if multiplayer.is_server():
		if target is Interactable:
			target.interact(player)
		# tell all clients
		rpc("confirm_interaction", player_path, target_path)
		
@rpc("authority")
func confirm_interaction(player_path: NodePath, target_path: NodePath) -> void:
	var player = get_node_or_null(player_path)
	var target = get_node_or_null(target_path)

	if target and target is Interactable:
		# Play animation / apply local effect
		target.interact(player)
