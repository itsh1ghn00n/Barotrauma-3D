extends Node
class_name hotbar_manager

# Called locally by a player (host or client)
func request_equip_slot_local(player_id: int, index: int) -> void:
	if multiplayer.is_server():
		_process_equip_slot(player_id, index)
	else:
		rpc_id(1, "request_equip_slot_remote", player_id, index)

func request_throw_item_local(player_id: int) -> void:
	if multiplayer.is_server():
		_process_throw_item(player_id)
	else:
		rpc_id(1, "request_throw_item_remote", player_id)


# === RPCs received by the server ===
@rpc("any_peer")
func request_equip_slot_remote(player_id: int, index: int) -> void:
	if not multiplayer.is_server():
		return
	# Validation: ensure sender == player_id
	if multiplayer.get_remote_sender_id() != player_id:
		return
	_process_equip_slot(player_id, index)

@rpc("any_peer")
func request_throw_item_remote(player_id: int) -> void:
	if not multiplayer.is_server():
		return
	if multiplayer.get_remote_sender_id() != player_id:
		return
	_process_throw_item(player_id)


# === Server-side authoritative logic ===
func _process_equip_slot(player_id: int, index: int) -> void:
	var player = _get_player_by_id(player_id)
	if not player:
		return

	var hotbar = player.get_node_or_null("Hotbar")
	if not hotbar:
		return

	hotbar._apply_equip_slot(index)
	print("Applied equip slot", index, "for player", player_id)

	# Broadcast only to that player to sync visuals
	rpc_id(player_id, "confirm_equip_slot", index)


func _process_throw_item(player_id: int) -> void:
	var player = _get_player_by_id(player_id)
	if not player:
		return

	var hotbar = player.get_node_or_null("Hotbar")
	if not hotbar:
		return

	hotbar._apply_throw_item()
	print("Processed throw for player", player_id)

	# Broadcast only to that player to sync visuals
	rpc_id(player_id, "confirm_throw_item")


# === RPCs received by individual clients ===
@rpc("authority", "call_local")
func confirm_equip_slot(index: int) -> void:
	var player = _get_local_player()
	if player and player.has_node("Hotbar"):
		player.get_node("Hotbar")._apply_equip_slot(index)
		print("Confirmed equip slot", index)

@rpc("authority", "call_local")
func confirm_throw_item() -> void:
	var player = _get_local_player()
	if player and player.has_node("Hotbar"):
		player.get_node("Hotbar")._apply_throw_item()
		print("Confirmed throw item")


# === Utility ===
func _get_player_by_id(peer_id: int) -> Node3D:
	for player in get_tree().get_nodes_in_group("Players"):
		if player.get_multiplayer_authority() == peer_id:
			return player
	return null

func _get_local_player() -> Node3D:
	for player in get_tree().get_nodes_in_group("Players"):
		if multiplayer.get_unique_id() == player.get_multiplayer_authority():
			return player
	return null
