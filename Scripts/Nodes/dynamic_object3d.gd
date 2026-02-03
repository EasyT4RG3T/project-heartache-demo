class_name DynamicObject3D
extends DynamicRigidBody3D


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	super()
	interactable.show_type = Interactable.ShowType.PRESS
	interactable.semi_active = true
	interactable.interacted.connect(func(player:PlayerCharacter):
		if picked_up:
			put_down(player)
		else:
			pick_up(player))
