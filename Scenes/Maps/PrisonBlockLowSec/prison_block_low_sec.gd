extends Node3D


@onready var double_bed_event: OnCenterScreenNotifier3D = %DoubleBedEvent
@onready var cutscenes: Cutscene = %Cutscenes


func _ready() -> void:
	double_bed_event.center_entered.connect(func():
		var look_cut: LookCutscene = LookCutscene.new()
		add_child(look_cut)
		look_cut.look(double_bed_event.global_position, 1.0)
		look_cut.animation_finished.connect(func():
			look_cut.queue_free())
		double_bed_event.disabled = true)
	
	GameManager.GameFullyLoaded.connect(func():
		if GameManager.is_new_game:
			cutscenes.play("WakeUp")
			GameManager.is_new_game = false)


func save() -> Dictionary:
	var data: Dictionary = {
	}
	
	return data


func load_save(data: Dictionary) -> void:
	pass
