@tool
class_name DynamicSpotLight3D
extends SpotLight3D


@export_tool_button("Set up") var set_up: Callable = func():
	if Engine.is_editor_hint():
		spot_angle = 80
		light_bake_mode = Light3D.BAKE_DISABLED
		light_size = 0.2
		shadow_enabled = true
		shadow_bias = 0.01
		shadow_blur = 1.5
		add_to_group("DynamicLights")


func _ready() -> void:
	if !Engine.is_editor_hint():
		if SaverLoader.graphics_settings.smooth_lights == false:
			light_size = 0
