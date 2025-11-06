extends Resource
class_name Durability

var current: int = 0
var max: int = 20

func _init(current_value: int = 0, max_value: int = 20):
	set_current(current_value)
	set_max(max_value)

# Set max durability
func set_max(new : int):
	max = new

func set_current(new : int):
	current = new

func damage(amount : int):
	var newcurrent : int = current + amount
	if newcurrent <= 0:
		current = 0
		break_obj()
		pass
	else:
		current = newcurrent

func fix(amount : int):
	var newcurrent : int = current + amount
	if newcurrent >= max:
		current = max
	else:
		current = newcurrent
		
func break_obj() -> void:
	#implement function
	pass
