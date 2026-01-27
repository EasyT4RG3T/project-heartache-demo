class_name DynamicRigidBody3D
extends RigidBody3D


const THUMP = preload("uid://tbgl4aqox0xy")


@export var ignore_player: bool = false
@export var default_distance: float = 1.6
@export var max_distance: float = 1.6
@export var min_distance: float = 1.0


var collisions: Array = []

var picked_up: bool = false


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
			AudioManager.play_sound_at(THUMP, collision_point, collision_velocity.length() - 10)
	collisions = new_collisions


func _ready() -> void:
	if ignore_player:
		collision_layer = 4
	else:
		collision_layer = 2
	collision_mask = 39
	
	contact_monitor = true
	max_contacts_reported = 1


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
	
	if !ignore_player:
		collision_layer = 32
		set_collision_mask_value(4, true)


func put_down(player: PlayerCharacter) -> void:
	player.phys_object = null
	
	angular_damp = 0
	
	picked_up = false
	if !ignore_player:
		collision_layer = 2
		set_collision_mask_value(4, false)
