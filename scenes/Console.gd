extends Interactable
class_name Console

@onready var log: RichTextLabel = $CanvasLayer/Container/OutputLog
@onready var input: LineEdit = $CanvasLayer/Container/InputLog

var is_open: bool = true
var commands := {}

var caret_timer := 0.0
var caret_visible := true

var startup_sequence := [
""" 
              ⡆⣿⣿⣦⠹⣳⣳⣕⢅⠈⢗⢕⢕⢕⢕⢕⢈⢆⠟⠋⠉⠁⠉⠉⠁⠈⠼⢐⢕      rom@de
              ⡗⢰⣶⣶⣦⣝⢝⢕⢕⠅⡆⢕⢕⢕⢕⢕⣴⠏⣠⡶⠛⡉⡉⡛⢶⣦⡀⠐⣕
              ⡝⡄⢻⢟⣿⣿⣷⣕⣕⣅⣿⣔⣕⣵⣵⣿⣿⢠⣿⢠⣮⡈⣌⠨⠅⠹⣷⡀⢱
              ⡝⡵⠟⠈⢀⣀⣀⡀⠉⢿⣿⣿⣿⣿⣿⣿⣿⣼⣿⢈⡋⠴⢿⡟⣡⡇⣿⡇⡀
              ⡝⠁⣠⣾⠟⡉⡉⡉⠻⣦⣻⣿⣿⣿⣿⣿⣿⣿⣿⣧⠸⣿⣦⣥⣿⡇⡿⣰⢗
              ⠁⢰⣿⡏⣴⣌⠈⣌⠡⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣬⣉⣉⣁⣄⢖⢕⢕
              ⡀⢻⣿⡇⢙⠁⠴⢿⡟⣡⡆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣵⣵
              ⡻⣄⣻⣿⣌⠘⢿⣷⣥⣿⠇⣿⣿⣿⣿⣿⣿⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
              ⣷⢄⠻⣿⣟⠿⠦⠍⠉⣡⣾⣿⣿⣿⣿⣿⣿⢸⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿
              ⡕⡑⣑⣈⣻⢗⢟⢞⢝⣻⣿⣿⣿⣿⣿⣿⣿⠸⣿⠿⠃⣿⣿⣿⣿⣿⣿⡿⠁
""",
]

func startup_bootup_sequence() -> void:
	for block in startup_sequence:
		var lines = block.split("\n")
		for line in lines:
			_log(line)
			await get_tree().create_timer(randf_range(0.25,0.7)).timeout

func _ready():
	input.grab_focus()
	input.caret_blink = false
	input.connect("text_submitted", Callable(self, "_on_command_entered"))
	
	init_commands()
	
	startup_bootup_sequence()
	#_log("[b]Game Console initialized. Type 'help' for commands.[/b]")

func toggle_console():
	is_open = !is_open
	visible = is_open
	if is_open:
		input.grab_focus()

func _on_command_entered(text: String):
	text = text.strip_edges()
	if text == "":
		return
	
	_log("> " + text)
	_execute_command(text)
	input.text = ""

func _execute_command(input_text: String):
	var args = input_text.split(" ")
	var command = args[0]
	args = args.slice(1, args.size())

	if commands.has(command):
		commands[command].call(args)
	else:
		_log("Unknown command: " + command)

# --- Command registration system ---
func register_command(name: String, func_ref: Callable):
	commands[name] = func_ref

func init_commands():
	register_command("help", _cmd_help)
	register_command("clear", _cmd_clear)
	register_command("echo", _cmd_echo)

# --- Example commands ---
func _cmd_help(args):
	_log("Commands: " + ", ".join(commands.keys()))

func _cmd_clear(args):
	log.clear()

func _cmd_echo(args):
	if args.size() == 0:
		_log("Usage: echo <text>")
		return
	_log(" ".join(args))

# --- Output ---
func _log(text: String):
	log.append_text(text + "\n")
	log.scroll_to_line(log.get_line_count())
