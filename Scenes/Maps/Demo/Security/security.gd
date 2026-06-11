extends Node3D


var skinny_monster_happened: bool = false:
	set(value):
		skinny_monster_happened = value
		if value:
			%SkinnyMonster/Area3D.call_deferred("set_monitoring", false)


func _ready() -> void:
	%JanitorDoor/Hinge3D.opened.connect(func():
		%JanitorDoor/Hinge3D/InteractableStaticBody3D.active = false)
	
	_light_blink(randf_range(0.5, 2))
	
	%SkinnyMonster/Area3D.body_entered.connect(func(_body):
		%SkinnyMonster/AnimationPlayer.play("Run")
		%SkinnyMonster/AnimationPlayer.animation_finished.connect(func(_anim):
			%SkinnyMonster.hide())
		skinny_monster_happened = true
		AudioManager.play_uid_sound("SFX", "uid://bnx3g24rknw6a"))


func _light_blink(time: float) -> void:
	await get_tree().create_timer(time).timeout
	if $StaticJanitor/Lights/DynamicSpotLight3D.visible:
		$StaticJanitor/Lights/DynamicSpotLight3D.hide()
		_light_blink(randf_range(0.1, 0.2))
	else:
		$StaticJanitor/Lights/DynamicSpotLight3D.show()
		_light_blink(randf_range(0.1, 5))


func _physics_process(_delta: float) -> void:
	%SkinnyMonster/HeadLookIK.global_position = GameManager.player_character.main_camera.global_position


func save() -> Dictionary:
	var file: Dictionary = {
		"skinny_monster_happened" = skinny_monster_happened
	}
	
	return file


func load_save(file: Dictionary) -> void:
	skinny_monster_happened = file["skinny_monster_happened"]
	if skinny_monster_happened:
		%SkinnyMonster.hide()
