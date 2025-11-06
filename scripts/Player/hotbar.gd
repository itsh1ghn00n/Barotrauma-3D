# Hotbar.gd
extends Node3D
class_name Hotbar

@export var hotbar_size: int = 5
var current_index: int = -1
var held_item: Node3D = null
var held_collision: int = 0

@export var hand_socket: Node3D

# Inventory reference (assigned in editor or code)
@onready var inventory := $Inventory
@export var cam_node: Node3D = null
@onready var main_scene : Node = null

func _ready() -> void:
	main_scene = self
	while main_scene and main_scene.name != "Map":
		main_scene = main_scene.get_parent()
	if inventory:
		inventory.connect("inventory_updated", Callable(self, "_on_inventory_updated"))

func _unhandled_input(event: InputEvent) -> void:
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		return
		
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

@rpc("any_peer")
func request_equip_slot(index: int) -> void:
	if not multiplayer.is_server():
		return

	rpc("confirm_equip_slot", multiplayer.get_remote_sender_id(), index)
	_apply_equip_slot(index)
	
@rpc("any_peer", "call_local")
func confirm_equip_slot(player_id: int, index: int) -> void:
	if multiplayer.get_unique_id() == player_id:
		_apply_equip_slot(index)
		
func _physics_process(delta: float) -> void:
	if not held_item:
		return

	var body: RigidBody3D = held_item.get_child(0)
	if not body:
		return

	# === Magnet to hand ===
	var target_pos = hand_socket.global_position
	var item_pos = body.global_position

	var to_target = target_pos - item_pos
	var distance = to_target.length()
	if distance < 0.01:
		return # close enough, no need to add force

	to_target = to_target.normalized()

	# --- spring strength constants ---
	var spring_strength = 45.0   # how strongly it's pulled
	var damping = 8.0            # resists velocity (prevents overshoot)

	# spring force = (offset * strength) - (velocity * damping)
	var vel = body.linear_velocity
	var force = (to_target * distance * spring_strength) - (vel * damping)

	body.apply_central_force(force)

	# === Optional rotation alignment ===
	var target_rot = hand_socket.global_transform.basis
	var current_rot = body.global_transform.basis

	var rot_diff = current_rot.get_rotation_quaternion().slerp(
		target_rot.get_rotation_quaternion(), delta * 10.0
	)
	var desired_basis = Basis(rot_diff)

	body.global_transform = Transform3D(desired_basis, body.global_transform.origin)
	# move held item to item slot

func equip_slot(index: int) -> void:
	if multiplayer.is_server():
		_apply_equip_slot(index)
		rpc("confirm_equip_slot", multiplayer.get_unique_id(), index)
	else:
		rpc_id(1, "request_equip_slot", index)
	
func _apply_equip_slot(index: int) -> void:
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
	print("Holding: ", held_item)
	
	hand_socket.add_child(held_item)

func unequip_item() -> void:
	if held_item:
		held_item.queue_free()
		held_item = null
		
func throw_item() -> void:
	if not held_item:
		return
	
	var forward_dir = -cam_node.global_transform.basis.z
	
	if multiplayer.is_server():
		_apply_throw_item(forward_dir)
		rpc("confirm_throw_item", multiplayer.get_unique_id(), forward_dir)
	else:
		rpc_id(1, "request_throw_item", forward_dir)

# request to throw items like the host
@rpc("any_peer")
func request_throw_item(forward_dir: Vector3) -> void:
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	_apply_throw_item(forward_dir)
	rpc("confirm_throw_item", sender_id, forward_dir)

# Apply's throwing the item to the clients	
@rpc("any_peer", "call_local")
func confirm_throw_item(player_id: int, forward_dir: Vector3) -> void:
	_apply_throw_item(forward_dir)

#Throws the item locally
func _apply_throw_item(forward_dir: Vector3) -> void:
	if not held_item:
		return

	var body = held_item.get_child(0)
	if not body:
		return
		
	var items_node = main_scene.get_node("Items")
	held_item.reparent(items_node)

	body.apply_central_impulse(forward_dir * 5.0)

	inventory.remove_item(current_index)
	held_item = null
	current_index = -1
		
