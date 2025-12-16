extends ItemAction
class_name LightToggleAction

@export var light_path: NodePath

func use(user: Node, target: Node, item: UsableBehavior) -> void:
	var light = user.get_node_or_null(light_path)
	if light:
		light.visible = !light.visible
	item.item_durability.damage(1)
