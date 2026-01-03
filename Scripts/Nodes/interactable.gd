class_name Interactable
extends Resource


signal interacted(player)
signal started_interacting(player)
signal stopped_interacting(player)

enum InteractableType { PRESS, TAP, HOLD }
@export var interact_type: InteractableType = InteractableType.PRESS

var active: bool = true

var is_interacted: bool = false


func interact(player: PlayerCharacter):
	match interact_type:
		InteractableType.PRESS:
			interacted.emit(player)
		InteractableType.TAP:
			interacted.emit(player)
		InteractableType.HOLD:
			started_interacting.emit(player)
			is_interacted = true


func stop_interacting(player: PlayerCharacter):
	if is_interacted and interact_type == InteractableType.HOLD:
			is_interacted = false
			stopped_interacting.emit(player)
