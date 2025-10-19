extends Interactable
class_name TerminalInteractable

@onready var menu: Menu = $SubViewport/Terminal/CanvasLayer/Menu
@onready var offpanel: Panel = $SubViewport/Terminal/CanvasLayer/offpanel
var interacting_player: Node3D = null

var is_open: bool = false

func _ready():
	pass
	#input.grab_focus()
	
	#_log("[b]Game Console initialized. Type 'help' for commands.[/b]")

func _process(delta):
	if not interacting_player:
		return
	var dist = global_position.distance_to(interacting_player.global_position)
	#print(dist)
	#print(is_open)
	if (dist >= 3 && is_open):
		print("Turning off")
		toggle_console()
		interacting_player = null

func toggle_console():
	is_open = !is_open
	menu.is_on = is_open
	offpanel.visible = !is_open

func interact(player: Node) -> void:
	toggle_console()
	interacting_player = player
