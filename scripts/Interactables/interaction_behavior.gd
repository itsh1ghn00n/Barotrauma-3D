extends Node
class_name InteractionBehavior

@onready var syncer: MultiplayerSynchronizer = $MultiplayerSynchronizer

func _ready() -> void:
	if not multiplayer.is_server():
		return
	set_multiplayer_authority(1)
	if syncer:
		syncer.set_multiplayer_authority(1)
		syncer.replication_interval = 0.05

func execute(_player: Node, _interactable: Node) -> void:
	pass

func on_confirm(_player: Node, _interactable: Node) -> void:
	pass
