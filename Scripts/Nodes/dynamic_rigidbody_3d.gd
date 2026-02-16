class_name DynamicRigidBody3D
extends RigidBody3D


@export var ignore_player: bool = false
@export var max_distance: float = 1.6
@export var min_distance: float = 1.0

@export var collision_sound: String = ""


var audio_grace: bool = false

var collisions: Array = []

var picked_up: bool = false

var current_player: PlayerCharacter


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var collision_count = state.get_contact_count()
	var new_collisions: Array = []
	if collision_count > 0:
		for i in range(collision_count):
			new_collisions.append(state.get_contact_collider_id(i))
			if collisions.has(state.get_contact_collider_id(i)):
				continue
			
			if state.get_contact_collider_object(i) is PlayerCharacter:
				if global_position.y < state.get_contact_collider_object(i).global_position.y:
					set_collision_mask_value(4, false)
				else:
					set_collision_mask_value(4, true)
			
			var collision_point = state.get_contact_local_position(i)
			var collision_velocity = state.get_contact_local_velocity_at_position(i)
			if audio_grace and collision_velocity.length() > 2:
				var loudness = clamp(collision_velocity.length() - 32, -30, 0)
				AudioManager.play_uid_sound_at(collision_sound, collision_point, loudness)
	collisions = new_collisions


func _ready() -> void:
	if ignore_player:
		collision_layer = 4
	else:
		collision_layer = 2
	collision_mask = 39
	
	contact_monitor = true
	max_contacts_reported = 1
	
	get_tree().create_timer(0.1).timeout.connect(func(): audio_grace = true)


func switch_pick_up(player: PlayerCharacter) -> void:
	if picked_up:
		put_down(player)
	else:
		pick_up(player)


func pick_up(player: PlayerCharacter) -> void:
	var distance: float = player.main_camera.global_position.distance_to(global_position)
	
	player.phys_wanted_distance = distance
	player.phys_wanted_distance_max = max_distance
	player.phys_wanted_distance_min = min_distance
	player.phys_wanted_rotation = global_basis
	
	player.phys_object = self
	
	angular_damp = 50
	
	picked_up = true
	current_player = player
	
	if !ignore_player:
		collision_layer = 32
		set_collision_mask_value(4, true)


func put_down(player: PlayerCharacter) -> void:
	player.phys_object = null
	
	angular_damp = 0
	
	picked_up = false
	current_player = null
	
	if !ignore_player:
		collision_layer = 2
		set_collision_mask_value(4, false)


func save() -> Dictionary:
	var data: Dictionary = {
		"pos": global_position,
		"rot": global_rotation,
		"mass": mass,
		"ignore_player": ignore_player,
		"max_distance": max_distance,
		"min_distance": min_distance,
		"collision_sound": collision_sound,
	}
	return data


func load_save(data: Dictionary) -> void:
	global_position = data["pos"]
	global_rotation = data["rot"]
	mass = data["mass"]
	ignore_player = data["ignore_player"]
	max_distance = data["max_distance"]
	min_distance = data["min_distance"]
	collision_sound = data["collision_sound"]
