extends Node3D


var bed_monster_happened: bool = false:
	set(value):
		bed_monster_happened = value
		if value:
			%BedMonster.hide()
			%BedMonsterOnScreenNotifier3D.disabled = true
var corridor_monster_ready: bool = false
var corridor_monster_ready_2: bool = false:
	set(value):
		corridor_monster_ready_2 = value
		var player = GameManager.player_character
		while value:
			player.look_vector.x = PI
			player.look_vector.y = 0
			await get_tree().process_frame


func _ready() -> void:
	%NoSaveArea3D.body_entered.connect(func(_body):
		SaverLoader.can_save += 1)
	%NoSaveArea3D.body_entered.connect(func(_body):
		SaverLoader.can_save -= 1)
	
	$FakeCells/StaticFakeCell02_2/BedMonsterOnScreenNotifier3D.screen_entered_plus.connect(func():
		get_parent().cell_jumpscare = true
		%BedMonster/AnimationPlayer.play("Hide")
		AudioManager.play_uid_sound("SFX", "uid://bs05hgwl2paw0", -5.0)
		%BedMonster/AnimationPlayer.animation_finished.connect(func(_anim):
			DialogueManager.say("I have to tell them something is wrong", 3)
			bed_monster_happened = true)
		Game.story_description = "I have to tell them Michael is gone")
	
	if randi_range(1, 1000) == 67:
		var egg: StandardMaterial3D = load("uid://d34jsbwlmnipc")
		%CorridorMonster/MeshInstance3D3.set_surface_override_material(0, egg)
	
	%CorridorArea3D.body_entered.connect(func(body: PlayerCharacter):
		body.change_movement_mode(PlayerCharacter.MovementMode.NONE, true, false)
		if %CorridorOnScreenNotifier3D.is_on_screen():
			body.inventory.hide()
			%CorridorMonster/AnimationPlayer.play("Scare")
			%CorridorMonster/AnimationPlayer.animation_finished.connect(func(_anim):
				await get_tree().create_timer(0.2).timeout
				_end_demo())
			corridor_monster_ready_2 = true
			await get_tree().create_timer(1).timeout
			AudioManager.play_uid_sound("SFX", "uid://cfj7ljehifjom", -15.0)
		else:
			corridor_monster_ready = true)
	
	%CorridorOnScreenNotifier3D.screen_entered.connect(func():
		if corridor_monster_ready:
			GameManager.player_character.inventory.hide()
			%CorridorMonster/AnimationPlayer.play("Scare")
			%CorridorMonster/AnimationPlayer.animation_finished.connect(func(_anim):
				await get_tree().create_timer(0.2).timeout
				_end_demo())
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


func _jumpscare() -> void:
	InputManager.player_character_input = false
	
	var animation: Animation = %CorridorMonster/AnimationPlayer.get_animation("Scare")
	var player = GameManager.player_character
	var end_point = player.main_camera.global_position - (player.main_camera.global_basis.z * 0.2)
	animation.track_set_key_value(0, animation.track_get_key_count(0) - 1, end_point)
	
	player.inventory.flashlight.disabled = true
	
	AudioManager.play_uid_sound("SFX", "uid://b8jorf3nmlhbi", -10.0)


func _end_demo() -> void:
	Console.menu_hint = true
	GameManager.load_main_menu()


func save() -> Dictionary:
	var file: Dictionary = {
		"bed_monster_happened" = bed_monster_happened
	}
	
	return file


func load_save(file: Dictionary) -> void:
	bed_monster_happened = file["bed_monster_happened"]
