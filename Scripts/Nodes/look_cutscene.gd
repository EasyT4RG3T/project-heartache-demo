class_name LookCutscene
extends Node3D


signal animation_started
signal animation_finished


var look_tween: Tween


func look(look_pos: Vector3, speed: float = 1.0, duration: float = 0.0) -> void:
	animation_started.emit()
	SaverLoader.can_save -= 1
	InputManager.player_character_input = false
	global_position = GameManager.player_character.head.global_position
	look_at(look_pos)
	
	if look_tween:
		look_tween.kill()
	
	look_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_ease(Tween.EASE_OUT)
	look_tween.tween_property(GameManager.player_character.head, "global_basis", global_basis, speed)
	look_tween.tween_callback(func():
		if duration > 0.0:
			await get_tree().create_timer(duration).timeout
		var vector: Vector3 = global_basis.get_euler()
		GameManager.player_character.look_vector.x = vector.y
		GameManager.player_character.look_vector.y = vector.x
		InputManager.player_character_input = true
		SaverLoader.can_save += 1
		animation_finished.emit())
