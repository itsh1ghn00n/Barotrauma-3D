extends InteractionBehavior
class_name ControlBehavior

@export var sit_socket: Node3D
@export var player_id: int
var player_node : Node
@export var submarine: Submarine
@export var in_use: bool = false
var new_depth

func _ready() -> void:
	new_depth = submarine.buoyancy.return_desired_depth()

func toggle_use():
	in_use = !in_use

func _process(delta: float) -> void:
	if !is_multiplayer_authority() or !in_use:
		return
	if Input.is_action_pressed("jump"): #Holding Jump
		new_depth -= 3 * delta
	if Input.is_action_pressed("crouch"): #Holding Ctrl
		new_depth += 3 * delta
		
	submarine.buoyancy.set_desired_depth(new_depth)
	
	player_node.global_position = sit_socket.global_position
	var input_axis : Vector2 = Input.get_vector("left", "right", "forward", "back")
	#if forward Access Engine and add throttle till we hit max
	if input_axis.y < 0:
		submarine.adjust_throttle(1, delta) # forward
	#if back access engine and remove throttle till we hit - max
	elif input_axis.y > 0:
		submarine.adjust_throttle(-1, delta) # backward
	else:
		submarine.adjust_throttle(0, delta)
	#if left access tail rudder and angle left
	if input_axis.x < 0:
		submarine.turn_rudder(1, delta) # left
	#if right access tail rudder and angle right
	elif input_axis.x > 0:
		submarine.turn_rudder(-1, delta)  # right
	else:
		submarine.turn_rudder(0, delta)

func execute(player: Node, interactable: Node) -> void:
	player_id = player.multiplayer.get_unique_id()
	if multiplayer.is_server():
		player_node = player
		print("Player Node: ", player_node, "Player: ", player)
		toggle_use()
		player.set_can_move(!in_use) # while in use cant move
	else:
		pass
		#player_node = multiplayer.get_node(player_id)
