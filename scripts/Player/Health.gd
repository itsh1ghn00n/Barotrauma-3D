extends Resource
class_name Health

var current_health: int = 0
var max_health: int = 10

func _init(current_value: int = 0, max_value: int = 20):
	set_current(current_value)
	set_max(max_value)

# Set max durability
func set_max(new : int):
	max_health = new

func set_current(new : int):
	current_health = new

func Damage(amount : int):
	var newcurrent : int = current_health + amount
	if newcurrent <= 0:
		current_health = 0
		Die()
		pass
	else:
		current_health = newcurrent

func Heal(amount : int):
	var newcurrent : int = current_health + amount
	if newcurrent >= max_health:
		current_health = max_health
	else:
		current_health = newcurrent
		
func Die() -> void:
	#implement function
	pass
