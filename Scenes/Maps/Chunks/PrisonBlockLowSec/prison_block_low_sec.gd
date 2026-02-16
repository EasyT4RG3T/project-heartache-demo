extends Node3D


@onready var double_bed_event: OnCenterScreenNotifier3D = %DoubleBedEvent
@onready var cutscenes: Cutscene = %Cutscenes
@onready var look_cutscene: LookCutscene = %LookCutscene


func _ready() -> void:
	double_bed_event.center_entered.connect(func():
		look_cutscene.look(double_bed_event.global_position, 1.0)
		double_bed_event.disabled = true)
	
	await GameManager.PlayerSetUp
	cutscenes.play("WakeUp")
