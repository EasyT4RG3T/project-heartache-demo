extends Node3D


signal activated


@onready var hinge_3d: Hinge3D = $Hinge3D


var interactable: Interactable = Interactable.new()
var active: bool = false


func get_interactable() -> Interactable:
	return interactable


func _ready() -> void:
	interactable.show_type = Interactable.ShowType.TAP
	interactable.interacted.connect(_interact)


func _physics_process(delta: float) -> void:
	if active: return
	if hinge_3d.open_progress < 0:
		hinge_3d.open_progress += delta * 10
		if hinge_3d.open_progress > 0:
			hinge_3d.open_progress = 0


func _interact(player: PlayerCharacter) -> void:
	hinge_3d.open_progress -= hinge_3d.max_negative * 0.1
	if hinge_3d.open_progress <= -hinge_3d.max_negative:
		hinge_3d.open_progress = -hinge_3d.max_negative
		interactable.active = false
		active = true
		activated.emit()
		player.add_thought("Activated Broken Lever")
		player.interaction_ray_result = {}


func reset() -> void:
	hinge_3d.open_progress = 0
	interactable.active = true
	active = false
