extends Node3D


var bed_monster_happened: bool = false:
	set(value):
		bed_monster_happened = value
		if value:
			%BedMonster.hide()
			%BedMonsterOnScreenNotifier3D.disabled = true

var corridor_monster_ready_2: bool = false:
	set(value):
		corridor_monster_ready_2 = value
		var player = GameManager.player_character
		var last_pos: float = player.global_position.z
		
		if player.look_vector.x < 2.5 and player.look_vector.x > 0:
			player.look_vector.x = 2.5
		if player.look_vector.x > -2.5 and player.look_vector.x < 0:
			player.look_vector.x = -2.5
		
		if player.look_vector.y > 0.5 and player.look_vector.y > 0:
			player.look_vector.y = 0.5
		if player.look_vector.y < -0.5 and player.look_vector.y < 0:
			player.look_vector.y = -0.5
		
		var look_rotation_x = Quaternion(Vector3.UP, player.look_vector.x)
		var look_rotation_y = Quaternion(Vector3.RIGHT, player.look_vector.y)
		
		player.head.quaternion = look_rotation_x * look_rotation_y
		
		while value:
			if player.look_vector.x < 2.5 and player.look_vector.x > 0:
				player.look_vector.x = 2.5
			if player.look_vector.x > -2.5 and player.look_vector.x < 0:
				player.look_vector.x = -2.5
			
			if player.look_vector.y > 0.5 and player.look_vector.y > 0:
				player.look_vector.y = 0.5
			if player.look_vector.y < -0.5 and player.look_vector.y < 0:
				player.look_vector.y = -0.5
			
			if player.global_position.z < last_pos:
				player.global_position.z = last_pos
			
			last_pos = player.global_position.z
			
			await get_tree().process_frame


func _ready() -> void:
	%NoSaveArea3D.body_entered.connect(func(_body):
		SaverLoader.can_save += 1)
	%NoSaveArea3D.body_exited.connect(func(_body):
		SaverLoader.can_save -= 1)
	
	$FakeCells/StaticFakeCell02_2/BedMonsterOnScreenNotifier3D.screen_entered_plus.connect(func():
		get_parent().cell_jumpscare = true
		%BedMonster/AnimationPlayer.play("Hide")
		AudioManager.play_uid_sound("SFX", "uid://bs05hgwl2paw0", -5.0)
		%BedMonster/AnimationPlayer.animation_finished.connect(func(_anim):
			DialogueManager.say("I have to tell them something is wrong", 3)
			Game.story_description = "I have to tell them Michael is gone"
			bed_monster_happened = true))
	
	if randi_range(1, 1000) == 67:
		var egg: StandardMaterial3D = load("uid://d34jsbwlmnipc")
		%CorridorMonster/MeshInstance3D3.set_surface_override_material(0, egg)
	
	%CorridorArea3D.body_entered.connect(func(_body: PlayerCharacter):
		GameManager.player_character.inventory.hand.hide()
		%CorridorMonster/AnimationPlayer.play("Scare")
		%CorridorMonster/AnimationPlayer.animation_finished.connect(func(_anim):
			await get_tree().create_timer(0.2).timeout)
			#_end_demo())
		corridor_monster_ready_2 = true
		await get_tree().create_timer(1).timeout
		AudioManager.play_uid_sound("SFX", "uid://cfj7ljehifjom", -15.0))
	
	%TempWall/Area3D.body_entered.connect(func(player: PlayerCharacter):
		player.add_thought("Not there"))
	
	%CutsceneArea/CollisionShape3D.disabled = true
	%SpecialCellDoor/Hinge3D.failed_to_open.connect(func():
		%CutsceneArea/CollisionShape3D.disabled = false
		Game.story_description = "I have to go there"
		SaverLoader.can_save += 1
		%Cutscene.play_animation("Look")
		DialogueManager.say("This isn't normal", 2)
		await get_tree().create_timer(1).timeout
		DialogueManager.say("I have to check this out", 1))
	
	%CutsceneArea.body_entered.connect(func(_p):
		Game.story_description = "I have to go there"
		%Cutscene.play_animation("Look")
		DialogueManager.say("This isn't normal", 2)
		await get_tree().create_timer(1).timeout
		DialogueManager.say("I have to check this out", 1))
	
	get_parent().security_key_signal.connect(func():
		%TempWall.queue_free())
	
	%CorridorArea3D2.body_entered.connect(func(_p):
		_jumpscare())


func _jumpscare() -> void:
	InputManager.player_character_input = false
	
	var player = GameManager.player_character
	
	player.inventory.hide()
	
	%SkinnyMonster/AnimationPlayer.play("Scare")
	%SkinnyMonster.global_position = player.main_camera.global_position
	%SkinnyMonster.global_rotation = player.main_camera.global_rotation
	
	AudioManager.play_uid_sound("SFX", "uid://b8jorf3nmlhbi", -12.0)
	
	await get_tree().create_timer(1.0).timeout
	SaverLoader.show_loading_screen()
	SaverLoader.progress_message = ""
	get_parent().credits()


func save() -> Dictionary:
	var file: Dictionary = {
		"bed_monster_happened" = bed_monster_happened
	}
	
	return file


func load_save(file: Dictionary) -> void:
	bed_monster_happened = file["bed_monster_happened"]
