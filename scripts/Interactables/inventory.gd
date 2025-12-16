# Inventory.gd
class_name Inventory
extends Node

signal inventory_updated(index: int)

@export var max_slots: int = 10
# Dictionary: item_id → ItemData
@export var items: Dictionary = {}  

# Array of item_ids, -1 means empty slot  
@export var slots: Array[int] = []

func _ready() -> void:
	slots.resize(max_slots)
	for i in range(max_slots):
		slots[i] = -1  # empty

func add_item(item_id: int, item_data: ItemData, index: int = -1) -> bool:
	items[item_id] = item_data
	# Specific slot
	if index != -1:
		if index >= 0 and index < max_slots and slots[index] == -1: # Check if slot is within range, and if the slot is empty
			slots[index] = item_id
			inventory_updated.emit(index)
			print("Added ", item_data.name, " (ID ", item_id, ") to explicit slot ", index)
			return true
		print("Requested slot invalid or full, falling back to auto placement.")
	return false;
	# Non-Def slot
	#for i in range(max_slots):
		#if slots[i] == -1:
			#slots[i] = item_id
			#inventory_updated.emit(i) # return slot equipped to
			#print("Added: ", item_data.name, " (ID ", item_id, ") to slot ", i)
			#return true

func remove_item(slot: int) -> bool:
	if slot < 0 or slot > max_slots:
		return false

	var item_id := slots[slot]
	if item_id == -1:
		return false

	var data : ItemData = items.get(item_id)

	# Remove from slot + dictionary
	slots[slot] = -1
	items.erase(item_id)

	inventory_updated.emit()
	print("Removed ", data.name, " (ID ", item_id, ") from slot ", slot)
	return true
	
func get_item_in_slot(slot: int) -> ItemData:
	if slot < 0 or slot > max_slots:
		return null

	var id := slots[slot]
	if id == -1:
		return null

	return items.get(id)

func get_hotbar_items(count: int = 5) -> Array[int]:
	return slots.slice(0, count)
