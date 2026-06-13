extends Node3D


var sitting_man_happened: bool = false
var blockade_happened: bool = false:
	set(value):
		blockade_happened = value
		if value:
			%Blockade.global_position = Vector3(-9.9, 0.1, 1.8)
			%StaffDoor3/Area3D.queue_free()
var peak_happened: bool = false:
	set(value):
		peak_happened = value
		if value:
			%Peak/Area3D.queue_free()


func _ready() -> void:
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
	%TempWall2/Area3D.body_entered.connect(func(player: PlayerCharacter):
		player.add_thought("I don't need to go to the kitchen"))
	
	%StaffDoor3/Hinge3D.failed_to_open.connect(func():
		get_parent().kitchen_door = true)
	
	%StaffDoor3/Area3D.body_entered.connect(func(_p):
		if get_parent().security_key:
			blockade_happened = true)
	
	%Blockade/Area3D.body_entered.connect(func(player: PlayerCharacter):
		player.add_thought("I could use the vents")
		Game.story_description += "\nI could use the vent in my cell")
	
	%Peak/Area3D.body_entered.connect(func(_p):
		%Peak/AnimationPlayer.play()
		%Peak/StaffDoor2/Hinge3D.open = true
		%Peak/StaffDoor2/Hinge3D.force_close()
		peak_happened = true)
	
	get_parent().vent_open_signal.connect(func():
		%SquareVent/Hinge3D.force_open(-1))
	
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
		
		%SquareVent/Hinge3D.open_progress = -20
		
		%TempWall2.queue_free()
		
		%ugh1/Label3D.hide()
		%ugh2/Label3D.hide()
		
		await get_tree().process_frame
		if !peak_happened:
			%Peak/StaffDoor2/Hinge3D.open_progress = -30
			%Peak/AnimationPlayer.play("Door")
			await get_tree().process_frame
			%Peak/AnimationPlayer.pause())


func save() -> Dictionary:
	var file: Dictionary = {
		"sitting_man_happened" = sitting_man_happened,
		"blockade_happened" = blockade_happened,
		"peak_happened" = peak_happened,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	sitting_man_happened = file["sitting_man_happened"]
	blockade_happened = file["blockade_happened"]
	peak_happened = file["peak_happened"]
