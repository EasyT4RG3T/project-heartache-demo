class_name InteractableStaticBody3D
extends StaticBody3D


signal interacted(player)


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.interacted.connect(func(player):
		interacted.emit(player))
