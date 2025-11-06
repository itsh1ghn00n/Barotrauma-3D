extends Control
class_name Console

@onready var log: RichTextLabel = $Container/OutputLog
@onready var input: LineEdit = $Container/InputLog

var is_open: bool = false
var commands := {}

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
	#$TerminalViewport.size = Vector2(1150, 650) I dont know why this specifically works
	input.connect("text_submitted", Callable(self, "_on_command_entered"))
	init_commands()
	CommandManager.register_console(self)
	
	startup_bootup_sequence()
	#_log("[b]Game Console initialized. Type 'help' for commands.[/b]")

func toggle_console():
	is_open = !is_open

func focus():
	input.grab_focus()

func unfocus():
	input.release_focus()	
	
func _on_command_entered(text: String):
	text = text.strip_edges()
	if text == "":
		return
	
	_log("> " + text)
	_execute_command(text)
	input.text = ""

func register_command(name: String, func_ref: Callable) -> void:
	if commands.has(name):
		push_warning("Command '%s' already exists in console '%s'." % [name, name])
		return
	commands[name] = func_ref

func _execute_command(input_text: String) -> void:
	var args = input_text.split(" ")
	var command = args[0]
	args = args.slice(1, args.size())

	if commands.has(command):
		var func_ref = commands[command]
		# If the command expects console context, pass self
		if func_ref.get_argument_count() == 2:
			func_ref.call(self, args)
		else:
			func_ref.call(args)
	else:
		_log("Unknown command: " + command)

#Initalizing Base Commands
func init_commands():
	CommandManager.register_command("help", func(console):
		return func(args): console._cmd_help(args))
	CommandManager.register_command("clear", func(console):
		return func(args): console._cmd_clear(args))
	CommandManager.register_command("echo", func(console):
		return func(args): console._cmd_echo(args))

# --- Example commands ---
func _cmd_help(args):
	_log("Commands: " + ", ".join(CommandManager.get_command_list()))

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
	
