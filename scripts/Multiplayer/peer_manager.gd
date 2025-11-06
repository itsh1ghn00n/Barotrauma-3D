extends Node
class_name PeerManager
var peer : MultiplayerPeer 
enum PeerMode {
	LOCAL,
}
func _ready() -> void:
	set_peer_mode(0)

func get_peer():
	return peer

func update_multiplayer_peer():
	multiplayer.multiplayer_peer = get_peer()

func set_peer_mode(peer_mode : PeerMode):
	match peer_mode:
		PeerMode.LOCAL:
			peer = ENetMultiplayerPeer.new()
			peer.is_server_relay_supported()
	update_multiplayer_peer()
