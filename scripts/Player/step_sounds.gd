extends Node

@export var player : CharacterBody3D
@export var raycast : RayCast3D
@export var audio_player : AudioStreamPlayer3D
@export var metal_sounds : Array[AudioStream] = []
@export var default_sounds : Array[AudioStream] = []

@export var step_distance : float = 2.0

var distance_since_last_step := 0.0

func _physics_process(delta):
	if not player.is_on_floor():
		return

	# Only the local player triggers footstep sounds
	if not player.is_multiplayer_authority():
		return

	# Accumulate distance traveled
	var movement = player.velocity.length() * delta
	distance_since_last_step += movement

	if distance_since_last_step >= step_distance:
		play_footstep()
		distance_since_last_step = 0.0

func play_footstep():
	var surface_type := "default"

	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider and collider.has_meta("surface_type"):
			surface_type = collider.get_meta("surface_type")

	var sound_array : Array
	match surface_type:
		"metal":
			sound_array = metal_sounds
		_:
			sound_array = default_sounds

	if sound_array.size() == 0:
		return

	audio_player.stream = sound_array.pick_random()
	audio_player.play()
