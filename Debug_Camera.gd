extends Camera3D

@export var mouse_sensitivity := 0.25
@export var camera_speed := 10.0
@export var camera_speed_fast := 30.0

func _ready():
	pass
	
func _input(event) -> void:
	pass
	
func _process(delta: float) -> void:
	var input_axis : Vector2 = Input.get_vector("left", "right", "forward", "back")
	
	#var motion :=
	pass
