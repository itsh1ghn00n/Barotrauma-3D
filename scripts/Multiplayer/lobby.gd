extends Node

@export var peer_manager : PeerManager
@export var map_spawner : MultiplayerSpawner

@export_category("Local Lobby")

var local_lobby_id : int = 1
@export var local_addr : String = "67.176.84.224"
@export var local_port : int = 5000
@export var local_max_players : int = 4
signal on_local_lobby_created

func _ready() -> void:
	var args = OS.get_cmdline_args()
	
	await get_tree().process_frame
	if "--host" in args:
		setup_local_lobbies()
		create_local_lobby()
		
	await get_tree().create_timer(0.5).timeout
	if "--client" in args:
		setup_local_lobbies()
		var idx = args.find("--client")
		if idx + 1 < args.size():
			local_addr = args[idx + 1]   # IP after --client
		if idx + 2 < args.size():
			local_port = int(args[idx + 2]) # Port after IP
		join_local_lobby()

func setup_local_lobbies():
	peer_manager.set_peer_mode(peer_manager.PeerMode.LOCAL)

func create_local_lobby():	
	var err = peer_manager.get_peer().create_server(local_port, local_max_players, 0)
	if err != OK:
		print("Server creation error: ", err)
	else:
		print("Server created on port ", local_port)
	peer_manager.update_multiplayer_peer()
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	map_spawner.spawn(map_spawner.map_path)
	on_local_lobby_created.emit()
	
func _on_peer_connected(id: int) -> void:
	print("Client connected with peer ID: ", id)

func _on_peer_disconnected(id: int) -> void:
	print("Client disconnected with peer ID: ", id)

func join_local_lobby():
	var err = peer_manager.get_peer().create_client(local_addr, local_port)
	if err != OK:
		print("Client connection error: ", err)
	else:
		print("Attempting to connect to server at ", local_addr, ":", local_port)

	peer_manager.update_multiplayer_peer()

	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected_to_server() -> void:
	print("Successfully connected to the server!")

func _on_connection_failed() -> void:
	print("Failed to connect to server.")

func _on_server_disconnected() -> void:
	print("Disconnected from the server.")
