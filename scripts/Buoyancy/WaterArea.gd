# WaterArea.gd
extends Area3D

@onready var water_maker: WaterMaker3D = get_tree().get_first_node_in_group("WaterMakers")
@export var player_container : Node3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.set_submerged(true)
		#body.reparent(player_container)
		var peer_id := body.get_multiplayer_authority()
		if peer_id != 0:
			water_maker.decrease_no_water(peer_id)

#func _on_body_exited(body: Node) -> void:
	#if body is Player:
		#body.set_submerged(false)
