extends Control
class_name HotbarUI

const SLOT_SCENE := preload("res://ui/HotbarSlot.tscn")

@onready var container := $CanvasLayer/HBoxContainer
var slots: Array[HotbarSlot] = []

func _ready():
	if not is_multiplayer_authority():
		return
	for i in range(5):
		var slot: HotbarSlot = SLOT_SCENE.instantiate()
		container.add_child(slot)
		slots.append(slot)

func highlight_slot(index):
	for i in range(slots.size()):
		slots[i].highlight(i == index)
