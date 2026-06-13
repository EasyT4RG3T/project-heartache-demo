extends Node3D


var journal_picked_up: bool = false:
	set(value):
		journal_picked_up = value
		if value:
			%JournalPickup.queue_free()

var cell_opened: bool = false:
	set(value):
		cell_opened = value
		if value:
			if %Guard:
				%Guard/AnimationPlayer.play("Stand")
				while %Guard:
					%Guard/HeadLookIK.global_position = lerp(%Guard/HeadLookIK.global_position, GameManager.player_character.main_camera.global_position, get_physics_process_delta_time() * 10)
					await get_tree().physics_frame

var janitor_hint_happened: bool = false:
	set(value):
		janitor_hint_happened = value
		if value:
			%JanitorArea3D.queue_free()


func _ready() -> void:
	%JanitorArea3D.body_entered.connect(func(_p):
		DialogueManager.say("Janitor should have tools in his closet", 5)
		janitor_hint_happened = true
		Game.story_description += "\nThere should be a screwdriver in the janitors closet")
	
	%JournalPickup/StaticBody3D.interacted.connect(func(player: PlayerCharacter):
		player.inventory.journal.disabled = false
		journal_picked_up = true
		player.add_thought("[TAB] to open the journal")
		AudioManager.play_uid_sound("SFX", "uid://e11hf6bvulye")
		await get_tree().create_timer(2).timeout
		SaverLoader.can_save += 1
		%Guard/AnimationPlayer.play("Open")
		%Guard/AnimationPlayer.animation_finished.connect(func(_anim):
			cell_opened = true
			SaverLoader.can_save -= 1))
	
	%SkeletonBlanked04/AnimationPlayer.play("Breathe")
	%Skeleton/AnimationPlayer.play("Breathe")
	
	get_parent().second_talk_signal.connect(func():
		%Guard.queue_free())


func _open_cell() -> void:
	$StaticCell01/Assets/CellDoor01/Hinge3D.force_open()
	$StaticCell01/Assets/CellDoor01/Hinge3D/InteractableStaticBody3D.interactable.active = false
	DialogueManager.say("[{alkhemikal}]You're late for breakfast[/font]", 3)
	AudioManager.play_uid_sound_at("SFX", "uid://dfd6nswnuicaj", $StaticCell01/Assets/CellDoor01.global_position)


func save() -> Dictionary:
	var file: Dictionary = {
		"journal_picked_up" = journal_picked_up,
		"cell_opened" = cell_opened,
		"janitor_hint_happened" = janitor_hint_happened,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	journal_picked_up = file["journal_picked_up"]
	cell_opened = file["cell_opened"]
	janitor_hint_happened = file["janitor_hint_happened"]
