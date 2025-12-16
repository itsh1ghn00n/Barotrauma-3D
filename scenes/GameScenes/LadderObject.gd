extends InteractionBehavior
class_name LadderBehavior

@export var areaT : Area3D
var can_climb: bool = false
@export var climbing: bool = false

func _ready():
	areaT.body_exited.connect(_on_area_exited)

func execute(_player: Node, _interactable: Node) -> void:
	climbing = !climbing
	_player.set_climbing(climbing)

func _on_area_exited(body):
	if body is Player:
		climbing = false
		body.set_climbing(false)
