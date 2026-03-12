class_name InteractableAnimatableBody3D
extends AnimatableBody3D


signal interacted(player)


@export var anim_player: AnimationPlayer


var interactable: Interactable = Interactable.new()
@export var open: bool = false


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.interacted.connect(func(player):
		interacted.emit(player)
		if !open:
			anim_player.play("anim")
			open = true
		else:
			anim_player.play_backwards("anim")
			open = false)
