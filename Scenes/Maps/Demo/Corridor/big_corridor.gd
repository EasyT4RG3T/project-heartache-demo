extends Node3D


var sitting_man_happened: bool = false
var flashlight_picked_up: bool = false:
	set(value):
		flashlight_picked_up = value
		if value and %Flashlight:
			%Flashlight.queue_free()


func _ready() -> void:
	%Flashlight.hide()
	
	%InvisibleWalls/Area3D.body_entered.connect(func(player: PlayerCharacter):
		player.add_thought("I shouldn't go there"))
	
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
	
	%StaffDoor3/Hinge3D.failed_to_open.connect(func():
		get_parent().kitchen_door = true)
	
	%StaffDoor3/Area3D.body_entered.connect(func(_p):
		if !%StaffDoor3/Hinge3D.locked:
			%StaffDoor3/Hinge3D.duration = 0.2
			%StaffDoor3/Hinge3D.force_close()
			%StaffDoor3/Hinge3D.locked = true
			%StaffDoor3/Hinge3D.locked_message = ""
			AudioManager.play_uid_sound_at("SFX", "uid://ou087mm5q5jl", %StaffDoor3.global_position, 5)
			%Blockade.global_position += Vector3(0, 3, 0))
	
	%Blockade/Area3D.body_entered.connect(func(player: PlayerCharacter):
		player.add_thought("I could use the vents")
		Game.story_description += "\nI could use the vent in my cell")
	
	
	get_parent().first_talk_signal.connect(func():
		%TempWall.queue_free())
	
	get_parent().second_talk_signal.connect(func():
		%DefaultPrisoner.queue_free()
		
		for light in $Lights.get_children():
			light.queue_free()
		
		for light: StaticBodyLight3D in %StaticCeilingLights.get_children():
			light.turn_off()
		
		var imbake: LightmapGIData = load("uid://yo68ciruy22h")
		$DynamicLightmapGI.light_data = imbake
		
		%Flashlight.show())
	
	%Flashlight.interactable.interacted.connect(func(_p):
		flashlight_picked_up = true)


func save() -> Dictionary:
	var file: Dictionary = {
		"sitting_man_happened" = sitting_man_happened,
		"flashlight_picked_up" = flashlight_picked_up,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	sitting_man_happened = file["sitting_man_happened"]
	flashlight_picked_up = file["flashlight_picked_up"]
