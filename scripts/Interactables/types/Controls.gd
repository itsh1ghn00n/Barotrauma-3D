extends Interactable
class_name Controls

@onready var sit_socket: Node3D = $SitSocket
var player_node: Node = null
@export var submarine: Submarine
var in_use: bool = false

func toggle_use():
	in_use = !in_use
	
func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority() or !in_use:
		return
	if event.is_action_pressed("jump"):
		submarine.modify_all(-10)
		#Set Submarine to bail by 10% | For slow rise
		pass
	if event.is_action_pressed("crouch"):
		submarine.modify_all(10)
		#Set Submarine to fill by 10% | For slow lower
		pass
	#Call functions using user wasd, space, and ctrl inputs

func _process(delta: float) -> void:
	if not in_use:
		return
	
	player_node.global_position = sit_socket.global_position
	var input_axis : Vector2 = Input.get_vector("left", "right", "forward", "back")
	#if forward Access Engine and add throttle till we hit max
	if input_axis.y < 0:
		submarine.adjust_throttle(1, delta) # forward
	#if back access engine and remove throttle till we hit - max
	elif input_axis.y > 0:
		submarine.adjust_throttle(-1, delta) # backward
	#if left access tail rudder and angle left
	if input_axis.x < 0:
		submarine.turn_rudder(1, delta) # left
	#if right access tail rudder and angle right
	elif input_axis.x > 0:
		submarine.turn_rudder(-1, delta)  # right	
		#move the player to the Controls Position

func interact(player: Node) -> void:
	if not is_multiplayer_authority():
		return
	player_node = player
	toggle_use()
	player.set_can_move(!in_use) # while in use cant move
