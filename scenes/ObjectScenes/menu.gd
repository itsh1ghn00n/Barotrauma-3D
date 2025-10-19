extends RichTextLabel
class_name Menu

var menu_items := ["New Game", "Join Game", "Settings", "Credits"]
var selected_index := 0
var is_on: bool = false

func _ready():
	draw_menu()

func _process(delta):
	if (is_on):
		# Arrow key navigation
		if Input.is_action_just_pressed("ui_down"):
			selected_index = (selected_index + 1) % menu_items.size()
			draw_menu()
		elif Input.is_action_just_pressed("ui_up"):
			selected_index = (selected_index - 1 + menu_items.size()) % menu_items.size()
			draw_menu()
		elif Input.is_action_just_pressed("ui_accept"):
			_select_item(selected_index)

func draw_menu():
	self.clear()
	for i in range(menu_items.size()):
		if i == selected_index:
			_log("[bgcolor=orangered][color=black]> " + menu_items[i] + "[/color][/bgcolor]\n")
		else:
			_log("  " + menu_items[i] + "\n")

func _select_item(index):
	match index:
		0:
			_log("Starting New Game...")
		1:
			_log("Joining Game...")
		2:
			_log("Opening Settings...")
		3:
			_log("Showing Credits...")

func toggle_on():
	is_on = !is_on

# Optional: log helper for messages outside menu
func _log(text: String):
	self.append_text(text + "\n")
