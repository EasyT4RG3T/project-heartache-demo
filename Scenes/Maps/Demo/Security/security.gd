extends Node3D


func _ready() -> void:
	%JanitorDoor/Hinge3D.opened.connect(func():
		%JanitorDoor/Hinge3D/InteractableStaticBody3D.active = false)
	
	_light_blink(randf_range(0.5, 2))


func _light_blink(time: float) -> void:
	await get_tree().create_timer(time).timeout
	if $StaticJanitor/Lights/DynamicSpotLight3D.visible:
		$StaticJanitor/Lights/DynamicSpotLight3D.hide()
		_light_blink(randf_range(0.1, 0.2))
	else:
		$StaticJanitor/Lights/DynamicSpotLight3D.show()
		_light_blink(randf_range(0.1, 5))
