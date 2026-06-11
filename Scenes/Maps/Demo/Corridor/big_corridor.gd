extends Node3D


var sitting_man_happened: bool = false


func _ready() -> void:
	%DefaultPrisoner/AnimationPlayer.play("Sit1")
	%DefaultPrisoner/AnimationPlayer.animation_finished.connect(func(anim):
		%DefaultPrisoner/AnimationPlayer.play(anim))
	%DefaultPrisoner/HeadLookIK.global_position = Vector3(-9.503, 0.9, -0.1)
	var area = %DefaultPrisoner/Area3D
	area.body_entered.connect(func(player: PlayerCharacter):
		if !sitting_man_happened:
			DialogueManager.say("[{belanidi}][font_size=30]You took your sweet time[/font_size][/font]", 3)
			sitting_man_happened = true
		while area.has_overlapping_bodies():
			%DefaultPrisoner/HeadLookIK.global_position = lerp(%DefaultPrisoner/HeadLookIK.global_position, player.main_camera.global_position, get_physics_process_delta_time() * 10)
			await get_tree().physics_frame
		while !%DefaultPrisoner/HeadLookIK.global_position.is_equal_approx(Vector3(-9.503, 0.9, -0.1)):
			%DefaultPrisoner/HeadLookIK.global_position = lerp(%DefaultPrisoner/HeadLookIK.global_position, Vector3(-9.503, 0.9, -0.1), get_physics_process_delta_time() * 10)
			await get_tree().physics_frame)
	%TempWall/Area3D.body_entered.connect(func(player: PlayerCharacter):
		player.add_thought("Not this way"))


func faze1() -> void:
	%TempWall.queue_free()


func save() -> Dictionary:
	var file: Dictionary = {
		"sitting_man_happened" = sitting_man_happened
	}
	
	return file


func load_save(file: Dictionary) -> void:
	sitting_man_happened = file["sitting_man_happened"]
