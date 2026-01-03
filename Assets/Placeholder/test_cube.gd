extends StaticBody3D


var interactable: Interactable = Interactable.new()


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.show_type = Interactable.ShowType.PRESS
	interactable.hold = true
	interactable.interacted.connect(_test1)
	interactable.started_interacting.connect(_test2)
	interactable.stopped_interacting.connect(_test3)


func _test1(player: PlayerCharacter) -> void:
	player.add_thought("interacted", false, 1.0)


func _test2(player: PlayerCharacter) -> void:
	player.add_thought("started_interacting", false, 1.0)


func _test3(player: PlayerCharacter) -> void:
	player.add_thought("stopped_interacting", false, 1.0)
