extends Node3D


const MESH_BURGER = preload("uid://bryahiae8bwhl")

var burger_pos: Vector3 = Vector3(-0.085, 0.088, 0.001)
var burger_rot: Vector3 = Vector3(0.409848, -0.142662, -0.220846)


var flashlight_picked_up: bool = false:
	set(value):
		flashlight_picked_up = value
		if value and %Flashlight:
			%Flashlight.queue_free()


var cutscene1_happened: bool = false:
	set(value):
		cutscene1_happened = value
		if value:
			%Cutscene1/Area3D.queue_free()


var key_picked_up: bool = false:
	set(value):
		key_picked_up = value
		get_parent().security_key = value
		if value:
			%Key.queue_free()


var prisoners: Array = []


func _ready() -> void:
	%VaultHint.hide()
	%Flashlight.hide()
	
	%Cutscene1/Area3D.body_entered.connect(func(_p):
		%Friend2/AnimationPlayer.play("Sit4(Wave)")
		cutscene1_happened = true
		%Cutscene1.play_animation("Look")
		DialogueManager.say("Our table", 2))
	
	$StaticKitchen/CrawlArea.body_entered.connect(func(_p):
		if %VaultHint.visible:
			get_parent().kitchen_door = false
			%VaultHint.hide())
	
	%Key/KeyInteractable.interacted.connect(func(player: PlayerCharacter):
		player.inventory.add_key("Security Key")
		AudioManager.play_uid_sound("SFX", "uid://cn3tdffsy22my")
		key_picked_up = true
		SaverLoader.can_save += 1
		DialogueManager.say("Dave always knows what to do", 3)
		await get_tree().create_timer(3).timeout
		DialogueManager.say("I need to get to him... or his cell", 3)
		await get_tree().create_timer(3).timeout
		DialogueManager.say("I think he's in 12", 3)
		Game.story_description = "I need to get to cell 012"
		SaverLoader.can_save -= 1)
	
	prisoners.append_array(_find_prisoners(%StaticCafeteria/Assets))
	
	for prisoner in prisoners:
		match randi_range(0, 2):
			0:
				_prisoner_sit_2(prisoner)
			1:
				_prisoner_sit_2_burger(prisoner)
			2:
				_prisoner_sit_2_burger_2(prisoner)
	
	%Friend1/AnimationPlayer.play("Sit3")
	%Friend1/AnimationPlayer.get_animation("Sit3").loop_mode = Animation.LOOP_LINEAR
	%Friend2/AnimationPlayer.play("Sit4")
	%Friend2/AnimationPlayer.get_animation("Sit4").loop_mode = Animation.LOOP_LINEAR
	
	%Friends/InteractableFaze1.interacted.connect(func(player: PlayerCharacter):
		get_parent().first_talk = true
		player.interactable = null
		Game.story_description = "I should check on Michael in cell 008"
		%Cutscene2.play_animation("Talk"))
	
	%Friends/InteractableFaze2.active = false
	%Friends/InteractableFaze2.interacted.connect(func(player: PlayerCharacter):
		DialogueManager.say("Hey guys!", 2)
		await get_tree().create_timer(2).timeout
		DialogueManager.say("Michael is", 4)
		AudioManager.play_uid_sound("SFX", "uid://cm8a6u7yjbf52")
		get_parent().second_talk = true
		player.interactable = null
		await get_tree().create_timer(2).timeout
		DialogueManager.say("... gone", 2)
		Game.story_description = "Everyone is gone?")
	
	
	get_parent().first_talk_signal.connect(func():
		%Friends/InteractableFaze1.queue_free())
	
	get_parent().cell_jumpscare_signal.connect(func():
		%Friends/InteractableFaze2.active = true)
	
	%SpecialTable/StaticBench.hide()
	%SpecialTable/StaticBench2.hide()
	
	get_parent().second_talk_signal.connect(func():
		for light in $StaticCafeteria/Lights.get_children():
			light.queue_free()
		var imbake: LightmapGIData = load("uid://c5q78c3lqlufr")
		$DynamicLightmapGI.light_data = imbake
		
		for light: StaticBodyLight3D in %StaticCeilingLights.get_children():
			light.turn_off()
		
		%Flashlight.show()
		
		%Friends.queue_free()
		%TempWall.queue_free()
		for prisoner in prisoners:
			prisoner.queue_free())
	
	%Flashlight.interactable.interacted.connect(func(_p):
		flashlight_picked_up = true)
	
	get_parent().kitchen_door_signal.connect(func():
		%VaultHint.show())
	
	get_parent().security_key_signal.connect(func():
		%SpecialTable.global_position = Vector3(-11.9, 0.1, 6.1)
		%SpecialTable/StaticBench.show()
		%SpecialTable/StaticBench2.show())


func _prisoner_sit_2(prisoner: Node) -> void:
	for child in prisoner.get_children():
		if child is AnimationPlayer:
			child.play("Sit2")
			child.seek(randf_range(0, child.current_animation_length), true)
			child.animation_finished.connect(func(_anim_name: StringName):
				child.play("Sit2"))


func _prisoner_sit_2_burger(prisoner: Node) -> void:
	var burger = MESH_BURGER.instantiate()
	burger.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC
	for child in prisoner.get_children():
		if child.name == "RightHandIK":
			child.add_child(burger)
			burger.position = burger_pos
			burger.rotation = burger_rot
		
		if child is AnimationPlayer:
			child.play("Sit2(Burger)")
			child.seek(randf_range(0, child.current_animation_length), true)
			child.animation_finished.connect(func(_anim_name: StringName):
				match randi_range(0, 1):
					0:
						child.play("Sit2(Burger)")
					1:
						child.play("Sit2(Burger)_Eat")
				)


func _prisoner_sit_2_burger_2(prisoner: Node) -> void:
	var burger: MeshInstance3D = MESH_BURGER.instantiate()
	burger.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC
	for child in prisoner.get_children():
		if child.name == "RightHandIK":
			child.add_child(burger)
			burger.position = burger_pos
			burger.rotation = burger_rot
		
		if child is AnimationPlayer:
			child.play("Sit2(Burger2)")
			child.seek(randf_range(0, child.current_animation_length), true)
			child.animation_finished.connect(func(_anim_name: StringName):
				match randi_range(0, 1):
					0:
						child.play("Sit2(Burger2)")
					1:
						child.play("Sit2(Burger2)_Eat")
				)


func _find_prisoners(node: Node) -> Array:
	var array: Array = []
	for child in node.get_children():
		if child.name.contains("DefaultPrisoner"):
			array.append(child)
		elif child.get_child_count() > 0:
			array.append_array(_find_prisoners(child))
	
	return array


func _say(text: String, duration: float = 5) -> void:
	DialogueManager.say(text, duration)


func save() -> Dictionary:
	var file: Dictionary = {
		"key_picked_up" = key_picked_up,
		"cutscene1_happened" = cutscene1_happened,
		"flashlight_picked_up" = flashlight_picked_up,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	key_picked_up = file["key_picked_up"]
	cutscene1_happened = file["cutscene1_happened"]
	flashlight_picked_up = file["flashlight_picked_up"]
