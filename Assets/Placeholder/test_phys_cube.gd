extends DynamicRigidBody3D


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.show_type = Interactable.ShowType.PRESS
	interactable.hold = true
	interactable.interacted.connect(func(player:PlayerCharacter):
		if picked_up:
			put_down(player)
		else:
			_pick_up(player))
	interactable.started_interacting.connect(func(player:PlayerCharacter):
		if picked_up:
			put_down(player)
		else:
			pick_up(player))


func _pick_up(player: PlayerCharacter) -> void:
	player.add_thought("error: pick up to inventory")
