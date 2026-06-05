@tool
class_name StaticOmniLight3D
extends OmniLight3D


@export_tool_button("Set up") var set_up: Callable = func():
	if Engine.is_editor_hint():
		layers = 3
		light_bake_mode = Light3D.BAKE_STATIC
		omni_range = 3.0
		distance_fade_enabled = true
		distance_fade_begin = 5.0
		distance_fade_shadow = 10.0
		distance_fade_length = 10.0
		add_to_group("StaticLights")


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	if light_cull_mask >= 524288:
		light_cull_mask -= 524288
	add_to_group("StaticLights")
