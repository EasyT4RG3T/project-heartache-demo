extends Node3D


@onready var double_bed_event: OnCenterScreenNotifier3D = %DoubleBedEvent
@onready var cutscenes: Cutscene = %Cutscenes


func _ready() -> void:
	double_bed_event.center_entered.connect(func():
		get_tree().create_timer(1.0).timeout.connect(func():
			Game.character_say(PlayerHUD.Characters.PLAYER, "I never got a cellmate", 3.0))
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


func animation_signal(animation: String) -> void:
	match animation:
		"WakeUp":
			Game.character_say(
				PlayerHUD.Characters.PLAYER,
				"It's that nightmare again.",
				4
			)


func save() -> Dictionary:
	var data: Dictionary = {
		
	}
	
	return data


func load_save(data: Dictionary) -> void:
	pass
