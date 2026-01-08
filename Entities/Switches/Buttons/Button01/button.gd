extends StaticBody3D


@onready var slider_3d: Slider3D = $Slider3D


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.interacted.connect(slider_3d.interact)
	interactable.interacted.connect(func(player: PlayerCharacter):
		player.add_thought("Pressed Button"))
