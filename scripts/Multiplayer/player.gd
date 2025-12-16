extends CharacterBody3D
class_name Player

@export_category("Movement Settings")
@export var move_speed := 3.0
@export var swim_speed := 3.0
@export var jump_strength := 5.0
@export var mouse_sensitivity := 0.005
@export var climb_speed := 4.0

@export_group("Debug")
@export var debug_label: Label
@export var debug: bool = false

@onready var camera : Camera3D = $Head/Camera3D
@onready var buoyancy := $Buoyancy
@onready var interactor: Interactor = $Head/Interactor
@onready var inventory: Inventory = $Hotbar/Inventory
@onready var hotbar: Hotbar = $Hotbar

var current_interactable: TerminalInteractable = null

var target_node: CSGShape3D = null

var health: Health

var forward : Vector3
var gravity : float = 0.0
var submerged := false
var can_move := true

var hit_points := []

#Climbing
var climbing := false

var ladder_forward : Vector3
var ladder_normal : Vector3

func _ready() -> void:
	if is_multiplayer_authority():
		health = Health.new(100,100)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.make_current()
	else:
		set_process_input(false)
	pass

func _unhandled_input(event):
	if current_interactable and current_interactable.is_open:
		current_interactable.push_input(event)
		get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	handle_anims(delta)
	if is_multiplayer_authority():
		move(delta)
	move_and_slide()
	#if submerged:
		#buoyancy.apply_buoyancy(self, submerged, delta)

func _process(delta: float) -> void:
	forward = camera.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	if not debug:
		return
	var _a = DebugDraw3D.new_scoped_config().set_thickness(0.01)
	for hit in hit_points:
		var collider: Node3D = hit["collider"]
		var local: Vector3 = hit["local"]
		var normal = hit["normal_local"]
		var world_p = collider.global_transform * local
		var world_n = collider.global_transform.basis * normal
		DebugDraw3D.draw_sphere(world_p, 0.1, Color.RED)
		DebugDraw3D.draw_line(
		world_p,
		world_p + world_n.normalized() * 0.5,
		Color.GREEN
	)
	update_debug()
		
	
func handle_anims(delta : float) -> void:
	
	if !is_on_floor() && submerged:
		$character_template/AnimationPlayer.play("jump") #implement a anim tree for the different directions of swimming
		return
	if !is_on_floor():
		$character_template/AnimationPlayer.play("jump")
		return
	if velocity.length() > 3.0:
		$character_template/AnimationPlayer.play("sprint")
	elif velocity.length() > 0.1:
		$character_template/AnimationPlayer.play("run")
	else:
		$character_template/AnimationPlayer.play("idle")

func set_submerged(value: bool) -> void:
	submerged = value
	
func set_climbing(value: bool) -> void:
	climbing = value
	gravity = 0
	velocity = Vector3.ZERO

func set_can_move(value: bool) -> void:
	print(can_move)
	can_move = value

func handle_movement(delta: float):
	if can_move:
		var input_axis = Input.get_vector("left", "right", "forward", "back")
		var direction = global_transform.basis * Vector3(input_axis.x, 0, input_axis.y)
		direction = direction.normalized()
		
		# Vertical movement if submerged
		if submerged:
			direction.y = Input.get_action_strength("up") - Input.get_action_strength("down")
			velocity = velocity.move_toward(direction * swim_speed, delta * 10)
		else:
			velocity = velocity.move_toward(direction * move_speed, delta * 10)
			# gravity only if not submerged
			if not is_on_floor():
				velocity.y -= 9.8 * delta
		move_and_slide()

func move(delta : float) -> void:
	if !can_move:
		return
	if !is_on_floor() && !submerged && !climbing:
		gravity -= 9.8 * delta
		
	elif gravity < 0.0:
		gravity = 0.0
		
	var input_axis : Vector2 = Input.get_vector("left", "right", "forward", "back")

	var right = camera.global_transform.basis.x
	right.y = 0
	right = right.normalized()

	var direction = (right * input_axis.x + forward * input_axis.y).normalized()
	if Input.is_action_pressed("sprint"):
		direction *= 1.3
	if submerged:
		#var direction = camera.global_transform.basis * Vector3(input_axis.x, 0.0, input_axis.y)
		# Good in this case because camera looking up can affect our movement dir
		direction.y = Input.get_action_strength("jump") - Input.get_action_strength("sprint")
		velocity = velocity.move_toward(direction * swim_speed, delta * 30)
	else:
		velocity = velocity.move_toward(direction * move_speed, delta * 30)
		velocity.y = gravity
			
	if climbing:
		gravity = 0
		var vertical_input := Input.get_action_strength("forward") - Input.get_action_strength("back")
		direction = Vector3(0, vertical_input, 0)
		velocity = Vector3(0, vertical_input * climb_speed, 0)
		if Input.is_action_just_pressed("jump"):
			climbing = false
			gravity = jump_strength
		return
		
func _detect_hit(start : Vector3):
	var space = get_world_3d().direct_space_state
	var cam_forward = -camera.global_transform.basis.z
	var result = space.intersect_ray(
		PhysicsRayQueryParameters3D.create(
			start,
			start + cam_forward * 30
		)
	)
	if result.is_empty():
		return
	var collider = result.collider
	
	print("Hit:", collider.name)
	var hit_position = result.position
	var hit_normal: Vector3 = result.normal
	
	var local_point = collider.global_transform.affine_inverse() * hit_position
	var local_normal = collider.global_transform.basis.inverse() * hit_normal
	hit_points.append({
		"collider": collider,
		"local": local_point,
		"normal_local": local_normal
	})
	#var hit_normal = result.normal
	
	#DebugDraw3D.draw_sphere(hit_position, 0.1, Color.RED)
	#DebugDraw3D.draw_line(hit_position, hit_position + hit_normal * 0.3, Color.GREEN)
	#DebugDraw3D.draw_line(start, start + forward * 30, Color.BLUE)

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
	if Input.is_action_just_pressed("interact"):
		interactor.try_interact(self)
		
	if event.is_action_pressed("drop"):
		hotbar.throw_request()
		
	if event.is_action_pressed("R"):
		var start = camera.global_position 
		#var forward = camera.global_transform.basis.z
		_detect_hit(start)
	if event.is_action_pressed("jump") and is_on_floor():
		gravity = jump_strength
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func update_debug():
	if not is_multiplayer_authority():
		var start = global_transform.origin + Vector3(0,0.5,0)
		var end = start + (-forward)
		DebugDraw3D.draw_line(start, end, Color.GREEN)
		DebugDraw3D.draw_sphere(hotbar.hand_socket.global_position, 0.02, Color.DARK_RED)
		DebugDraw3D.draw_cylinder_ab(global_transform.origin, global_transform.origin + Vector3(0,1,0), 0.259, Color.DARK_BLUE)
		return
	if debug_label:
		debug_label.text = """
Peer: %s
Authority: %s
Facing: %s
Pos: %s
Vel: %s
Submerged: %s
CanMove: %s
""" % [
			multiplayer.get_unique_id(),
			is_multiplayer_authority(),
			forward,
			global_position,
			velocity,
			submerged,
			can_move
		]
