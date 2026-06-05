extends Node3D


@onready var interactable_static_body_3d: InteractableStaticBody3D = $Hinge3D/InteractableStaticBody3D
@onready var hinge_3d: Hinge3D = $Hinge3D


func _ready() -> void:
	interactable_static_body_3d.interacted.connect(func(p: PlayerCharacter):
		hinge_3d.interact(p))
