extends Node3D


@onready var interactable_static_body_3d: InteractableStaticBody3D = %InteractableStaticBody3D
@onready var hinge_3d: Hinge3D = %Hinge3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	interactable_static_body_3d.interacted.connect(func(player: PlayerCharacter):
		hinge_3d.interact(player)
		if hinge_3d.locked:
			animation_player.play("Handle(Locked)")
		else:
			animation_player.play("Handle"))
