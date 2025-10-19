# Hotbar.gd
extends Node3D
class_name Hotbar

@export var hotbar_size: int = 5
var current_index: int = -1
var held_item: Node3D = null
var held_collision: int = 0

@onready var hand_socket := $HandSocket

# Inventory reference (assigned in editor or code)
@onready var inventory := $Inventory
var cam_node: Node3D = null
@onready var main_scene : Node = null

func _ready() -> void:
	main_scene = self
	while main_scene and main_scene.name != "Map":
		main_scene = main_scene.get_parent()
	if inventory:
		inventory.connect("inventory_updated", Callable(self, "_on_inventory_updated"))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var number = event.keycode - KEY_1
		if number >= 0 and number < hotbar_size:
			equip_slot(number)
	if Input.is_action_just_pressed("drop"):
		throw_item()

func _on_inventory_updated(item_data: ItemData) -> void:
	# Automatically equip first available hotbar slot if nothing is held
	if held_item == null:
		for i in range(hotbar_size):
			if inventory.slots[i] != null:
				equip_slot(i)
				return

func equip_slot(index: int) -> void:
	if index == current_index:
		return
	current_index = index

	if held_item:
		unequip_item()

	var item_data = inventory.slots[index]
	if item_data:
		equip_item(item_data)

func equip_item(item_data: ItemData) -> void:
	# Instance the item scene
	held_item = item_data.create_instance()
	if held_item == null:
		return
	
	held_collision = held_item.get_child(0).collision_layer #Store the current items original collision layer settings
	hand_socket.add_child(held_item)
	held_item.get_child(0).freeze = true
	held_item.get_child(0).collision_layer = 0
	held_item.global_transform = hand_socket.global_transform

	# Hold anim no associated anim
	#var anim_player = get_parent().get_node_or_null("AnimationPlayer")
	#if anim_player:
		#anim_player.play("hold_item")

func unequip_item() -> void:
	if held_item:
		held_item.queue_free()
		held_item = null

func drop_item() -> void:
	if held_item:
		var body = held_item.get_child(0)
		body.freeze = false
		body.collision_layer = held_collision
		
		print(main_scene)
		var items_node = main_scene.get_node("Items")
		print(items_node)
		held_item.reparent(items_node)
		
		held_item = null
		current_index = -1
		
func throw_item() -> void:
	if held_item:
		var body = held_item.get_child(0)
		body.freeze = false
		body.collision_layer = held_collision
		
		var items_node = main_scene.get_node("Items")
		held_item.reparent(items_node)
		
		var forward_dir = -cam_node.global_transform.basis.z
		var throw_strength = 5.0
		
		body.apply_central_impulse(forward_dir * throw_strength)
		
		inventory.remove_item(held_item.base_item.item_data)
		
		held_item = null
		current_index = -1
		
