# Inventory.gd
class_name Inventory
extends Node

signal inventory_updated(item: ItemData)

@export var max_slots: int = 10
var slots: Array[ItemData] = []

func _ready():
	slots.resize(max_slots)

func add_item(item_data: ItemData) -> bool:
	for i in range(max_slots):
		if slots[i] == null:
			slots[i] = item_data
			inventory_updated.emit(item_data)
			print("Added: ", item_data.name, " to inventory")
			return true
	return false

func remove_item(slot: int) -> bool:
	if slot < 0 or slot >= max_slots:
		return false
	
	var item_data = slots[slot]
	if item_data == null:
		return false
		
	slots[slot] = null
	inventory_updated.emit(item_data)
	print("Removed: ", item_data.name, " from slot ", slot)
	return true

func get_hotbar_items(count: int = 5) -> Array:
	return slots.slice(0, count)
