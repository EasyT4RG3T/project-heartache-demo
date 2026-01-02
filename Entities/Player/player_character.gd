class_name PlayerCharacter
extends CharacterBody3D


const player_collision_height: float = 1.8
const player_collision_position: Vector3 = Vector3(0, 0.9, 0)
const player_crouch_collision_height: float = 0.8
const player_crouch_collision_position: Vector3 = Vector3(0, 0.4, 0)
func _check_can_uncrouch() -> bool:
	player_shape_query.transform.origin = global_position + player_collision_position
	if direct_space_state.intersect_shape(player_shape_query, 1):
		return false
	else:
		player_crouch_query.transform.origin = global_position + player_crouch_head_position
		if direct_space_state.intersect_shape(player_crouch_query, 1):
			return false
		return true

const player_head_position: Vector3 = Vector3(0, 1.7, 0)
const player_crouch_head_position: Vector3 = Vector3(0, 0.7, 0)

var direct_space_state: PhysicsDirectSpaceState3D
var player_shape_query: PhysicsShapeQueryParameters3D = ShapeHelper.create_query_capsule(0.35, 1.8)
var player_crouch_query: PhysicsShapeQueryParameters3D = ShapeHelper.create_query_capsule(0.35, 0.8)


@onready var body_collision: CollisionShape3D = %BodyCollision
@onready var head_collision: CollisionShape3D = %HeadCollision
@onready var head: Node3D = %Head
var head_tween: Tween
func _move_head_smooth(pos: Vector3, duration: float, on_complete: Callable = Callable()) -> void:
	if head.position.is_equal_approx(pos):
		head.position = pos
		if on_complete.is_valid():
			on_complete.call()
			return
	
	if head_tween:
		head_tween.kill()
	
	head_tween = create_tween().set_ease(Tween.EASE_IN_OUT)\
	.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	head_tween.tween_property(head, "position", pos, duration)
	head_tween.finished.connect(func():
		if on_complete.is_valid():
			on_complete.call())

@onready var player_hud: PlayerHUD = %PlayerHUD
@onready var flashlight: Flashlight = %Flashlight
@onready var hands: Node3D = %Hands

@onready var main_camera: Camera3D = %MainCamera
@onready var inventory_camera: Camera3D = %InventoryCamera
@onready var inventory_sub_viewport: SubViewport = %InventorySubViewport
@export var player_fov: float = 90
var fov_tween: Tween
func _change_fov_smooth(fov: float) -> void:
	if fov_tween:
		fov_tween.kill()
	fov_tween = create_tween().set_ease(Tween.EASE_IN).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	fov_tween.tween_property(main_camera, "fov", fov, 0.3)

@onready var dust_particles: GPUParticles3D = %DustParticles
@onready var dust_collider: GPUParticlesCollisionBox3D = %DustCollider


var mouse_sensitivity: float = 10.0
var mouse_sensitivity_modifier: float = 0.0001
var look_vector: Vector2 = Vector2.ZERO

var movement_acceleration: float = 20.0
var movement_vector: Vector2 = Vector2.ZERO
var movement_vector_fly: float = 0.0
var wanted_movement_direction: Vector2 = Vector2.ZERO
enum MovementMode { NONE, FLY, WALKING, SPRINTING, CROUCHING, CARRYING, VAULTING }
var movement_speeds: Dictionary[MovementMode, float] = {
	MovementMode.NONE: 0,
	MovementMode.FLY: 5,
	MovementMode.WALKING: 2,
	MovementMode.SPRINTING: 3.5,
	MovementMode.CROUCHING: 1,
	MovementMode.CARRYING: 1.5,
	MovementMode.VAULTING: 0,
}
var current_movement_mode: MovementMode = MovementMode.WALKING
var current_movement_speed: float = movement_speeds[MovementMode.WALKING]
var movement_speed_tween: Tween
var pre_fly_movement_mode: MovementMode = MovementMode.WALKING
var pre_fly_movement_speed: float = movement_speeds[MovementMode.WALKING]

var vault_checks: VaultChecks = VaultChecks.new()
var vault_position: Vector3 = Vector3.ZERO
var can_vault: bool = false:
	set(value):
		can_vault = value
		if value:
			player_hud.vault = true
			#_raise_hands(true)
		else:
			player_hud.vault = false
			#_raise_hands(false)
var player_tween: Tween

var interact_type: String = ""
var interaction_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
var interaction_ray_result: Dictionary:
	set(value):
		if value == interaction_ray_result: return
		if value and value["collider"] is Interactable and value["collider"].active:
			interaction_ray_result = value
			player_hud.active = true
			match value["collider"].interact_type:
				Interactable.InteractableType.PRESS:
					player_hud.can_tap = false
					player_hud.can_hold = false
					interact_type = "Press"
				Interactable.InteractableType.TAP:
					player_hud.can_hold = false
					player_hud.can_tap = true
					interact_type = "Tap"
				Interactable.InteractableType.HOLD:
					player_hud.can_tap = false
					player_hud.can_hold = true
					interact_type = "Hold"
		else:
			interaction_ray_result = {}
			player_hud.active = false
			player_hud.can_tap = false
			player_hud.can_hold = false
			interact_type = ""
var drop_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
var drop_ray_result: Dictionary:
	set(value):
		if value:
			drop_ray_result = value
		else:
			drop_ray_result = {}

var heavy_item: HeavyItem3D = null:
	set(value):
		heavy_item = value
		if value is HeavyItem3D:
			change_movement_mode(MovementMode.CARRYING)
		else:
			change_movement_mode(MovementMode.WALKING)


func _ready() -> void:
	direct_space_state = get_world_3d().direct_space_state
	get_window().size_changed.connect(_update_sub_viewport)
	_update_sub_viewport()
	interaction_ray_query.collision_mask = 1
	drop_ray_query.collision_mask = 1
	vault_checks.p = self


func take_input(event: InputEvent) -> void:
	_handle_camera_input(event)
	_handle_movement_input(event)
	_handle_action_input(event)


func _handle_camera_input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion: return
	
	var raw_input: Vector2 = event.relative * mouse_sensitivity * mouse_sensitivity_modifier
	
	look_vector -= raw_input
	
	look_vector.x = wrapf(look_vector.x, -PI, PI)
	look_vector.y = clamp(look_vector.y, -PI / 2.2, PI / 2.2)
	
	var look_rotation_x = Quaternion(Vector3.UP, look_vector.x)
	var look_rotation_y = Quaternion(Vector3.RIGHT, look_vector.y)
	
	head.quaternion = look_rotation_x * look_rotation_y


func _handle_movement_input(event: InputEvent) -> void:
	movement_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	movement_vector_fly = Input.get_axis("crouch", "vault")
	
	if event.is_action_pressed("sprint"):
		match current_movement_mode:
			MovementMode.WALKING:
				if !movement_vector.y < 0: return
				change_movement_mode(MovementMode.SPRINTING)
			MovementMode.SPRINTING:
				change_movement_mode(MovementMode.WALKING)
			MovementMode.CROUCHING:
				if !_check_can_uncrouch(): return
				change_movement_mode(MovementMode.SPRINTING)
	
	if event.is_action_pressed("crouch"):
		match current_movement_mode:
			MovementMode.WALKING:
				change_movement_mode(MovementMode.CROUCHING)
			MovementMode.SPRINTING:
				change_movement_mode(MovementMode.CROUCHING)
			MovementMode.CROUCHING:
				if !_check_can_uncrouch(): return
				change_movement_mode(MovementMode.WALKING)
	
	if event.is_action_pressed("vault"):
		if !can_vault: return
		match current_movement_mode:
			MovementMode.WALKING:
				_vault()
			MovementMode.SPRINTING:
				_vault()
			MovementMode.CROUCHING:
				_vault()


func _handle_action_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if interaction_ray_result:
			interaction_ray_result["collider"].interact(self)
	
	if event.is_action_released("interact"):
		if interaction_ray_result:
			interaction_ray_result["collider"].stop_interacting(self)
	
	if event.is_action_pressed("flashlight"):
		if !flashlight.disabled:
			if current_movement_mode != MovementMode.CARRYING:
				flashlight.switch()
	
	if event.is_action_pressed("drop"):
		if heavy_item:
			while Input.is_action_pressed("drop"):
				drop_ray_query.from = head.global_position
				drop_ray_query.to = head.global_position - main_camera.global_basis.z *\
				clampf(abs(head.rotation.x) * 2, 1.2, 2)
				drop_ray_result = direct_space_state.intersect_ray((drop_ray_query))
				
				if drop_ray_result:
					heavy_item.show_preview(self, drop_ray_result)
				else:
					heavy_item.hide_preview()
				
				await get_tree().physics_frame
	
	if event.is_action_released("drop"):
		if heavy_item:
			heavy_item.hide_preview()
			drop_ray_query.from = head.global_position
			drop_ray_query.to = head.global_position - main_camera.global_basis.z *\
			clampf(abs(head.rotation.x) * 2, 1.2, 2)
			drop_ray_result = direct_space_state.intersect_ray((drop_ray_query))
			
			if drop_ray_result:
				heavy_item.drop(self, drop_ray_result)


func change_movement_mode(mode: MovementMode) -> void:
	exit_movement_mode(current_movement_mode)
	current_movement_mode = mode
	match mode:
		MovementMode.WALKING:
			change_movement_speed(movement_speeds[MovementMode.WALKING])
			_change_fov_smooth(player_fov)
			vault_checks.vault_distance = vault_checks.vault_distances[MovementMode.WALKING]
		MovementMode.SPRINTING:
			change_movement_speed(movement_speeds[MovementMode.SPRINTING])
			_change_fov_smooth(player_fov + 10)
			vault_checks.vault_distance = vault_checks.vault_distances[MovementMode.SPRINTING]
		MovementMode.CROUCHING:
			change_movement_speed(movement_speeds[MovementMode.CROUCHING])
			_change_fov_smooth(player_fov - 10)
			body_collision.shape.height = player_crouch_collision_height
			body_collision.position = player_crouch_collision_position
			vault_checks.vault_distance = vault_checks.vault_distances[MovementMode.CROUCHING]
			_move_head_smooth(player_crouch_head_position, 0.3)
		MovementMode.CARRYING:
			change_movement_speed(movement_speeds[MovementMode.CARRYING])
			_change_fov_smooth(player_fov - 5)
			can_vault = false
			flashlight.turn_off()
		MovementMode.VAULTING:
			can_vault = false


func exit_movement_mode(mode: MovementMode) -> void:
	match mode:
		MovementMode.CROUCHING:
			body_collision.shape.height = player_collision_height
			body_collision.position.y = player_collision_position.y
			_move_head_smooth(player_head_position, 0.3)


func change_movement_speed(speed: float) -> void:
	if movement_speed_tween:
		movement_speed_tween.kill()
	
	movement_speed_tween = create_tween().set_ease(Tween.EASE_OUT)\
	.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	movement_speed_tween.tween_property(self, "current_movement_speed", speed, 0.5)


func _process(delta: float) -> void:
	interaction_ray_query.from = main_camera.global_position
	interaction_ray_query.to = head.global_position - main_camera.global_basis.z *\
		clampf(abs(head.rotation.x) * 2, 1.2, 1.6)
	
	interaction_ray_result = direct_space_state.intersect_ray(interaction_ray_query)
	
	flashlight.global_position = head.global_position
	flashlight.global_rotation.x = lerpf(
		flashlight.global_rotation.x,
		head.global_rotation.x,
		delta * 20
	)
	flashlight.global_rotation.y = lerp_angle(
		flashlight.global_rotation.y,
		head.global_rotation.y,
		delta * 20)


func _physics_process(delta: float) -> void:
	head_collision.position = head.position + Vector3(0, -0.35, 0)
	dust_particles.global_position = main_camera.global_position - main_camera.global_basis.z * 2
	
	match current_movement_mode:
		MovementMode.NONE:
			pass
		MovementMode.WALKING:
			_on_ground_movement(delta)
			_vault_check()
		MovementMode.SPRINTING:
			_on_ground_movement(delta)
			if !movement_vector.y < 0:
				change_movement_mode(MovementMode.WALKING)
			_vault_check()
		MovementMode.CROUCHING:
			_on_ground_movement(delta)
			_vault_check()
		MovementMode.CARRYING:
			_on_ground_movement(delta)
		MovementMode.VAULTING:
			pass
		MovementMode.FLY:
			_apply_fly_velocity(delta, current_movement_speed)
			move_and_slide()


func _on_ground_movement(delta: float) -> void:
	_apply_velocity(delta, current_movement_speed)
	if is_on_floor():
		_step_check()
	else:
		_gravity(delta)
	move_and_slide()


func _apply_velocity(delta: float, wanted_movement_speed: float) -> void:
	wanted_movement_direction = movement_vector.rotated(-head.rotation.y)
	var target_velocity: Vector2 = wanted_movement_direction * wanted_movement_speed
	
	velocity.x = lerpf(velocity.x, target_velocity.x, 1.0 - exp(-movement_acceleration * delta))
	if is_equal_approx(velocity.x, target_velocity.x):
		velocity.x = target_velocity.x
	velocity.z = lerpf(velocity.z, target_velocity.y, 1.0 - exp(-movement_acceleration * delta))
	if is_equal_approx(velocity.z, target_velocity.y):
		velocity.z = target_velocity.y


func _apply_fly_velocity(delta: float, wanted_movement_speed: float) -> void:
	var forward = -head.basis.z * -movement_vector.y
	var right = head.basis.x * movement_vector.x
	var up = Vector3.UP * movement_vector_fly
	
	if Input.is_action_pressed("fly_speed_up"):
		wanted_movement_speed *= 1.5
	elif Input.is_action_pressed("fly_speed_down"):
		wanted_movement_speed *= 0.5
	
	var target_velocity: Vector3 = (forward + right + up) * wanted_movement_speed
	
	for i in range(3):
		velocity[i] = lerpf(velocity[i], target_velocity[i], 1.0 - exp(-movement_acceleration * delta))
		if is_equal_approx(velocity[i], target_velocity[i]):
			velocity[i] = target_velocity[i]


func _gravity(delta: float) -> void:
	velocity.y -= 50 * delta


func _step_check() -> void:
	if !is_on_wall(): return
	
	var move_direction: Vector2 = wanted_movement_direction \
		if wanted_movement_direction != Vector2.ZERO else Vector2(velocity.x, velocity.z).normalized()
	
	if move_direction.length() < 0.1:
		return
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		
		var to_collision: Vector3 = collision.get_position() - global_position
		var to_collision_xz: Vector2 = Vector2(to_collision.x, to_collision.z).normalized()
		
		if move_direction.dot(to_collision_xz) < 0: continue
		
		to_collision_xz = to_collision_xz.limit_length(0.01)
		
		var high_difference: float = (collision.get_position().y - position.y)
		if high_difference > 0.345: continue
		
		var step_ray = PhysicsRayQueryParameters3D.new()
		step_ray.from = collision.get_position() + Vector3(to_collision_xz.x, 0.05, to_collision_xz.y)
		step_ray.to = collision.get_position() + Vector3(to_collision_xz.x, -0.25, to_collision_xz.y)
		var result = direct_space_state.intersect_ray(step_ray)
		var step_point = result.get("position")
		var step_normal = result.get("normal")
		
		if !step_normal: continue
		if abs(step_normal.dot(Vector3.UP)) < 0.701: continue
		
		var step_pos_multiplier: float = high_difference * 2
		
		var to_step: Vector3 = step_point - global_position
		
		var step_position = global_position + Vector3(
			to_step.x * step_pos_multiplier,
			to_step.y,
			to_step.z * step_pos_multiplier
		)
		
		if current_movement_mode == MovementMode.CROUCHING:
			player_crouch_query.transform.origin = step_position + player_crouch_collision_position
			if !direct_space_state.intersect_shape(player_crouch_query, 1):
				position = step_position
				break
		else:
			player_shape_query.transform.origin = step_position + player_collision_position
			if !direct_space_state.intersect_shape(player_shape_query, 1):
				position = step_position
				break


func _vault_check() -> void:
	if !is_on_floor(): return
	
	vault_checks.check()


func _vault() -> void:
	var pre_vault_movement_mode = current_movement_mode
	if current_movement_mode != MovementMode.CROUCHING or vault_checks.vault_uncrouch_height == Vector3.ZERO:
		current_movement_mode = MovementMode.VAULTING
		_move_player_smooth(vault_position, 0.4, func():
			current_movement_mode = pre_vault_movement_mode)
		return
	
	current_movement_mode = MovementMode.VAULTING
	if vault_checks.vault_crouch_mid == Vector3.ZERO:
		_move_player_smooth(global_position + vault_checks.vault_uncrouch_height, 0.2, func():
			_move_player_smooth(vault_position, 0.4, func():
				current_movement_mode = pre_vault_movement_mode))
		return
	
	_move_player_smooth(global_position + vault_checks.vault_uncrouch_height, 0.2, func():
		_move_player_smooth(vault_checks.vault_crouch_mid, 0.4, func():
			_move_player_smooth(vault_position, 0.2, func():
				current_movement_mode = pre_vault_movement_mode)))


func _move_player_smooth(pos: Vector3, duration: float, on_complete: Callable = Callable()) -> void:
	if global_position.is_equal_approx(pos):
		global_position = pos
		if on_complete.is_valid():
			on_complete.call()
			return
	
	if player_tween:
		player_tween.kill()
	
	player_tween = create_tween().set_ease(Tween.EASE_IN_OUT)\
	.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	player_tween.tween_property(self, "global_position", pos, duration)
	player_tween.finished.connect(func():
		if on_complete.is_valid():
			on_complete.call())


func _update_sub_viewport() -> void:
	inventory_sub_viewport.size = get_window().size


func add_thought(thought: String, story: bool = false, time: float = 2.0) -> void:
	player_hud.display_thought(thought, story, time)


func apply_settings() -> void:
	player_fov = SaverLoader.settings.fov
	main_camera.fov = player_fov
	mouse_sensitivity = SaverLoader.settings.sensitivity


func save() -> Dictionary:
	var file = {
		"position": global_position if current_movement_mode != MovementMode.VAULTING else vault_position,
		"rotation": head.global_rotation,
		"look_vector": look_vector,
		"movement_mode": current_movement_mode,
	}
	
	file["flashlight"] = {
		"disabled": flashlight.disabled,
		"visible": flashlight.light.visible,
	}
	
	if heavy_item:
		file["heavy_item"] = {
			"path": heavy_item.scene_file_path,
		}
	
	return file


func load_save(file: Dictionary) -> void:
	velocity = Vector3.ZERO
	global_position = file["position"]
	head.global_rotation = file["rotation"]
	look_vector = file["look_vector"]
	if file["movement_mode"] == MovementMode.CROUCHING:
		current_movement_mode = MovementMode.CROUCHING
		current_movement_speed = movement_speeds[MovementMode.CROUCHING]
		main_camera.fov = player_fov - 10
		body_collision.shape.height = player_crouch_collision_height
		body_collision.position = player_crouch_collision_position
		vault_checks.vault_distance = vault_checks.vault_distances[MovementMode.CROUCHING]
		head.position = player_crouch_head_position
	
	flashlight.disabled = file["flashlight"]["disabled"]
	flashlight.light.visible = file["flashlight"]["visible"]
	
	if heavy_item:
		heavy_item.queue_free()
		heavy_item = null
	if file.has("heavy_item"):
		var hv: HeavyItem3D = load(file["heavy_item"]["path"]).instantiate()
		add_child(hv)
		hv._pick_up(self)
