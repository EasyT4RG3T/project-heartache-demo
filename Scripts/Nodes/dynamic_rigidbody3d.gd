class_name DynamicRigidBody3D
extends RigidBody3D


func _init() -> void:
	body_entered.connect(func(body: Node):
		if body is PlayerCharacter:
			if global_position.y < body.global_position.y:
				set_collision_mask_value(4, false)
			else:
				set_collision_mask_value(4, true)
			pass)
	
	body_exited.connect(func(body: Node):
		if body is PlayerCharacter:
			set_collision_mask_value(4, false))
	
	contact_monitor = true
	max_contacts_reported = 1
