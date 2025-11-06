extends Node3D

@export var rope_anchor: Node3D
@export var cage: RigidBody3D
@export var connection: Node3D
@export var rope: Node3D

@export var min_rope_length: float = 1.0  # shortest (fully raised)
@export var max_rope_length: float = 10.0 # longest (fully dropped)
@export var rope_change_speed: float = 2.0 # meters per second when raising/lowering

var current_rope_length: float = 5.0  # start mid-way

func _ready():
	if not rope_anchor or not cage:
		push_error("Rope anchor or cage not assigned!")
		return
	current_rope_length = clamp(current_rope_length, min_rope_length, max_rope_length)

func _physics_process(delta: float):
	if not cage or not rope_anchor:
		return

	# === Control rope length ===
	if Input.is_action_pressed("ui_left"): # shorten rope (raise cage)
		current_rope_length = max(min_rope_length, current_rope_length - rope_change_speed * delta)
	elif Input.is_action_pressed("ui_right"): # lengthen rope (lower cage)
		current_rope_length = min(max_rope_length, current_rope_length + rope_change_speed * delta)
		
	rope.rope_length = current_rope_length
