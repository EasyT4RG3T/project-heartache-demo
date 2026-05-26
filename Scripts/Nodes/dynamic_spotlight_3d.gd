@tool
class_name DynamicSpotLight3D
extends SpotLight3D


var disabled: bool = false:
	set(value):
		disabled = value
		if value:
			hide()
		elif !out_of_area:
			show()

var out_of_area: bool = false:
	set(value):
		out_of_area = value
		if value:
			hide()
		elif !disabled:
			show()

@export var area: Area3D


@export_tool_button("Set up") var set_up: Callable = func():
	if Engine.is_editor_hint():
		spot_angle = 80
		light_bake_mode = Light3D.BAKE_DISABLED
		shadow_enabled = true
		shadow_bias = 0.01
		shadow_blur = 1.0
		distance_fade_enabled = true
		distance_fade_begin = 5.0
		distance_fade_shadow = 10.0
		distance_fade_length = 10.0
		add_to_group("DynamicLights")


func _ready() -> void:
	if Engine.is_editor_hint(): return
	
	if light_cull_mask >= 524288:
		light_cull_mask -= 524288
	
	if shadow_caster_mask >= 524288:
		shadow_caster_mask -= 524288
	
	add_to_group("DynamicLights")
	if area:
		area.collision_layer = 8
		area.collision_mask = 8
		area.monitoring = true
		area.monitorable = false
		area.body_entered.connect(func(_body: Node3D):
			out_of_area = false)
		area.body_exited.connect(func(_body: Node3D):
			out_of_area = true)
		if !area.has_overlapping_bodies():
			out_of_area = true
