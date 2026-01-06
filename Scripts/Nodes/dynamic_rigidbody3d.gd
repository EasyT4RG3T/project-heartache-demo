class_name DynamicRigidBody3D
extends RigidBody3D


var picked_up: bool = false


func _init() -> void:
	collision_layer = 2
	collision_mask = 35
	
	body_entered.connect(func(body: Node):
		if picked_up: return
		if body is PlayerCharacter:
			if global_position.y < body.global_position.y:
				set_collision_mask_value(4, false)
			else:
				set_collision_mask_value(4, true)
			pass)
	
	body_exited.connect(func(body: Node):
		if picked_up: return
		if body is PlayerCharacter:
			set_collision_mask_value(4, false))
	
	contact_monitor = true
	max_contacts_reported = 1


func switch_pick_up(player: PlayerCharacter) -> void:
	if picked_up:
		put_down(player)
	else:
		pick_up(player)


func pick_up(player: PlayerCharacter) -> void:
	player.phys_wanted_distance = 1.2
	player.phys_wanted_rotation = global_basis
	
	player.phys_object = self
	
	angular_damp = 50
	
	picked_up = true
	collision_layer = 32
	set_collision_mask_value(4, true)


func put_down(player: PlayerCharacter) -> void:
	player.phys_object = null
	
	angular_damp = 0
	
	picked_up = false
	collision_layer = 2
	set_collision_mask_value(4, false)
