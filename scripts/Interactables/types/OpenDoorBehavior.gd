extends InteractionBehavior
class_name DoorBehavior

@export var anim: AnimationPlayer
@export var is_open: bool = false

func execute(player: Node, interactable: Node):
	is_open = !is_open
	#print("Server toggled door:", is_open)

func on_confirm(player: Node, interactable: Node):
	await get_tree().process_frame #Wait for sync to update var
	#print("Animation Play: ", is_open)
	if anim:
		anim.play("open_door" if is_open else "close_door")
