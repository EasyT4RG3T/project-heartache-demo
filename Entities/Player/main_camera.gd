extends Camera3D


var center_ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
var direct_space: PhysicsDirectSpaceState3D

var collider: OnCenterScreenNotifier3D:
	set(value):
		if value == collider: return
		if collider is OnCenterScreenNotifier3D:
			collider.exit_center()
		if value is OnCenterScreenNotifier3D:
			value.enter_center()
		collider = value


func _ready() -> void:
	direct_space = get_world_3d().direct_space_state
	apply_settings()
	center_ray.collision_mask = 17
	center_ray.hit_from_inside = true


func _process(_delta: float) -> void:
	center_ray.from = global_position
	center_ray.to = global_position + (-global_basis.z * 100)
	
	var center_ray_result = direct_space.intersect_ray(center_ray)
	if center_ray_result and center_ray_result["collider"].get_collision_layer_value(5) == true:
		collider = center_ray_result["collider"]
	else:
		collider = null


func apply_settings() -> void:
	environment.tonemap_mode = SaverLoader.graphics_settings.tonemap_mode
	environment.tonemap_exposure = SaverLoader.graphics_settings.tonemap_exposure
	environment.tonemap_white = SaverLoader.graphics_settings.tonemap_white
	
	environment.ssao_enabled = SaverLoader.graphics_settings.ssao_enabled
	environment.ssao_radius = SaverLoader.graphics_settings.ssao_radius
	environment.ssao_intensity = SaverLoader.graphics_settings.ssao_intensity
	environment.ssao_power = SaverLoader.graphics_settings.ssao_power
	environment.ssao_detail = SaverLoader.graphics_settings.ssao_detail
	environment.ssao_horizon = SaverLoader.graphics_settings.ssao_horizon
	environment.ssao_sharpness = SaverLoader.graphics_settings.ssao_sharpness
	environment.ssao_light_affect = SaverLoader.graphics_settings.ssao_light_affect
	
	environment.ssil_enabled = SaverLoader.graphics_settings.ssil_enabled
	environment.ssil_radius = SaverLoader.graphics_settings.ssil_radius
	environment.ssil_intensity = SaverLoader.graphics_settings.ssil_intensity
	environment.ssil_sharpness = SaverLoader.graphics_settings.ssil_sharpness
	environment.ssil_normal_rejection = SaverLoader.graphics_settings.ssil_normal_rejection
	
	environment.glow_enabled = SaverLoader.graphics_settings.glow_enabled
	var current_level: int = 1
	for level in SaverLoader.graphics_settings.glow_levels:
		environment.set("glow_levels/" + str(current_level), level)
		current_level += 1
	environment.glow_normalized = SaverLoader.graphics_settings.glow_normalized
	environment.glow_intensity = SaverLoader.graphics_settings.glow_intensity
	environment.glow_strength = SaverLoader.graphics_settings.glow_strength
	environment.glow_bloom = SaverLoader.graphics_settings.glow_bloom
	environment.glow_blend_mode = SaverLoader.graphics_settings.glow_blend_mode
	
	environment.ssr_enabled = SaverLoader.graphics_settings.ssr_enabled
	
	environment.fog_enabled = SaverLoader.graphics_settings.fog_enabled
	environment.fog_mode = SaverLoader.graphics_settings.fog_mode
	environment.fog_light_energy = SaverLoader.graphics_settings.fog_light_energy
	environment.fog_sun_scatter = SaverLoader.graphics_settings.fog_sun_scatter
	environment.fog_density = SaverLoader.graphics_settings.fog_density
	environment.fog_sky_affect = SaverLoader.graphics_settings.fog_sky_affect
	environment.fog_height = SaverLoader.graphics_settings.fog_height
	environment.fog_height_density = SaverLoader.graphics_settings.fog_height_density
	environment.fog_depth_curve = SaverLoader.graphics_settings.fog_depth_curve
	environment.fog_depth_begin = SaverLoader.graphics_settings.fog_depth_begin
	environment.fog_depth_end = SaverLoader.graphics_settings.fog_depth_end
	
	environment.volumetric_fog_enabled = SaverLoader.graphics_settings.volumetric_fog_enabled
	
	environment.adjustment_brightness = SaverLoader.graphics_settings.brightness
	environment.adjustment_contrast = SaverLoader.graphics_settings.contrast
	environment.adjustment_saturation = SaverLoader.graphics_settings.saturation
