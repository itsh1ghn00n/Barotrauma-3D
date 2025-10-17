# Console.gd
extends Control

@onready var input_line := $LineEdit
@export var submarine_path: NodePath
var submarine: Node = null

func _ready():
	if submarine_path != null:
		submarine = get_node(submarine_path)
	# Connect the correct signal in Godot 4
	input_line.submitted.connect(_on_command_entered)

func _on_command_entered(text: String):
	if submarine == null:
		print("No submarine assigned")
		return
	match text.to_lower():
		"fill_all":
			submarine.fill_all(5)
		"bail_all":
			submarine.bail_all(5)
		_:
			print("Unknown command:", text)
	input_line.text = ""
