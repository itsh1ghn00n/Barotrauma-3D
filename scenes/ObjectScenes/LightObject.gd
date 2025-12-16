extends Toggleable

@export var light : Node3D

func _ready() -> void:
	light.visible = true if value else false 

func toggle_switch(newval : bool) -> void:
	value = newval
	light.visible = true if value else false 
