extends InteractionBehavior
class_name UsableBehavior

@export var max_durability: int = 10
@export var action: ItemAction
var item_durability: Durability

func _ready():
	item_durability = Durability.new(max_durability, max_durability)

func use(user: Node, target: Node = null):
	if action:
		action.execute(user, target, self)
