@tool
class_name InteractableStaticBody3D
extends StaticBody3D


@export var to_interact: Node:
	set(value):
		if !value.has_method("interact"):
			return
		to_interact = value


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	if to_interact:
		interactable.interacted.connect(to_interact.interact)
