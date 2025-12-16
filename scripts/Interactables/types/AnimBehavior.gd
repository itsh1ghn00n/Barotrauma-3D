extends InteractionBehavior
class_name AnimBehavior

@export var anim: AnimationPlayer
@export var value: bool = false
@export var anim_1: String = ""
@export var anim_2: String = ""

func execute(player: Node, interactable: Node) -> void:
	value = !value
	
func on_confirm(_player: Node, _interactable: Node) -> void:
	await get_tree().process_frame
	#Wait for sync to update var
	if anim:
		anim.play(anim_1 if value else anim_2)
