# Interactable.gd
class_name Interactable
extends Node3D

@export var interact_prompt: String = "Press [E] to interact"

func interact(player: Node) -> void:
	
	print("was interacted with by", player)
