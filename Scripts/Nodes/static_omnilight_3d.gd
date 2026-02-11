@tool
class_name StaticOmniLight3D
extends OmniLight3D


func _init():
	if Engine.is_editor_hint():
		light_bake_mode = Light3D.BAKE_STATIC
		omni_range = 1.0
		add_to_group("StaticLights")
