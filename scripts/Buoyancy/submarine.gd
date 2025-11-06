# Submarine.gd
extends Node3D
class_name Submarine

@onready var compartments := get_tree().get_nodes_in_group("Compartments")
@onready var ballasts := get_tree().get_nodes_in_group("ballasts")
@onready var buoyancy := $RigidBody3D

#Throttle
#--------------------------------------
@export var max_throttle: float = 10.0
@export var throttle_accel: float = 0.5 # how fast throttle changes per second

var current_throttle: float = 0.0
#--------------------------------------

#Rudder
#--------------------------------------
@export var max_turn_angle: float = 40.0
@export var rudder_turn_speed: float = 20.0   # degrees per second

var current_turn: float = 0.0
#--------------------------------------

@export var move_speed: float = 2.0  # base speed multiplier

func _ready() -> void:
	init_commands()

func _input(event: InputEvent) -> void:
	pass
	#if event.is_action_pressed("test"):
		#bail_all(100)
	#if event.is_action_pressed("test2"):
		#add_water_to_compartment(1,100)
		#add_water_to_compartment(2,100)
		#add_water_to_compartment(3,100)
	#if event.is_action_pressed("test3"):
		#fill_all(100)
	#if event.is_action_pressed("test4"):
		#add_water_to_compartment(4,100)
		#add_water_to_compartment(5,100)
		#get_volume_percentage()
		

func _physics_process(delta: float) -> void:
	# Apply movement based on current throttle
	var forward_dir = global_transform.basis.x.normalized()
	global_position += forward_dir * current_throttle * move_speed * delta
	
	if abs(current_turn) > 0.1:
		rotate_y(deg_to_rad(current_turn) * 0.1 * delta)

func init_commands():
	CommandManager.register_command("sub.modify", func(console):
		return func(args): _cmd_modify_ballasts(console, args))
	CommandManager.register_command("sub.status", func(console):
		return func(args): _cmd_sub_status(console, args))
	CommandManager.register_command("sub.depth", func(console):
		return func(args): _cmd_sub_depth(console, args))
		
# Registered Commands
# -------------------------------------------------------------

func _cmd_modify_ballasts(console, args):
	var percent := float(args[0]) if args.size() > 0 else 100.0
	modify_all(percent)
	console._log("[Submarine] Ballasts filled to %.1f%%" % percent)

func _cmd_sub_status(console, args):
	var total_vol = 0.0
	var working_percent = 0.0
	for c in compartments:
		total_vol += c.max_volume
		working_percent += c.fill_percentage
	var total_perc = (working_percent * 100.0 / compartments.size())
	console._log("[Submarine] Volume: %.1f | Fill: %.1f%%" % [total_vol, total_perc])
	
func _cmd_sub_depth(console, args):
	console._log("[Submarine] Depth: %.1f" %buoyancy.return_depth())
	
# -------------------------------------------------------------

func adjust_throttle(direction: int, delta: float) -> void:
	# direction = 1 for forward, -1 for reverse, 0 for no input
	if direction != 0:
		current_throttle += direction * throttle_accel * delta
	# Clamp between -max_throttle and +max_throttle
	current_throttle = clamp(current_throttle, -max_throttle, max_throttle)

func turn_rudder(direction: int, delta: float) -> void:
	if direction != 0:
		current_turn += direction * rudder_turn_speed * delta
	else:
		# Smoothly center when no input
		if abs(current_turn) > 0.5:
			current_turn -= sign(current_turn) * rudder_turn_speed * delta
		else:
			current_turn = 0.0
	
	current_turn = clamp(current_turn, -max_turn_angle, max_turn_angle)
		

func modify_water_to_compartment(index: int, amount: float) -> void:
	if index >= 0 and index < compartments.size():
		compartments[index].modify_water(amount)

#Modify's the water fill on each compartment + or -
func modify_all(amount: float) -> void:
	for c in compartments:
		c.modify_water(amount)
		print(c.name, " Has been set to:", c.fill_percentage)

func set_auto_fill(index: int, rate: float) -> void:
	if index >= 0 and index < compartments.size():
		compartments[index].auto_fill_rate = rate

func set_auto_drain(index: int, rate: float) -> void:
	if index >= 0 and index < compartments.size():
		compartments[index].auto_drain_rate = rate

func get_volume_percentage() -> void:
	var total_vol = 0.0
	var working_percent = 0.0
	for c in compartments:
		total_vol += c.max_volume 
		working_percent += c.fill_percentage
	var total_perc = (working_percent * 100 / 6)
	print("Total Vol: ",total_vol, "Total %: ", total_perc)
