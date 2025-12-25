class_name Interactable
extends StaticBody3D


signal interacted(player)
signal started_interacting(player)
signal stopped_interacting(player)

enum InteractableType { PRESS, TAP, HOLD }
@export var interact_type: InteractableType = InteractableType.PRESS

var active: bool = true


func interact(player: PlayerCharacter):
	match interact_type:
		InteractableType.PRESS:
			interacted.emit(player)
		InteractableType.TAP:
			interacted.emit(player)
		InteractableType.HOLD:
			started_interacting.emit(player)


func stop_interacting(player: PlayerCharacter):
	if interact_type == InteractableType.HOLD:
			stopped_interacting.emit(player)
