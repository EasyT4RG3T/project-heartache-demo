extends Node3D


var vent_opened: bool = false:
	set(value):
		vent_opened = value
		if value:
			%VentArea3D.queue_free()


func _ready() -> void:
	%TempWall/Area3D.body_entered.connect(func(player: PlayerCharacter):
		if player.inventory.flashlight.disabled:
			player.add_thought("I need a flashlight")
		else:
			SaverLoader.auto_save_game_data()
			%TempWall.queue_free())
	
	%VentArea3D.body_entered.connect(func(_p):
		get_parent().vent_open = true
		vent_opened = true)
	
	%VentArea3D2.body_entered.connect(func(_p):
		%VentArea3D2.queue_free()
		AudioManager.play_uid_sound_at("SFX", "uid://dtm7dlm5wj48g", %FootMarker3D.global_position + Vector3(0, 0, -2))
		await get_tree().create_timer(0.2).timeout
		AudioManager.play_uid_sound_at("SFX", "uid://dcucocy3lvfhe", %FootMarker3D.global_position)
		await get_tree().create_timer(0.2).timeout
		AudioManager.play_uid_sound_at("SFX", "uid://bi6suisvx8mj2", %FootMarker3D.global_position + Vector3(0, 0, 2)))


func save() -> Dictionary:
	var file: Dictionary = {
		"vent_opened" = vent_opened,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	vent_opened = file["vent_opened"]
