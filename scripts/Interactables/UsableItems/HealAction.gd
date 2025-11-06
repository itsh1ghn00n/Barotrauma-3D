extends ItemAction
class_name HealAction

@export var heal_amount: int = 25

func execute(user: Node, target: Node, item: UsableItem) -> void:
	if target.health.has_method("Heal"):
		target.health.Heal(heal_amount)
	item.item_durability.damage(1)
