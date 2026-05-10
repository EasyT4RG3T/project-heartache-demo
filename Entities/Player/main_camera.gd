extends Camera3D


var center_ray: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
var direct_space: PhysicsDirectSpaceState3D

var default_fov: int = 80
var dynamic_fov: bool = true

var collider: OnCenterScreenNotifier3D:
	set(value):
		if value == collider: return
		if collider is OnCenterScreenNotifier3D:
			collider.exit_center()
		if value is OnCenterScreenNotifier3D:
			value.enter_center()
		collider = value


func _set(property: StringName, value: Variant) -> bool:
	if property == &"fov":
		if !dynamic_fov:
			fov = default_fov
		else:
			fov = value
		return true
	return false


func _ready() -> void:
	direct_space = get_world_3d().direct_space_state
	center_ray.collision_mask = 17
	center_ray.hit_from_inside = true
	
	environment = GameManager.DEFAULT_ENVIRONMENT


func _process(_delta: float) -> void:
	center_ray.from = global_position
	center_ray.to = global_position + (-global_basis.z * 100)
	
	var center_ray_result = direct_space.intersect_ray(center_ray)
	if center_ray_result and center_ray_result["collider"].get_collision_layer_value(5) == true:
		collider = center_ray_result["collider"]
	else:
		collider = null


func apply_settings() -> void:
	default_fov = SaverLoader.settings.fov
	dynamic_fov = SaverLoader.settings.dynamic_fov
