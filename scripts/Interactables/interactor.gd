extends RayCast3D
class_name Interactor

var current_target: Interactable = null
var last_target: Node = null

func _physics_process(_delta: float) -> void:
	if is_colliding():
		var collider = get_collider()
		var target: Node = collider
		
		# Walk up the parent chain until an Interactable is found
		while target and not (target is Interactable):
			target = target.get_parent()
		if target and target is Interactable:
			current_target = target
		else:
			current_target = null
	else:
		current_target = null
		
	# Highlight
	if current_target != last_target:
		# remove highlight
		if last_target and last_target.has_node("BaseItem"):
			last_target.get_node("BaseItem").set_highlighted(false)
		
		# add highlight
		if current_target and current_target.has_node("BaseItem"):
			current_target.get_node("BaseItem").set_highlighted(true)
		
		last_target = current_target

func try_interact(player: Node) -> void:
	if current_target:
		InteractionManager.request_interact.rpc_id(1, player.get_path(), current_target.get_path())
