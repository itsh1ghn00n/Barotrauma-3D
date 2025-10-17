extends CharacterBody3D
class_name Player
@export var mouse_sensitivity := 0.005
@export var move_speed := 3.0
@export var swim_speed := 3.0
@export var jump_strength := 5.0
@onready var camera : Camera3D = $Head/Camera3D
@onready var buoyancy := $Buoyancy
@onready var interactor: Interactor = $Head/Interactor
@onready var inventory: Inventory = $Hotbar/Inventory
@onready var hotbar: Hotbar = $Hotbar

var gravity : float = 0.0
var submerged := false
func _ready() -> void:
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.make_current()
		hotbar.cam_node = camera
	else:
		set_process_input(false)
	pass
	print("Inventory found: ", inventory)

func _physics_process(delta: float) -> void:
	handle_anims(delta)
	if is_multiplayer_authority():
		move(delta)
	move_and_slide()
	#if submerged:
		#buoyancy.apply_buoyancy(self, submerged, delta)
	
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

func handle_movement(delta: float):
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
	if !is_on_floor() && !submerged:
		gravity -= 9.8 * delta
	elif gravity < 0.0:
		gravity = 0.0
	
	var input_axis : Vector2 = Input.get_vector("left", "right", "forward", "back")
	var direction = camera.global_transform.basis * Vector3(input_axis.x, 0.0, input_axis.y)
	direction = direction.normalized()
	if Input.is_action_pressed("sprint"):
		direction *= 1.3
	if submerged:
		direction.y = Input.get_action_strength("jump") - Input.get_action_strength("sprint")
		velocity = velocity.move_toward(direction * swim_speed, delta * 30)
	else:
		velocity = velocity.move_toward(direction * move_speed, delta * 30)
		velocity.y = gravity
	
func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority():
		return
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
	if Input.is_action_just_pressed("interact"):
		interactor.try_interact(self)
	#if event.is_action_pressed("test"):
		#submerged = !submerged
	if event.is_action_pressed("jump") and is_on_floor():
		gravity = jump_strength
	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseButton and event.pressed:
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
