@tool
class_name StaticOmniLight3D
extends OmniLight3D


@export_tool_button("Set up") var set_up: Callable = func():
	if Engine.is_editor_hint():
		light_bake_mode = Light3D.BAKE_STATIC
		omni_range = 1.0
		distance_fade_enabled = true
		distance_fade_begin = 5.0
		distance_fade_shadow = 10.0
		distance_fade_length = 10.0
		add_to_group("StaticLights")


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	add_to_group("StaticLights")
