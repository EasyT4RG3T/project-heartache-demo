extends StaticBody3D


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.interacted.connect(func(player: PlayerCharacter):
		if player.inventory.screwdriver.disabled:
			player.inventory.screwdriver.disabled = false
			queue_free()
		else:
			player.add_thought("I already have one"))
