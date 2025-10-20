extends Interactable

@export var open_speed: float = 30.0
var is_open: bool = false

func interact(player: Node) -> void:
	is_open = !is_open
	print("Door toggled:", is_open)
	# Later: plway animation / tween rotation
	if (is_open):
		$AnimationPlayer.play("open_door")
	if (!is_open):
		$AnimationPlayer.play("close_door")
