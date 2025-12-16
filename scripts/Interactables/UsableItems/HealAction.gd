extends ItemAction
class_name HealAction

@export var heal_amount: int = 25

func use(user: Node, target: Node, item: UsableBehavior) -> void:
	if target.health.has_method("Heal"):
		target.health.Heal(heal_amount)
	item.item_durability.damage(1)
