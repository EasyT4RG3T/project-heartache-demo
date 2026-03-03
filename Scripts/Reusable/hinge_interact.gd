extends Node


@onready var hinge_3d: Hinge3D = $".."


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.interacted.connect(hinge_3d.interact)
