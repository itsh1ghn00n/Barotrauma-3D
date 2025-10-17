# WaterArea.gd
extends Area3D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.set_submerged(true)

func _on_body_exited(body: Node) -> void:
	if body is Player:
		body.set_submerged(false)
