
extends Node
class_name ItemSyncProxy

@export var item_id: int = -1
@export var item_data: ItemData

@export var syncer: MultiplayerSynchronizer

var sync_position : Vector3 = Vector3.ZERO
var sync_rotation : Vector3 = Vector3.ZERO

func _ready() -> void:
	if multiplayer.is_server():
		set_multiplayer_authority(1)
		#if syncer:
			#syncer.replication_interval = 0.01

func _physics_process(delta: float) -> void:
	var base = get_parent()
	
	if multiplayer.is_server():
		return
	
	# If we want to try and sync items through client here again
	
	#base.rotation = lerp(base.rotation ,sync_rotation, delta)
	#base.position = lerp(base.position ,sync_position, delta)
