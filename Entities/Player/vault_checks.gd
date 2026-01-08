class_name VaultChecks
extends Node

var debug: bool = false:
	set(value):
		debug = value
		match value:
			true:
				d_crouch_mesh = ShapeHelper.create_capsule_mesh(0.35, 0.8, Color.RED, 0.5)
				p.add_child(d_crouch_mesh)
				d_crouch_mesh.top_level = true
				d_player_mesh = ShapeHelper.create_capsule_mesh(0.35, 1.8, Color.RED, 0.5)
				p.add_child(d_player_mesh)
				d_player_mesh.top_level = true
				d_v_check_mesh = ShapeHelper.create_cylinder_mesh(0.15, 0.675, Color.DEEP_PINK, 0.5)
				p.add_child(d_v_check_mesh)
				d_v_check_mesh.top_level = true
				d_v_height_mesh = ShapeHelper.create_sphere_mesh(0.35, Color.AQUA, 0.5)
				p.add_child(d_v_height_mesh)
				d_v_height_mesh.top_level = true
				d_v_height_floor_mesh = ShapeHelper.create_sphere_mesh(0.35, Color.SKY_BLUE, 0.5)
				p.add_child(d_v_height_floor_mesh)
				d_v_height_floor_mesh.top_level = true
				d_v_floor_mesh_1 = ShapeHelper.create_cylinder_mesh(0.01, 0.2, Color.BLUE, 0.5)
				p.add_child(d_v_floor_mesh_1)
				d_v_floor_mesh_1.top_level = true
				d_v_floor_mesh_2 = ShapeHelper.create_cylinder_mesh(0.01, 0.2, Color.BLUE, 0.5)
				p.add_child(d_v_floor_mesh_2)
				d_v_floor_mesh_2.top_level = true
				d_v_floor_mesh_3 = ShapeHelper.create_cylinder_mesh(0.01, 0.2, Color.BLUE, 0.5)
				p.add_child(d_v_floor_mesh_3)
				d_v_floor_mesh_3.top_level = true
				d_v_floor_mesh_4 = ShapeHelper.create_cylinder_mesh(0.01, 0.2, Color.BLUE, 0.5)
				p.add_child(d_v_floor_mesh_4)
				d_v_floor_mesh_4.top_level = true
				d_v_point_mesh = ShapeHelper.create_sphere_mesh(0.02, Color.WHITE, 1)
				p.add_child(d_v_point_mesh)
				d_v_point_mesh.top_level = true
			false:
				d_crouch_mesh.queue_free()
				d_player_mesh.queue_free()
				d_v_check_mesh.queue_free()
				d_v_height_mesh.queue_free()
				d_v_height_floor_mesh.queue_free()
				d_v_floor_mesh_1.queue_free()
				d_v_floor_mesh_2.queue_free()
				d_v_floor_mesh_3.queue_free()
				d_v_floor_mesh_4.queue_free()
				d_v_point_mesh.queue_free()
				d_crouch_mesh = null
				d_player_mesh = null
				d_v_check_mesh = null
				d_v_height_mesh = null
				d_v_height_floor_mesh = null
				d_v_floor_mesh_1 = null
				d_v_floor_mesh_2 = null
				d_v_floor_mesh_3 = null
				d_v_floor_mesh_4 = null
				d_v_point_mesh = null

var d_crouch_mesh: MeshInstance3D
var d_player_mesh: MeshInstance3D
var d_v_check_mesh: MeshInstance3D
var d_v_height_mesh: MeshInstance3D
var d_v_height_floor_mesh: MeshInstance3D
var d_v_floor_mesh_1: MeshInstance3D
var d_v_floor_mesh_2: MeshInstance3D
var d_v_floor_mesh_3: MeshInstance3D
var d_v_floor_mesh_4: MeshInstance3D
var d_v_point_mesh: MeshInstance3D


const vault_max_height: float = 1.36
const vault_min_height: float = -0.21

var vault_check_query: PhysicsShapeQueryParameters3D = ShapeHelper.create_query_cylinder(0.15, 0.675)
var vault_check_query_position: Vector3 = Vector3(0, 0.685, 0)
var vault_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
var vault_height_query: PhysicsShapeQueryParameters3D = ShapeHelper.create_query_sphere(0.35)
var vault_fit_query: PhysicsShapeQueryParameters3D = ShapeHelper.create_query_sphere(0.3)
var vault_fit_query_position: Vector3 = Vector3(0, 1.55, 0)
var vault_fit_queary_mid_position: Vector3 = Vector3(0, 1.05, 0)
var vault_fit_query_crouch_position: Vector3 = Vector3(0, 0.55, 0)

var vault_uncrouch_height: Vector3 = Vector3.ZERO
var vault_crouch_mid: Vector3 = Vector3.ZERO

const vault_distances: Dictionary = {
	p.MovementMode.WALKING: 0.6,
	p.MovementMode.SPRINTING: 0.8,
	p.MovementMode.CROUCHING: 0.5,
}
var vault_distance: float = vault_distances[p.MovementMode.WALKING]

var vault_error: String = ""

var p: PlayerCharacter


func check() -> void:
	var vault_direction: Vector3 = Vector3.FORWARD.rotated(Vector3.UP, p.head.rotation.y)
	
	vault_check_query.transform.origin = p.global_position + vault_check_query_position
	vault_check_query.motion = vault_direction * vault_distance
	
	var vault_check_result = p.direct_space_state.cast_motion(vault_check_query)
	if !vault_check_result or vault_check_result[0] >= 1.0:
		p.can_vault = false
		vault_error = "nothing_to_vault"
		return
	
	if debug:
		d_v_check_mesh.global_position = vault_check_query.transform.origin
		d_v_check_mesh.global_position += vault_check_query.motion * vault_check_result[0]
	
	var vault_check_unsave_distance = vault_check_query.motion * vault_check_result[1]
	
	vault_check_query.transform.origin += vault_check_unsave_distance
	
	var collision_info = p.direct_space_state.get_rest_info(vault_check_query)
	if !collision_info:
		p.can_vault = false
		vault_error = "didn't_get_starting_vault_point"
		return
	
	if abs(collision_info.normal.dot(Vector3.UP)) >= 0.7:
		p.can_vault = false
		vault_error = "too_steep"
		return
	
	if vault_direction.dot(collision_info.normal) > -0.6:
		p.can_vault = false
		vault_error = "too_high_angle"
		return
	
	if !_vault_end_point_set(collision_info.point, collision_info.normal):
		if !_vault_end_point_set(p.global_position, -vault_direction * 2):
			p.can_vault = false
			return
	
	if debug:
		d_v_point_mesh.global_position = p.vault_position
	
	match p.current_movement_mode:
		p.MovementMode.CROUCHING:
			if _vault_crouch_cast(p.vault_position):
				p.can_vault = true
				return
		_:
			if _vault_standing_cast(p.vault_position):
				p.can_vault = true
				return
	
	p.can_vault = false
	vault_error = "something went wrong"


func _vault_end_point_set(point: Vector3, normal: Vector3) -> bool:
	var wanted_vault_point = point - normal * 0.6
	var wanted_vault_point_short = point - normal * 0.2
	
	vault_ray_query.from = Vector3(
		wanted_vault_point.x,
		p.global_position.y + vault_max_height,
		wanted_vault_point.z
	)
	vault_ray_query.to = Vector3(
		wanted_vault_point.x,
		p.global_position.y + vault_min_height,
		wanted_vault_point.z
	)
	
	var vault_point_result = p.direct_space_state.intersect_ray(vault_ray_query)
	var vault_point: Vector3
	
	vault_ray_query.from = Vector3(
		wanted_vault_point_short.x,
		p.global_position.y + vault_max_height,
		wanted_vault_point_short.z
	)
	vault_ray_query.to = Vector3(
		wanted_vault_point_short.x,
		p.global_position.y + vault_min_height,
		wanted_vault_point_short.z
	)
	
	var vault_point_short_result = p.direct_space_state.intersect_ray(vault_ray_query)
	var vault_point_short: Vector3
	
	if !vault_point_result and !vault_point_short_result:
		vault_error = "no_valid_vault_point"
		return false
	
	if !vault_point_result and vault_point_short_result:
		vault_point_short = vault_point_short_result["position"]
		
		if !_vault_end_point_final(vault_point_short):
			return false
		return true
	
	if !vault_point_short_result and vault_point_result:
		vault_point = vault_point_result["position"]
		
		if !_vault_end_point_final(vault_point):
			return false
		return true
	
	vault_point_short = vault_point_short_result["position"]
	vault_point = vault_point_result["position"]
	
	if vault_point.y == vault_point_short.y:
		if vault_point.y > p.global_position.y + 0.2:
			if !_vault_end_point_final(vault_point_short):
				if !_vault_end_point_final(vault_point):
					return false
				return true
			return true
		else:
			if !_vault_end_point_final(vault_point):
				if !_vault_end_point_final(vault_point_short):
					return false
				return true
			return true
	
	elif vault_point.y < vault_point_short.y:
		if !_vault_end_point_final(vault_point):
			if !_vault_end_point_final(vault_point_short):
				return false
			return true
		return true
	
	else:
		if !_vault_end_point_final(vault_point_short):
			if !_vault_end_point_final(vault_point):
				return false
			return true
		return true


func _vault_floor_check(check_pos: Vector3) -> bool:
	var vault_floor_checks: Array[Vector3] = [
		check_pos + Vector3(0.15, 0.1, 0),
		check_pos + Vector3(0, 0.1, 0.15),
		check_pos + Vector3(-0.15, 0.1, 0),
		check_pos + Vector3(0, 0.1, -0.15),
	]
	
	if debug:
		d_v_floor_mesh_1.global_position = vault_floor_checks[0] - Vector3(0, 0.1, 0)
		d_v_floor_mesh_2.global_position = vault_floor_checks[1] - Vector3(0, 0.1, 0)
		d_v_floor_mesh_3.global_position = vault_floor_checks[2] - Vector3(0, 0.1, 0)
		d_v_floor_mesh_4.global_position = vault_floor_checks[3] - Vector3(0, 0.1, 0)
	
	for pos in vault_floor_checks:
		vault_ray_query.from = pos
		vault_ray_query.to = pos + Vector3(0, -0.2, 0)
		if !p.direct_space_state.intersect_ray(vault_ray_query):
			return false
	
	return true


func _vault_end_fit_check(check_pos: Vector3) -> bool:
	check_pos.y += 0.01
	match p.current_movement_mode:
		p.MovementMode.CROUCHING:
			p.player_crouch_query.transform.origin = check_pos + p.player_crouch_collision_position
			if p.direct_space_state.intersect_shape(p.player_crouch_query, 1):
				return false
		_:
			p.player_shape_query.transform.origin = check_pos + p.player_collision_position
			if p.direct_space_state.intersect_shape(p.player_shape_query, 1):
				return false
	return true


func _vault_height_adjust(pos: Vector3) -> Vector3:
	vault_height_query.transform.origin = Vector3(
		pos.x,
		pos.y + 0.45,
		pos.z
	)
	vault_height_query.motion = Vector3(0, -0.45, 0)
	
	if debug:
		d_v_height_mesh.global_position = vault_height_query.transform.origin
		d_v_height_floor_mesh.global_position = vault_height_query.transform.origin + vault_height_query.motion
		d_v_height_floor_mesh.global_position.y += 0.35
	
	var vault_height_result = p.direct_space_state.cast_motion(vault_height_query)
	
	pos = vault_height_query.transform.origin
	pos += vault_height_query.motion * vault_height_result[0]
	pos.y -= 0.35
	
	return pos


func _vault_end_point_final(point: Vector3) -> bool:
	if !_vault_floor_check(point):
		vault_error = "invalid_floor"
		return false
	
	point = _vault_height_adjust(point)
	
	if !_vault_end_fit_check(point):
		vault_error = "no_space"
		return false
	
	p.vault_position = point
	return true


func _vault_standing_cast(vault_end_point: Vector3) -> bool:
	if debug:
		d_player_mesh.global_position = vault_end_point + p.player_collision_position
	
	vault_fit_query.transform.origin = p.global_position + vault_fit_query_position
	vault_fit_query.motion = vault_end_point - p.global_position
	
	var vault_fit_result = p.direct_space_state.cast_motion(vault_fit_query)
	if vault_fit_result[0] < 1:
		vault_error = "can't_fit_through"
		return false
	
	p.vault_position = vault_end_point
	return true


func _vault_crouch_cast(vault_end_point: Vector3) -> bool:
	if debug:
		d_crouch_mesh.global_position = vault_end_point + p.player_crouch_collision_position
	
	vault_fit_query.transform.origin = p.global_position + vault_fit_query_crouch_position
	vault_fit_query.motion = vault_end_point - p.global_position
	
	var vault_fit_direct_result = p.direct_space_state.cast_motion(vault_fit_query)
	if vault_fit_direct_result[0] >= 1:
		p.vault_position = vault_end_point
		vault_uncrouch_height = Vector3.ZERO
		vault_crouch_mid = Vector3.ZERO
		return true
	
	if vault_end_point.y > p.global_position.y:
		var uncrouch_pos := Vector3(p.global_position.x, vault_end_point.y, p.global_position.z)
		
		vault_fit_query.transform.origin = uncrouch_pos + vault_fit_query_crouch_position
		vault_fit_query.motion = vault_end_point - uncrouch_pos
		
		var vault_fit_up_direct_result = p.direct_space_state.cast_motion(vault_fit_query)
		if vault_fit_up_direct_result[0] >= 1:
			vault_fit_query.transform.origin = p.global_position + vault_fit_query_crouch_position
			vault_fit_query.motion = Vector3(0, vault_end_point.y - p.global_position.y, 0)
			
			var vault_fit_up_result = p.direct_space_state.cast_motion(vault_fit_query)
			if vault_fit_up_result[0] < 1:
				vault_error = "can't_stand_up_to_vault_height"
				return false
			
			p.vault_position = vault_end_point
			vault_uncrouch_height = vault_fit_query.motion
			vault_crouch_mid = Vector3.ZERO
			return true
	
	vault_fit_query.transform.origin = p.global_position + vault_fit_queary_mid_position
	vault_fit_query.motion = Vector3(
		vault_end_point.x - p.global_position.x,
		0,
		vault_end_point.z - p.global_position.z
	)
	
	var vault_fit_mid_direct_result = p.direct_space_state.cast_motion(vault_fit_query)
	if vault_fit_mid_direct_result[0] >= 1:
		vault_fit_query.transform.origin = p.global_position + vault_fit_query_crouch_position
		vault_fit_query.motion = vault_fit_queary_mid_position - vault_fit_query_crouch_position
		
		var vault_fit_mid_result = p.direct_space_state.cast_motion(vault_fit_query)
		if vault_fit_mid_result[0] >= 1:
			p.vault_position = vault_end_point
			vault_uncrouch_height = vault_fit_query.motion
			vault_crouch_mid = Vector3(
				vault_end_point.x,
				p.global_position.y + vault_uncrouch_height.y,
				vault_end_point.z
			)
			return true
	
	vault_fit_query.transform.origin = p.global_position + vault_fit_query_position
	vault_fit_query.motion = Vector3(
		vault_end_point.x - p.global_position.x,
		0,
		vault_end_point.z - p.global_position.z
	)
	
	var vault_fit_uncrouch_direct_result = p.direct_space_state.cast_motion(vault_fit_query)
	if vault_fit_uncrouch_direct_result[0] < 1:
		vault_error = "can't_fit_through"
		return false
	
	if !p._check_can_uncrouch():
		vault_error = "can't_stand_up"
		return false
	
	p.vault_position = vault_end_point
	vault_uncrouch_height = p.player_head_position - p.player_crouch_head_position
	vault_crouch_mid = Vector3(
		vault_end_point.x,
		p.global_position.y + vault_uncrouch_height.y,
		vault_end_point.z
	)
	
	return true
