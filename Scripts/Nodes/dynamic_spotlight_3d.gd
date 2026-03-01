@tool
class_name DynamicSpotLight3D
extends SpotLight3D


var default_light_size: float = 0.2
var default_light_energy: float = 1.0
var out_of_area: bool = false:
	set(value):
		out_of_area = value
		if value:
			hide()

@export var cull_distance: float = 10.0
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
	
	default_light_size = light_size
	default_light_energy = light_energy
	if SaverLoader.graphics_settings.smooth_lights == false:
		light_size = 0
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


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if !GameManager.player_character: return
	
	if out_of_area: return
	
	var vector: Vector3 = global_position - GameManager.player_character.global_position
	var distance: float = vector.length()
	
	if distance > cull_distance:
		var dot: float = vector.normalized().dot(GameManager.player_character.head.basis.z)
		if visible and dot > 0:
			hide()
		elif !visible and dot < 0:
			show()
	elif !visible:
		show()
	
	if SaverLoader.graphics_settings.smooth_lights == false: return
	
	if distance > 10.0:
		light_size = 0
	elif distance > 7.0:
		light_size = default_light_size * 0.3
		light_energy = default_light_energy * 0.90
	elif distance > 5.0:
		light_size = default_light_size * 0.6
		light_energy = default_light_energy * 0.93
	else:
		light_size = default_light_size
		light_energy = default_light_energy
