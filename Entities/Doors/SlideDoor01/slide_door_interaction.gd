extends StaticBody3D


@onready var slide_door_01: StaticBody3D = $"../../.."


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.interacted.connect(slide_door_01.interact)
