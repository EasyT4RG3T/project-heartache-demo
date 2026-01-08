extends StaticBody3D


@onready var slider_3d: Slider3D = $Slider3D


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.show_type = Interactable.ShowType.HOLD
	interactable.hold = true
	interactable.started_interacting.connect(slider_3d.interact)
	interactable.started_interacting.connect(func(player: PlayerCharacter):
		player.add_thought("Started Holding Button"))
	interactable.stopped_interacting.connect(slider_3d.interact)
	interactable.stopped_interacting.connect(func(player: PlayerCharacter):
		player.add_thought("Stopped Holding Button"))
