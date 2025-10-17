@tool
class_name WaterMaker3D
extends CSGBox3D

@export var water_texture_move_speed := Vector3(0.0025, 0.0025, 0.0025)
@export var water_texture_uv_scale := 0.04
@export var water_color := Color(0.3098039329052, 0.54117649793625, 0.86666667461395, 0.38823530077934)
@export var fog_color := Color(0, 0.04313725605607, 0.15686275064945)
@export var deep_fog_color := Color(0, 0.04313725605607, 0.15686275064945)
@export_range(0.0, 250.0) var fog_fade_dist := 5.0

# Instead of global static (shared across all peers), track per-player states
static var last_frame_drew_underwater_effect : int = -999
var no_water_counter := {}

func _ready():
	process_priority = 999
	add_to_group("WaterMakers")

func is_in_no_water(peer_id: int) -> bool:
	return no_water_counter.get(peer_id, 0) > 0

@rpc("any_peer")
func increase_no_water(peer_id: int):
	no_water_counter[peer_id] = no_water_counter.get(peer_id, 0) + 1

@rpc("any_peer")
func decrease_no_water(peer_id: int):
	no_water_counter[peer_id] = max(0, no_water_counter.get(peer_id, 0) - 1)

# Track the current camera with an area so we can check if it is inside the water
func should_draw_camera_underwater_effect() -> bool:
	var peer_id := multiplayer.get_unique_id()
	if is_in_no_water(peer_id):
		return false

	var camera := get_viewport().get_camera_3d() if get_viewport() else null
	if not camera:
		return false

	var aabb = global_transform * get_aabb().grow(0.025)
	if not aabb.has_point(camera.global_position):
		return false

	if last_frame_drew_underwater_effect == Engine.get_process_frames():
		return false

	%CameraPosShapeCast3D.global_position = camera.global_position
	%CameraPosShapeCast3D.force_shapecast_update()

	for i in %CameraPosShapeCast3D.get_collision_count():
		if %CameraPosShapeCast3D.get_collider(i) == %SwimmableArea3D:
			return true
	return false

func _update_mesh():
	if get_node_or_null("%CollisionShape3D"):
		%CollisionShape3D.shape.size = size

func _process(delta):
	_update_mesh()
	if material is StandardMaterial3D:
		if not Engine.is_editor_hint():
			material.uv1_offset += water_texture_move_speed * delta
		material.uv1_scale = Vector3(water_texture_uv_scale, water_texture_uv_scale, water_texture_uv_scale)
		material.albedo_color = water_color

	%FogVolume.material.set_shader_parameter("deep_color", deep_fog_color)
	%FogVolume.size = size
	%FogVolume.fade_distance = fog_fade_dist

	if not Engine.is_editor_hint():
		if should_draw_camera_underwater_effect():
			%WaterRippleOverlay.visible = true
			%FogVolume.material.set_shader_parameter("edge_fade", 0.1)
			last_frame_drew_underwater_effect = Engine.get_process_frames()
		else:
			%WaterRippleOverlay.visible = false
			%FogVolume.material.set_shader_parameter("edge_fade", 1.1)
