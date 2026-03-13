class_name InteractableStaticBody3D
extends StaticBody3D


signal interacted(player)
signal started_interacting(player)
signal stopped_interacting(player)

@export var show_type: Interactable.ShowType = Interactable.ShowType.PRESS
@export var hold_time: float = 0.2

var active: bool = true:
	set(value):
		active = value
		interactable.active = value

var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.show_type = show_type
	interactable.hold_time = hold_time
	interactable.interacted.connect(func(player):
		interacted.emit(player))
	interactable.started_interacting.connect(func(player):
		started_interacting.emit(player))
	interactable.stopped_interacting.connect(func(player):
		stopped_interacting.emit(player))
