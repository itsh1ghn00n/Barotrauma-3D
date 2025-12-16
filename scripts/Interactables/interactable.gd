extends Node3D
class_name Interactable

var behaviors: Array[InteractionBehavior]
@onready var syncer: MultiplayerSynchronizer = $MultiplayerSynchronizer

func _ready() -> void:
	var behavior_root := $Behaviors

	for child in behavior_root.get_children():
		if child is InteractionBehavior:
			behaviors.append(child)
	
	if not multiplayer.is_server():
		return
	set_multiplayer_authority(1)
	if syncer:
		syncer.set_multiplayer_authority(1)
		syncer.replication_interval = 0.01

@rpc("any_peer")
func request_interact(player_path: NodePath) -> void:
	# Only the server validates and applies
	if not multiplayer.is_server():
		return
	var player = get_node_or_null(player_path)
	if not player:
		return

	for behavior in behaviors:
		if behavior:
			behavior.execute(player, self)

	# Optional: confirm to all clients for animation/state sync
	rpc("confirm_interact", player_path)

@rpc("any_peer", "call_local")
func confirm_interact(player_path: NodePath) -> void:
	var player = get_node_or_null(player_path)
	if not player:
		return

	for behavior in behaviors:
		if behavior:
			behavior.on_confirm(player, self)
