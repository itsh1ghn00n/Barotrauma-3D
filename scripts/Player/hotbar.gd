extends Node3D
class_name Hotbar

@export var hotbar_size := 5
@export var hand_socket: Node3D
@export var cam_node: Node3D

# ---- Server-authoritative replicated state ----
@export var current_index := -1
@export var held_item_id := -1

@export var held_item: Node3D = null

@export var hotbar_ui: HotbarUI
@onready var inventory : Inventory = $Inventory
@export var syncer: MultiplayerSynchronizer
@onready var main_scene := get_tree().root


# ----------------------------------------------------------------------
# Multiplayer setup
# ----------------------------------------------------------------------
func _enter_tree() -> void:
	syncer.set_multiplayer_authority(1)


func _ready() -> void:
	if not is_multiplayer_authority():
		return
	if inventory:
		inventory.connect("inventory_updated", Callable(self, "_auto_equip"))
	_equip(0)


# ----------------------------------------------------------------------
# Local input (client → server requests)
# ----------------------------------------------------------------------
func _unhandled_input(event: InputEvent) -> void:
	# Only the owning player may issue commands for their own hotbar
	if multiplayer.get_unique_id() != get_multiplayer_authority():
		return

	if event is InputEventKey and event.pressed:
		var i : int = event.keycode - KEY_1
		if i >= 0 and i < hotbar_size:
			_equip_request(i)


# ----------------------------------------------------------------------
# Auto-equip the first available item if empty
# ----------------------------------------------------------------------
func _auto_equip(index : int) -> void:
	#At current_index of hotbar_ui slots, set texture to the indexed items icon
	if held_item == null:
		_equip_request(index)


# ----------------------------------------------------------------------
# Equip logic
# ----------------------------------------------------------------------
func _equip_request(i: int) -> void:
	if multiplayer.is_server():
		_equip(i)
	else:
		rpc_id(1, "_equip", i)


@rpc("authority")
func _equip(i: int) -> void:
	print("Equipping Slot: ", i)
	if i == current_index:
		return
	
	current_index = i
	hotbar_ui.highlight_slot(i)
	_clear_held()
	
	var item_id := inventory.slots[i]
	if item_id == -1:
		held_item_id = -1
		return
		
	held_item_id = item_id
	
	var node : Node3D = ItemAPI.get_item_manager().get_item_node(item_id)
	if node:
		ItemAPI.get_item_node().add_child(node)
		attach(node)
	else:
		# Item node not spawned on this peer yet
		call_deferred("_equip", i)


# ----------------------------------------------------------------------
# Attaching / clearing logic
# (Physics-based grab version)
# ----------------------------------------------------------------------

func attach(n: Node3D) -> void:
	if not n:
		return
	held_item = n

	# Make sure physics is active so the spring works
	var item_info : InventoryAddBehavior = held_item.get_node_or_null("Behaviors/InventoryAddBehavior")
	if held_item is RigidBody3D:
		held_item.global_position = hand_socket.global_position
		held_item.visible = true
		held_item.freeze = false
		held_item.sleeping = false
	if item_info:
		held_item.collision_layer = item_info.item_collision_layer
		var data : ItemData = item_info.get_data()
		if data:
			hotbar_ui.slots[current_index].set_icon(data.icon)
	else: # Doesnt have a InventoryAdd
		held_item_id = 1000 # Pass a generalized id
	# Do NOT parent under hand_socket (physics grab handles the motion)

func _clear_held() -> void:
	if held_item:
		held_item.visible = false
		held_item.freeze = true
		held_item.collision_layer = 0
		hand_socket.add_child(held_item)
	held_item = null
	held_item_id = -1


# ----------------------------------------------------------------------
# Physics-based spring system to pull item toward the hand
# ----------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	if held_item_id < 0:
		held_item = null
		return

	var body := held_item as RigidBody3D
	if not body:
		return

	# Spring toward socket
	var target_pos := hand_socket.global_position
	var item_pos := body.global_position
	var to_target := target_pos - item_pos
	var distance := to_target.length()

	if distance > 0.01:
		to_target = to_target.normalized()
		var spring_strength := 45.0
		var damping := 8.0
		var vel := body.linear_velocity
		var force := (to_target * distance * spring_strength) - (vel * damping)
		body.apply_central_force(force)

	# Rotate gradually toward socket rotation
	var target_rot := hand_socket.global_transform.basis
	var current_rot := body.global_transform.basis
	var rot_q := current_rot.get_rotation_quaternion().slerp(
		target_rot.get_rotation_quaternion(), delta * 10.0
	)
	body.global_transform = Transform3D(Basis(rot_q), body.global_transform.origin)


# ----------------------------------------------------------------------
# Throw logic
# ----------------------------------------------------------------------
func throw_request() -> void:
	if held_item_id < 0:
		return

	var dir := -cam_node.global_transform.basis.z
	var owner_id := multiplayer.get_unique_id()
	print("Owner Id: ", owner_id)
	
	print("Held Item Id: ", held_item_id)

	if multiplayer.is_server():
		_throw(held_item_id, dir, owner_id)
	else:
		rpc_id(1, "_throw", held_item_id, dir, owner_id)


@rpc("authority", "call_local")
func _throw(item_id: int, dir: Vector3, owner_id: int) -> void:
	var node : Node3D = ItemAPI.get_item_manager().get_item_node(item_id)
	var items_root := main_scene.get_node("Items")
	if node:
		var body := node as RigidBody3D
		if not body:
			return
		hotbar_ui.slots[current_index].remove_icon()
		inventory.remove_item(current_index)
	held_item.reparent(items_root)
	held_item.apply_central_impulse(dir * 5.0)

	held_item = null
	held_item_id = -1
