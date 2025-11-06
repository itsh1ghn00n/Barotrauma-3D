extends Node
class_name command_manager

# Dictionary: command_name → Callable
static var commands := {}
static var consoles: Array = []

# --- Register consoles ---
static func register_console(console: Console):
	if consoles.has(console):
		return
	consoles.append(console)
	# Give it every command (each console gets its own bound callable)
	for name in commands.keys():
		var factory = commands[name]
		var bound_func = factory.call(console)
		console.register_command(name, bound_func)

	print("[CommandManager] Console registered:", console.name)

static func unregister_console(console: Console):
	consoles.erase(console)

# Registers a new command
static func register_command(name: String, func_ref: Callable):
	if commands.has(name):
		push_warning("Command '%s' already exists." % name)
		return

	commands[name] = func_ref
	print("[CommandManager] Registered command:", name)

	# Send to all consoles (bind per console)
	for console in consoles:
		var bound_func = func_ref.call(console)
		console.register_command(name, bound_func)
	
# Returns all registered command names
static func get_command_list() -> Array:
	return commands.keys()
