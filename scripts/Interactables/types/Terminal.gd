extends Interactable
class_name TerminalInteractable

@onready var console: Console = $TerminalViewport/Console
@export var monitor: MeshInstance3D
var mat: Material
@onready var offpanel: Panel = $TerminalViewport/Console/offpanel
@onready var subviewport: SubViewport = $TerminalViewport
var interacting_player: Node3D = null

var is_open: bool = false

func _ready():
	pass
	#_log("[b]Game Console initialized. Type 'help' for commands.[/b]")

func _process(delta):
	if not interacting_player:
		return
	var dist = global_position.distance_to(interacting_player.global_position)
	if (dist >= 3 && is_open):
		print("Turning off")
		toggle_console()
		interacting_player = null

func toggle_console():
	is_open = !is_open
	console.toggle_console()
	offpanel.visible = !is_open
	if is_open:
		mat.albedo_color = Color.WHITE
	else:
		mat.albedo_color = Color.BLACK

func push_input(event: InputEvent):
	subviewport.push_input(event)

func interact(player: Node) -> void:
	mat = monitor.get_surface_override_material(2)
	toggle_console()
	interacting_player = player
	
	if is_multiplayer_authority():
		player.set_can_move(is_open == false)
	
	if is_open:
		# change albedo of mat to white
		player.current_interactable = self
		console.focus()
	else:
		# change albedo of mat to black
		player.current_interactable = null
		console.unfocus()
