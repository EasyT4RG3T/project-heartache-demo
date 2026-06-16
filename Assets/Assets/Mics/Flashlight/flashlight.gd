extends StaticBody3D


var interactable: Interactable = Interactable.new()


func _ready() -> void:
	interactable.interacted.connect(func(player: PlayerCharacter):
		if player.inventory.flashlight.disabled:
			player.add_thought("[F] flashlight")
			player.inventory.flashlight.disabled = false
			queue_free()
		else:
			player.add_thought("I already have one"))


func get_interactable() -> Interactable:
	return interactable
