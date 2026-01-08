extends StaticBody3D


@onready var hinge_3d: Hinge3D = $Hinge3D


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.interacted.connect(hinge_3d.interact)
	hinge_3d.opened_negative.connect(func():
		GameManager.player_character.add_thought("Switched Lever On"))
	hinge_3d.closed.connect(func():
		GameManager.player_character.add_thought("Switched Lever Off"))
