extends Node3D
class_name ScrapperMachine

@export var _anim_player: AnimationPlayer
@export var scrap_zone: Area3D
@export var output: Node3D #Where we spawn our fuel if we dont have one
@export var fuelcell_data: ItemData #Prefab to spawn

var fuel_max: float = 1.5 # the number of scrap to fill a tank of fuel
var current_scrap: float = 0

var currentPrefab: Node3D
var fuel_script : FuelTank

func _ready() -> void:
	if not _anim_player:
		return
	_anim_player.play("scrap")
	scrap_zone.body_entered.connect(_scrap_entered)

func _process(delta: float) -> void:
	if not currentPrefab && current_scrap != 0.0:
		_spawn_prefab()
	if currentPrefab:
		# Update fuel amount
		fuel_script.set_fuel(current_scrap)

func _scrap_entered(body: Node) -> void:
	if (body.collision_layer & (1 << 3)) == 0:
		return
	current_scrap += 1
	await get_tree().process_frame # Wait until _spawn_prefab goes off
	body.queue_free()
	
	if currentPrefab:
		fuel_script.set_fuel(current_scrap)

	# Check if we filled it
	if current_scrap >= fuel_max:
		currentPrefab.freeze = false
		fuel_script.set_max()
		var force = Vector3(0,3,-4)
		currentPrefab.apply_central_impulse(force)
		currentPrefab = null
		fuel_script = null
		current_scrap -= fuel_max
		#_spawn_prefab()

func _spawn_prefab() -> void:
	if currentPrefab:
		return
	var itemManager = ItemAPI.get_item_manager()
	var item_id = itemManager.spawn_item(output.position, fuelcell_data)
	currentPrefab = itemManager.get_item_node(item_id)
	currentPrefab.rotation_degrees = Vector3(-90, 0, 0)
		
	if currentPrefab is RigidBody3D:
		currentPrefab.freeze = true
	fuel_script = currentPrefab.get_node("Mesh/Fuel") as FuelTank
	fuel_script.set_fuel(current_scrap)
