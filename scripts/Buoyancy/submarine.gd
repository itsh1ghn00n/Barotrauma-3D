# Submarine.gd
extends Node3D
class_name Submarine

@onready var compartments: Array[Node] = []
@onready var ballasts := get_tree().get_nodes_in_group("ballasts")
@export var buoyancy: Buoyancy

@export var physics_body_path: NodePath
var physics_body: RigidBody3D

@export var engine_pos: Node3D

var selected_compartment := 0

var target_position: Vector3 = Vector3(3,-10,0)
#Throttle
@export var max_throttle: float = 10.0
@export var throttle_accel: float = 0.5 # how fast throttle changes per second

@export var current_throttle: float = 0.0

#Rudder
@export var max_turn_angle: float = 40.0
@export var rudder_turn_speed: float = 20.0   # degrees per second

@export var current_turn: float = 0.0

@export var move_speed: float = 2.0  # base speed multiplier

func _ready() -> void:
	init_commands()
	physics_body = get_node(physics_body_path) as RigidBody3D
	
func _input(event):
	if event.is_action_pressed("comp_next"):
		selected_compartment = (selected_compartment + 1) % compartments.size()
		print("[Compartment] Selected:", compartments[selected_compartment].name)

	if event.is_action_pressed("comp_prev"):
		selected_compartment = (selected_compartment - 1 + compartments.size()) % compartments.size()
		print("[Compartment] Selected:", compartments[selected_compartment].name)

	# Increase water
	#if event.is_action_pressed("comp_increase"):
		#var new_depth = buoyancy.return_water_height() + 10.0
		#buoyancy.set_water_h(new_depth)
		#print("Submarine depth increased: ", new_depth)
		#compartments[selected_compartment].modify_water(+0.5)
		#print("[Compartment] Added 0.5 m³ to", compartments[selected_compartment].name)

	# Decrease water
	#if event.is_action_pressed("comp_decrease"):
		#var new_depth = buoyancy.return_water_height() - 10.0
		#buoyancy.set_water_h(new_depth)
		#print("Submarine depth decreased: ", new_depth)
		#compartments[selected_compartment].modify_water(-0.5)
		#print("[Compartment] Removed 0.5 m³ from", compartments[selected_compartment].name)

	# Flood instantly
	if event.is_action_pressed("comp_flood"):
		compartments[selected_compartment].set_fill_percentage(1.0)
		print("[Compartment] Flooded", compartments[selected_compartment].name)

	# Drain instantly
	if event.is_action_pressed("comp_drain"):
		compartments[selected_compartment].set_fill_percentage(0.0)
		print("[Compartment] Drained", compartments[selected_compartment].name)

	# Raise water height
	if event.is_action_pressed("water_raise") and buoyancy:
		buoyancy.water_height += 1.0
		print("[Water] Height:", buoyancy.water_height)

	# Lower water height
	if event.is_action_pressed("water_lower") and buoyancy:
		buoyancy.water_height -= 1.0
		print("[Water] Height:", buoyancy.water_height)


func _physics_process(delta: float) -> void:
	if not physics_body:
		return
	
	if (buoyancy.compartments.size() > compartments.size()):
		compartments = buoyancy.compartments
		#move_to_target(target_position, delta)
		
	var _a = DebugDraw3D.new_scoped_config().set_thickness(0.01)
	var forward_dir = -physics_body.global_transform.basis.x # No y movement
	
	#DebugDraw3D.draw_line(global_transform.origin, global_transform.origin+ forward_dir, Color.GREEN)
	
	global_transform = physics_body.global_transform
	
	var force = forward_dir * current_throttle * move_speed * 10
	physics_body.apply_central_force(force)
	
	if abs(current_turn) > 0.1:
		var torque = Vector3(0, current_turn * rudder_turn_speed * 10, 0)  # Adjust strength
		physics_body.apply_torque(torque)
		
	current_throttle -= sign(current_throttle) * throttle_accel * delta
	current_turn -= sign(current_turn) * rudder_turn_speed * delta

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
	else:
		# Smoothly center when no input
		if abs(current_throttle) > 0.5:
			current_throttle -= sign(current_throttle) * throttle_accel * delta
		else:
			current_throttle = 0.0
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
	
func set_target_depth(depth: float) -> void:
	if buoyancy:
		buoyancy.set_desired_depth(depth)
