extends Node3D


@onready var double_bed_event: OnCenterScreenNotifier3D = %DoubleBedEvent
@onready var cutscenes: Cutscene = %Cutscenes
@onready var cutscene_node: Node3D = %CutsceneNode


func _ready() -> void:
	double_bed_event.center_entered.connect(func(): print("double_bed_event"))
	await GameManager.PlayerSetUp
	cutscenes.play("WakeUp")
