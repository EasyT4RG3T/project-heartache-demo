extends StaticBody3D


var interactable: Interactable = Interactable.new()


func _ready() -> void:
	interactable.interacted.connect(func(player: PlayerCharacter):
		player.add_thought("[F] flashlight")
		player.inventory.flashlight.disabled = false
		queue_free())


func get_interactable() -> Interactable:
	return interactable
