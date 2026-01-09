extends StaticBody3D


signal pressed
signal depressed


@onready var hinge_3d: Hinge3D = $Hinge3D


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.show_type = Interactable.ShowType.HOLD
	interactable.hold = true
	interactable.started_interacting.connect(hinge_3d.interact)
	interactable.started_interacting.connect(func(player: PlayerCharacter):
		pressed.emit()
		player.add_thought("Started Holding Lever"))
	interactable.stopped_interacting.connect(hinge_3d.interact)
	interactable.stopped_interacting.connect(func(player: PlayerCharacter):
		depressed.emit()
		player.add_thought("Stopped Holding Lever"))
