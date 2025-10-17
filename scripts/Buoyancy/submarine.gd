# Submarine.gd
extends Node3D
class_name Submarine

@onready var compartments := get_tree().get_nodes_in_group("Compartments")
@onready var ballasts := get_tree().get_nodes_in_group("ballasts")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("test"):
		bail_all(100)
	if event.is_action_pressed("test2"):
		add_water_to_compartment(1,100)
		add_water_to_compartment(2,100)
		add_water_to_compartment(3,100)
	if event.is_action_pressed("test3"):
		fill_all(100)
	if event.is_action_pressed("test4"):
		add_water_to_compartment(4,100)
		add_water_to_compartment(5,100)
		get_volume_percentage()

func add_water_to_compartment(index: int, amount: float) -> void:
	if index >= 0 and index < compartments.size():
		compartments[index].add_water(amount)

func remove_water_from_compartment(index: int, amount: float) -> void:
	if index >= 0 and index < compartments.size():
		compartments[index].remove_water(amount)

func fill_all(amount: float) -> void:
	for c in compartments:
		c.add_water(amount)
		print(c.name, " Has been set to:", c.fill_percentage)

func bail_all(amount: float) -> void:
	for c in compartments:
		c.remove_water(amount)
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
