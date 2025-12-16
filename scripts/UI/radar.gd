extends Node

const RADAR_GROUPS := {
	"radar_scrap":   "scrap",
	"radar_target": "player",
	"radar_creature": "creature",
	"radar_ruin":   "ruin"
}

@export var sonar_viewport : SubViewport
@export var sonar_rig: Node3D

@export var sonar_cam_offset := Vector3(0, 30, 0)
@export var sonar_cam_pitch := -90.0

@export var submarine :Node3D= null
@export var sweep_speed := 1.2
@onready var radar_mat :Material= $RadarSprite.material

# Radar Targets
var radar_targets : Array = []
@onready var blip_container :Node2D= $"Blip Container"
var blip : Node2D

var radar_radius = 200.0
var radar_yaw := 0.0

var rediscover = 60.0

func _enter_tree():
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)

func _ready():
	# Ensure sonar camera renders the same world
	sonar_viewport.world_3d = get_viewport().world_3d

	# Feed the viewport texture into the radar shader
	radar_mat.set_shader_parameter(
		"sonar_tex",
		sonar_viewport.get_texture()
	)
	
	_discover_targets()

func _process(delta):
	if not submarine or not sonar_rig:
		return

	radar_yaw = -submarine.global_transform.basis.get_euler().y

	# --- Position & rotate sonar camera ---
	sonar_rig.global_position = submarine.global_position + sonar_cam_offset
	sonar_rig.global_rotation = Vector3(
		deg_to_rad(sonar_cam_pitch),
		radar_yaw,
		0.0
	)

	# --- Advance sweep (radar-local space) ---
	var sweep :float= radar_mat.get_shader_parameter("sweep_angle")
	sweep = wrapf(sweep + sweep_speed * delta, 0.0, TAU)
	radar_mat.set_shader_parameter("sweep_angle", sweep)

	# --- Update blips ---
	for i in range(radar_targets.size() - 1, -1, -1):
		var entry :Dictionary= radar_targets[i]
		if is_instance_valid(entry.node):
			_update_blip(entry, delta)
		else:
			entry.blip.queue_free()
			radar_targets.remove_at(i)
			
	
func _on_node_added(node: Node):
	if not (node is Node3D):
		return

	for group_name in RADAR_GROUPS.keys():
		if node.is_in_group(group_name):
			register_target(node, RADAR_GROUPS[group_name])
			return
			
func _on_node_removed(node: Node):
	if not (node is Node3D):
		return

	unregister_target(node)

func world_to_radar(pos_3d: Vector3) -> Vector2:
	# World offset
	var rel := pos_3d - submarine.global_position

	# Flatten to XZ
	var flat := Vector2(rel.x, rel.z)

	# Rotate INTO radar space (inverse of radar yaw)
	var rot := Transform2D(radar_yaw, Vector2.ZERO)
	return rot * flat
	
# Registering / Unregistering Radar Targets
# =========================================
func register_target(target: Node3D, type: String):
	print("Registered: ", target.name, " as: ", type)
	var blip: Node2D = null
	match type:
		"scrap":
			blip = preload("res://scenes/ObjectScenes/ScrapBlip.tscn").instantiate()
		"player":
			blip = preload("res://scenes/ObjectScenes/RadarBlip.tscn").instantiate()
		"creature":
			blip = preload("res://scenes/ObjectScenes/EnemyBlip.tscn").instantiate()
		"ruin":
			blip = preload("res://scenes/ObjectScenes/RuinBlip.tscn").instantiate()
		_:
			return

	blip_container.add_child(blip)
	radar_targets.append({
		"node": target,
		"blip": blip,
		"intensity": 0.0
	})

func unregister_target(target: Node3D):
	for i in range(radar_targets.size()):
		if radar_targets[i]["node"] == target:
			radar_targets[i]["blip"].queue_free()
			radar_targets.remove_at(i)
			return

func _update_blip(entry: Dictionary, delta: float):
	var blip: Node2D = entry.blip
	var world_pos: Vector3 = entry.node.global_position

	var radar_pos := world_to_radar(world_pos)

	# --- Range culling ---
	if radar_pos.length() > radar_radius:
		blip.visible = false
		entry.intensity = 0.0
		return

	blip.position = radar_pos

	# --- Angular comparison ---
	var blip_angle := atan2(radar_pos.y, radar_pos.x)
	if blip_angle < 0.0:
		blip_angle += TAU

	var sweep_angle :float= radar_mat.get_shader_parameter("sweep_angle")
	var diff :float= abs(blip_angle - sweep_angle)
	diff = min(diff, TAU - diff)

	# --- Ping + fade ---
	if diff < 0.04:
		entry.intensity = 1.0

	entry.intensity = max(entry.intensity - delta * 0.2, 0.0)

	blip.visible = entry.intensity > 0.01
	blip.modulate.a = entry.intensity

	
func _discover_targets():
	radar_targets.clear()

	for group_name in RADAR_GROUPS.keys():
		var type :String= RADAR_GROUPS[group_name]

		for node in get_tree().get_nodes_in_group(group_name):
			if node is Node3D:
				register_target(node, type)
