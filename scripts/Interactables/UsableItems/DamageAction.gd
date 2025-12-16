extends ItemAction
class_name DamageAction

@export var dmg_amount: int = 25

func use(user: Node, target: Node, item: UsableBehavior) -> void:
	if target is Player && target.health.has_method("Damage"):
		target.health.Damage(dmg_amount)
	item.item_durability.damage(1)
