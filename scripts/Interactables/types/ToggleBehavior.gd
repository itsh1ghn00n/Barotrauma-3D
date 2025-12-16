extends InteractionBehavior
class_name ToggleBehavior

@export var toggle_targets : Array[Toggleable] = []
@export var toggle: bool = false

func execute(player: Node, interactable: Node) -> void:
	toggle = !toggle
	
func on_confirm(_player: Node, _interactable: Node) -> void:
	await get_tree().process_frame
	
	for target in toggle_targets:
		target.toggle_switch(toggle)
	
