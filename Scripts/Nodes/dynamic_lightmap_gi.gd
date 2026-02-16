@tool
class_name DynamicLightmapGI
extends LightmapGI


var disabled: bool = false


func _init() -> void:
	if Engine.is_editor_hint():
		quality = LightmapGI.BAKE_QUALITY_HIGH
		supersampling = true
		use_texture_for_bounces = false
		environment_mode = LightmapGI.ENVIRONMENT_MODE_DISABLED
		generate_probes_subdiv = LightmapGI.GENERATE_PROBES_DISABLED
		add_to_group("GlobalIllumination")


func _ready() -> void:
	if Console.full_bright:
		Console.gis.append(self)
		hide()


func save() -> Dictionary:
	var data: Dictionary = {
		"disabled" = disabled
	}
	return data


func load_save(data: Dictionary) -> void:
	disabled = data["disabled"]


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and Console.full_bright:
		Console.gis.erase(self)
