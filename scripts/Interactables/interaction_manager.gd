extends Node
class_name interaction_manager

@rpc("any_peer", "call_local")
func request_interact(player_path: NodePath, target_path: NodePath) -> void:
	if not multiplayer.is_server(): return

	var player = get_node_or_null(player_path)
	var target = get_node_or_null(target_path)
	if not player or not target: 
		return

	# Server applies logic (items, doors, etc.)
	#if target is PickupItem:
		#target._handle_interaction(player)
	
	# Tell all peers (including player) to reflect visuals
	rpc("confirm_interaction", player_path, target_path)
		
@rpc("any_peer", "call_local")
func confirm_interaction(player_path: NodePath, target_path: NodePath) -> void:
	var player = get_node_or_null(player_path)
	var target = get_node_or_null(target_path)
	if not player or not target: return

	if target is PickupItem:
		target._handle_interaction(player)
