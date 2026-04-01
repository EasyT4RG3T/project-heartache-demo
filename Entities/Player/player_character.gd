class_name PlayerCharacter
extends CharacterBody3D

const player_collision_height: float = 1.8
const player_collision_position: Vector3 = Vector3(0, 0.9, 0)
const player_crouch_collision_height: float = 0.8
const player_crouch_collision_position: Vector3 = Vector3(0, 0.4, 0)
func _check_can_uncrouch() -> bool:
	player_shape_query.transform.origin = global_position + player_collision_position + Vector3(0, 0.001, 0)
	if direct_space_state.intersect_shape(player_shape_query, 1):
		return false
	else:
		player_crouch_query.transform.origin = global_position + player_crouch_head_position
		if direct_space_state.intersect_shape(player_crouch_query, 1):
			return false
		return true
const player_crawl_collision_height: float = 0.48
const player_crawl_collision_position: Vector3 = Vector3(0, 0.25, 0)
var crawl_cooldown: Timer = Timer.new()
var crawl_cooldown_time: float = 0.4
var crawl_debug: bool = false:
	set(value):
		crawl_debug = value
		match value:
			true:
				d_crouch_query = ShapeHelper.create_capsule_mesh(0.25, 0.8, Color.DARK_RED, 0.5)
				add_child(d_crouch_query)
				d_crouch_query.top_level = true
				d_crawl_query = ShapeHelper.create_capsule_mesh(0.25, 0.498, Color.DEEP_PINK, 0.5)
				add_child(d_crawl_query)
				d_crawl_query.top_level = true
			false:
				d_crouch_query.queue_free()
				d_crawl_query.queue_free()
				d_crouch_query = null
				d_crawl_query = null

var d_crouch_query = MeshInstance3D
var d_crawl_query = MeshInstance3D

const player_head_position: Vector3 = Vector3(0, 1.6, 0)
const player_crouch_head_position: Vector3 = Vector3(0, 0.6, 0)
const player_crawl_head_position: Vector3 = Vector3(0, 0.3, 0)

var direct_space_state: PhysicsDirectSpaceState3D
var player_shape_query: PhysicsShapeQueryParameters3D = ShapeHelper.create_query_capsule(0.25, 1.8)
var player_crouch_query: PhysicsShapeQueryParameters3D = ShapeHelper.create_query_capsule(0.25, 0.8)
var player_crawl_query: PhysicsShapeQueryParameters3D = ShapeHelper.create_query_capsule(0.25, 0.498)
var player_crawl_ceiling_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()


@onready var body_collision: CollisionShape3D = %BodyCollision
@onready var head_collision: CollisionShape3D = %HeadCollision
const head_collision_position: Vector3 = Vector3(0, -0.05, 0)
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
		head_tween = null
	
	head_tween = create_tween().set_ease(Tween.EASE_IN_OUT)\
	.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	head_tween.tween_property(head, "position", pos, duration)
	head_tween.tween_callback(func():
		if on_complete.is_valid():
			on_complete.call())

@onready var pause_menu: Control = %PauseMenu
@onready var player_hud: PlayerHUD = %PlayerHUD
@onready var flashlight: Flashlight = %Flashlight
@onready var hands: Node3D = %Hands

@onready var raytraced_audio_listener: RaytracedAudioListener = %RaytracedAudioListener

@onready var main_camera: Camera3D = %MainCamera
@onready var inventory_camera: Camera3D = %InventoryCamera
@onready var inventory_sub_viewport: SubViewport = %InventorySubViewport
var player_fov: float = 90
var fov_tween: Tween
func _change_fov_smooth(fov: float, duration: float = 0.3) -> void:
	if fov_tween:
		fov_tween.kill()
		fov_tween = null
	fov_tween = create_tween().set_ease(Tween.EASE_IN).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	fov_tween.tween_property(main_camera, "fov", fov, duration)
@onready var shader: ColorRect = %Shader
var do_bob: bool = true:
	set(value):
		do_bob = value
		if !value:
			main_camera.position = Vector3.ZERO
var bob_halftime: bool = false
var bob_time: float = 0.0
var bob_speed: float = 0.8

@onready var dust_particles: GPUParticles3D = %DustParticles

var mouse_sensitivity: float = 10.0
var mouse_sensitivity_modifier: float = 0.0001
var look_vector: Vector2 = Vector2.ZERO

var movement_acceleration: float = 20.0
var movement_vector: Vector2 = Vector2.ZERO
var movement_vector_fly: float = 0.0
var wanted_movement_direction: Vector2 = Vector2.ZERO
enum MovementMode { NONE, FLY, WALKING, SPRINTING, CROUCHING, CRAWL, CARRYING, VAULTING, CUTSCENE}
var movement_speeds: Dictionary[MovementMode, float] = {
	MovementMode.NONE: 0.0,
	MovementMode.FLY: 5.0,
	MovementMode.WALKING: 1.5,
	MovementMode.SPRINTING: 3.0,
	MovementMode.CROUCHING: 1.0,
	MovementMode.CRAWL: 0.8,
	MovementMode.CARRYING: 1.5,
	MovementMode.VAULTING: 0.0,
}
var current_movement_mode: MovementMode = MovementMode.WALKING
var current_movement_speed: float = movement_speeds[MovementMode.WALKING]
var movement_speed_tween: Tween
var pre_fly_movement_mode: MovementMode = MovementMode.WALKING
var pre_fly_movement_speed: float = movement_speeds[MovementMode.WALKING]

var last_pos: Vector3 = Vector3.ZERO
var was_on_ground: bool = false

const FAST_FOOTSTEP_01 = preload("uid://bj2u5uymwqsxx")
const FAST_FOOTSTEP_02 = preload("uid://bua6s2wd6n8ke")
const FAST_FOOTSTEP_03 = preload("uid://bfwl4fi50nlp")
const FAST_FOOTSTEP_04 = preload("uid://p7aytdgt2cqn")
const FAST_FOOTSTEP_05 = preload("uid://bj5fe00wqxsph")
const FAST_FOOTSTEP_06 = preload("uid://jd14431lq3x0")
const FAST_FOOTSTEP_07 = preload("uid://dmt2wh43yakgj")
const FAST_FOOTSTEP_08 = preload("uid://bu5toc2hdy4ce")
const FAST_FOOTSTEP_09 = preload("uid://dllae3mada0nt")
var fast_footsteps: Array = [
	FAST_FOOTSTEP_01,
	FAST_FOOTSTEP_02,
	FAST_FOOTSTEP_03,
	FAST_FOOTSTEP_04,
	FAST_FOOTSTEP_05,
	FAST_FOOTSTEP_06,
	FAST_FOOTSTEP_07,
	FAST_FOOTSTEP_08,
	FAST_FOOTSTEP_09
]
const FOOTSTEP_01 = preload("uid://crhxrcny28e6h")
const FOOTSTEP_02 = preload("uid://cha064owsqoh0")
const FOOTSTEP_03 = preload("uid://47sixlvx4lcq")
const FOOTSTEP_04 = preload("uid://bmep3oop7q06b")
const FOOTSTEP_05 = preload("uid://ducjj2sg2y78x")
const FOOTSTEP_06 = preload("uid://fghmdu3wu63o")
const FOOTSTEP_07 = preload("uid://c4lunogx8cjl7")
var footsteps: Array = [
	FOOTSTEP_01,
	FOOTSTEP_02,
	FOOTSTEP_03,
	FOOTSTEP_04,
	FOOTSTEP_05,
	FOOTSTEP_06,
	FOOTSTEP_07
]
const SLOW_FOOTSTEP_01 = preload("uid://dklk0hsrg5bgw")
const SLOW_FOOTSTEP_02 = preload("uid://cbmw6w1uwenoc")
const SLOW_FOOTSTEP_03 = preload("uid://chlusknabfn5d")
const SLOW_FOOTSTEP_04 = preload("uid://c5aquhnm5s71s")
const SLOW_FOOTSTEP_05 = preload("uid://cbp4lus65spto")
const SLOW_FOOTSTEP_06 = preload("uid://cxb11nbq8x6b1")
const SLOW_FOOTSTEP_07 = preload("uid://dk3m7xg44j8kx")
var slow_footsteps: Array = [
	SLOW_FOOTSTEP_01,
	SLOW_FOOTSTEP_02,
	SLOW_FOOTSTEP_03,
	SLOW_FOOTSTEP_04,
	SLOW_FOOTSTEP_05,
	SLOW_FOOTSTEP_06,
	SLOW_FOOTSTEP_07
]
var current_footsteps: Array = footsteps


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
var tilt_tween: Tween

var interactable: Interactable:
	set(value):
		if interactable:
			interactable.stop_looking(self)
		
		interactable = value
		
		if value:
			value.start_looking(self)
			player_hud.active = true
			player_hud.semi_active = value.semi_active
			player_hud.queue_redraw()
			match value.show_type:
				Interactable.ShowType.PRESS:
					player_hud.can_tap = false
					player_hud.can_hold = false
				Interactable.ShowType.TAP:
					player_hud.can_hold = false
					player_hud.can_tap = true
				Interactable.ShowType.HOLD:
					player_hud.can_tap = false
					player_hud.can_hold = true
		
		else:
			player_hud.active = false
			player_hud.can_tap = false
			player_hud.can_hold = false

var interaction_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
var interaction_ray_result: Dictionary:
	set(value):
		if phys_object: return
		if value:
			if interaction_ray_result:
				if interaction_ray_result["collider"] == value["collider"]:
					return
			
			if value["collider"].has_method("get_interactable"):
				var got_interactable: Interactable = value["collider"].get_interactable()
				if got_interactable.active:
					interactable = got_interactable
					interaction_ray_result = value
					return
		
		interactable = null
		interaction_ray_result = value

var phys_wanted_position: Vector3 = Vector3.ZERO
var phys_wanted_rotation: Basis = Basis()
var phys_wanted_distance_max: float = 1.6
var phys_wanted_distance_min: float = 1.0
var phys_wanted_distance: float = 0.0:
	set(value):
		phys_wanted_distance = clampf(value, phys_wanted_distance_min, phys_wanted_distance_max)
var phys_object: DynamicRigidBody3D:
	set(value):
		phys_object = value
		if value and value.mass >= 2 and current_movement_mode == MovementMode.SPRINTING:
			change_movement_mode(MovementMode.WALKING)
var mid_phys_rotation: bool = false


func _ready() -> void:
	direct_space_state = get_world_3d().direct_space_state
	get_window().size_changed.connect(_update_sub_viewport)
	_update_sub_viewport()
	interaction_ray_query.collision_mask = 7
	add_child(vault_checks)
	vault_checks.p = self
	
	add_child(crawl_cooldown)
	crawl_cooldown.one_shot = true
	player_crawl_query.collision_mask = 131
	
	inventory_camera.hide()
	inventory_camera.show()
	
	apply_settings()
	apply_graphics_settings()


func take_input(event: InputEvent) -> void:
	if DisplayServer.mouse_get_mode() != DisplayServer.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseButton:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
		return
	_handle_camera_input(event)
	_handle_movement_input(event)
	_handle_action_input(event)


func _handle_camera_input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion: return
	
	if !mid_phys_rotation:
		var raw_input: Vector2 = event.relative * mouse_sensitivity * mouse_sensitivity_modifier
		
		look_vector -= raw_input
		
		look_vector.x = wrapf(look_vector.x, -PI, PI)
		look_vector.y = clamp(look_vector.y, -PI / 2.2, PI / 2.2)
		
		var look_rotation_x = Quaternion(Vector3.UP, look_vector.x)
		var look_rotation_y = Quaternion(Vector3.RIGHT, look_vector.y)
		
		head.quaternion = look_rotation_x * look_rotation_y
	
	elif mid_phys_rotation:
		var raw_input: Vector2 = event.relative * mouse_sensitivity * mouse_sensitivity_modifier
		
		phys_wanted_rotation = phys_wanted_rotation.rotated(Vector3.UP, raw_input.x)
		phys_wanted_rotation = phys_wanted_rotation.rotated(head.global_basis.x, raw_input.y)


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
	if event.is_action_pressed("escape"):
		pause_menu.open()
	
	if event.is_action_pressed("interact"):
		if interactable:
			interactable.interact()
	
	if event.is_action_released("interact"):
		if interactable:
			interactable.stop_interacting()
	
	if event.is_action_pressed("flashlight"):
		if !flashlight.disabled:
			if current_movement_mode != MovementMode.CARRYING:
				flashlight.switch()
	
	if event.is_action_pressed("drop"):
		print("drop")
	
	if event.is_action_released("drop"):
		print("drop")
	
	if event.is_action_pressed("use_main"):
		pass
	
	if event.is_action_pressed("use_second"):
		pass
	
	if event.is_action_pressed("use_third"):
		mid_phys_rotation = true
	
	if event.is_action_released("use_third"):
		mid_phys_rotation = false
	
	if event.is_action_pressed("third_push"):
		phys_wanted_distance += 0.2
	
	if event.is_action_pressed("third_pull"):
		phys_wanted_distance -= 0.2


func change_movement_mode(mode: MovementMode, exit: bool = true) -> void:
	if exit:
		exit_movement_mode(current_movement_mode)
	current_movement_mode = mode
	match mode:
		MovementMode.WALKING:
			change_movement_speed(movement_speeds[MovementMode.WALKING])
			_change_fov_smooth(player_fov)
			vault_checks.vault_distance = vault_checks.vault_distances[MovementMode.WALKING]
			current_footsteps = footsteps
		MovementMode.SPRINTING:
			change_movement_speed(movement_speeds[MovementMode.SPRINTING])
			_change_fov_smooth(player_fov + 10)
			vault_checks.vault_distance = vault_checks.vault_distances[MovementMode.SPRINTING]
			current_footsteps = fast_footsteps
		MovementMode.CROUCHING:
			change_movement_speed(movement_speeds[MovementMode.CROUCHING])
			_change_fov_smooth(player_fov - 10)
			body_collision.shape.height = player_crouch_collision_height
			body_collision.position = player_crouch_collision_position
			vault_checks.vault_distance = vault_checks.vault_distances[MovementMode.CROUCHING]
			_move_head_smooth(player_crouch_head_position, 0.3)
			current_footsteps = slow_footsteps
		MovementMode.CRAWL:
			change_movement_speed(movement_speeds[MovementMode.CRAWL])
			_change_fov_smooth(player_fov - 20, 0.1)
			body_collision.shape.height = player_crawl_collision_height
			body_collision.position = player_crawl_collision_position
			_move_head_smooth(player_crawl_head_position, 0.1)
			can_vault = false
			await get_tree().process_frame
			can_vault = false
		MovementMode.CARRYING:
			change_movement_speed(movement_speeds[MovementMode.CARRYING])
			_change_fov_smooth(player_fov - 5)
			can_vault = false
			flashlight.turn_off()
		MovementMode.VAULTING:
			body_collision.disabled = true
			InputManager.player_character_input = false
		MovementMode.CUTSCENE:
			var main_camera_tween: Tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			main_camera_tween.tween_property(main_camera, "position", Vector3.ZERO, 0.2)
			bob_time = 0


func exit_movement_mode(mode: MovementMode) -> void:
	match mode:
		MovementMode.CROUCHING:
			body_collision.shape.height = player_collision_height
			body_collision.position.y = player_collision_position.y
			_move_head_smooth(player_head_position, 0.3)
		MovementMode.CRAWL:
			body_collision.shape.radius = 0.25
		MovementMode.VAULTING:
			body_collision.disabled = false
			was_on_ground = false
			InputManager.player_character_input = true


func change_movement_speed(speed: float) -> void:
	if movement_speed_tween:
		movement_speed_tween.kill()
		movement_speed_tween = null
	
	movement_speed_tween = create_tween().set_ease(Tween.EASE_OUT)\
	.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	movement_speed_tween.tween_property(self, "current_movement_speed", speed, 0.5)


func _process(delta: float) -> void:
	interaction_ray_query.from = main_camera.global_position
	interaction_ray_query.to = main_camera.global_position - main_camera.global_basis.z *\
		clampf(abs(head.rotation.x) * 2, 1.2, 1.6)
	
	interaction_ray_result = direct_space_state.intersect_ray(interaction_ray_query)
	
	flashlight.global_position = head.global_position - head.basis.y * 0.2 - head.basis.x * 0.1
	
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
	head_collision.position = head.position + head_collision_position
	dust_particles.global_position = main_camera.global_position - main_camera.global_basis.z * 2
	raytraced_audio_listener.update()
	
	if phys_object:
		phys_wanted_position = main_camera.global_position - main_camera.global_basis.z * phys_wanted_distance
		
		var force: Vector3 = phys_wanted_position - phys_object.global_position
		phys_object.linear_velocity = force * 10 * (1 + force.length())
		
		var rotation_diff: Vector3 = (phys_wanted_rotation * phys_object.global_basis.inverse()).get_euler()
		var angle_error: float = (abs(rotation_diff.x) + abs(rotation_diff.y) + abs(rotation_diff.z)) / 3.0
		var axis: Vector3 = rotation_diff.normalized()
		
		phys_object.angular_velocity = axis * angle_error * 100
		
		if (phys_wanted_position - phys_object.global_position).length() > 1.0:
			interactable.interact()
	
	match current_movement_mode:
		MovementMode.NONE:
			pass
		MovementMode.WALKING:
			_on_ground_movement(delta)
			if is_on_floor():
				vault_checks.check()
		MovementMode.SPRINTING:
			_on_ground_movement(delta)
			if !movement_vector.y < 0:
				change_movement_mode(MovementMode.WALKING)
			if is_on_floor():
				vault_checks.check()
		MovementMode.CROUCHING:
			_on_ground_movement(delta)
			_crawl_check()
			if is_on_floor():
				vault_checks.check()
		MovementMode.CRAWL:
			_on_ground_movement(delta)
			_uncrawl_check()
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
		
		var distance_delta: float = (global_position - last_pos).length()
		if !was_on_ground: distance_delta = 0.0
		last_pos = global_position
		bob_time += distance_delta * bob_speed * ((abs(main_camera.position.x) + 1.0) * 4)
		if bob_time >= PI and !bob_halftime:
			AudioManager.play_sound("SFX", current_footsteps.pick_random())
			bob_halftime = true
		if bob_time >= TAU:
			bob_time = 0
			AudioManager.play_sound("SFX", current_footsteps.pick_random())
			bob_halftime = false
		var side_bob: float = lerpf(-0.05, 0.05, ((sin(bob_time) + 1) / 2.0))
		var down_bob: float = lerpf(0, -0.02, sin(bob_time * 2))
		
		if do_bob:
			main_camera.position.x = side_bob
			main_camera.position.y = down_bob
		
		was_on_ground = true
	else:
		_gravity(delta)
		
		was_on_ground = false
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


func _crawl_check() -> void:
	player_crouch_query.transform.origin = global_position + player_crouch_collision_position + Vector3(
		-wanted_movement_direction.x * 0.02,
		0,
		-wanted_movement_direction.y * 0.02)
	player_crouch_query.motion = Vector3(
		wanted_movement_direction.x * 0.07,
		0,
		wanted_movement_direction.y * 0.07)
	var crawl_check_result = direct_space_state.cast_motion(player_crouch_query)
	
	if crawl_debug:
		d_crouch_query.global_position = player_crouch_query.transform.origin\
		+ (player_crouch_query.motion * crawl_check_result[0])
	
	if crawl_check_result[0] == 1.0:
		return
	
	player_crawl_query.transform.origin = global_position + player_crawl_collision_position + Vector3(
		-wanted_movement_direction.x * 0.02,
		0,
		-wanted_movement_direction.y * 0.02)
	player_crawl_query.motion = Vector3(
		wanted_movement_direction.x * 0.52,
		0,
		wanted_movement_direction.y * 0.52)
	var crawl_confirm_result = direct_space_state.cast_motion(player_crawl_query)
	
	if crawl_debug:
		d_crawl_query.global_position = player_crawl_query.transform.origin\
		+ (player_crawl_query.motion * crawl_confirm_result[0])
	
	if crawl_confirm_result[0] != 1.0:
		return
	
	player_crawl_ceiling_query.from = player_crawl_query.transform.origin + player_crawl_query.motion
	player_crawl_ceiling_query.to = player_crawl_ceiling_query.from + Vector3(0, 0.5, 0)
	var crawl_ceiling_result = direct_space_state.intersect_ray(player_crawl_ceiling_query)
	
	if !crawl_ceiling_result.has("collider"):
		return
	
	crawl_cooldown.start(crawl_cooldown_time)
	
	change_movement_mode(MovementMode.CRAWL)


func _uncrawl_check() -> void:
	if crawl_cooldown.time_left > 0.0: return
	
	player_crouch_query.transform.origin = global_position \
										 + player_crouch_collision_position \
										 + Vector3(0, 0.01, 0)
	var uncrawl_result = direct_space_state.get_rest_info(player_crouch_query)
	
	if uncrawl_result: return
	
	change_movement_mode(MovementMode.CROUCHING)


func _vault() -> void:
	var pre_vault_movement_mode: MovementMode = current_movement_mode
	var vault_height: float = vault_position.y - global_position.y
	var duration: float = 0.4 if vault_height < 1.0 else 0.8
	var tilt: float = 0.05 if (vault_position - global_position).dot(head.global_basis.x) < 0 else -0.05
	
	if tilt_tween:
		tilt_tween.kill()
		main_camera.rotation.z = 0.0
	
	tilt_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_parallel()
	tilt_tween.set_ease(Tween.EASE_IN)
	tilt_tween.tween_property(main_camera, "rotation:z", tilt, 0.2)
	if vault_height <= 1.0:
		tilt_tween.set_ease(Tween.EASE_OUT)
		tilt_tween.chain().tween_property(main_camera, "rotation:z", 0, 0.2)
	else:
		tilt_tween.set_ease(Tween.EASE_OUT_IN)
		tilt_tween.chain().tween_property(main_camera, "rotation:z", -tilt * 2, 0.4)
		tilt_tween.set_ease(Tween.EASE_OUT)
		tilt_tween.chain().tween_property(main_camera, "rotation:z", 0, 0.2)
	
	if current_movement_mode != MovementMode.CROUCHING or vault_checks.vault_uncrouch_height == Vector3.ZERO:
		change_movement_mode(MovementMode.VAULTING)
		_move_player_smooth(vault_position, duration, func():
			change_movement_mode(pre_vault_movement_mode))
		return
	
	change_movement_mode(MovementMode.VAULTING, false)
	if vault_checks.vault_crouch_mid == Vector3.ZERO:
		_move_player_smooth(global_position + vault_checks.vault_uncrouch_height, 0.2, func():
			_move_player_smooth(vault_position, duration, func():
				change_movement_mode(pre_vault_movement_mode)))
		return
	
	_move_player_smooth(global_position + vault_checks.vault_uncrouch_height, 0.2, func():
		_move_player_smooth(vault_checks.vault_crouch_mid, duration, func():
			_move_player_smooth(vault_position, 0.2, func():
				change_movement_mode(pre_vault_movement_mode))))


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
	player_tween.tween_callback(func():
		if on_complete.is_valid():
			on_complete.call())


func _update_sub_viewport() -> void:
	inventory_sub_viewport.size = get_window().size


func add_thought(thought: String, story: bool = false, time: float = 2.0, fade_in: float = 0.2, fade_out: float = 0.2) -> void:
	player_hud.display_thought(thought, story, time, fade_in, fade_out)


func apply_settings() -> void:
	player_fov = SaverLoader.settings.fov
	match current_movement_mode:
		MovementMode.SPRINTING:
			player_fov += 10
		MovementMode.CROUCHING:
			player_fov -= 10
		MovementMode.CRAWL:
			player_fov -= 20
	main_camera.fov = clamp(player_fov, 50, 120)
	mouse_sensitivity = SaverLoader.settings.sensitivity
	do_bob = SaverLoader.settings.head_bob
	shader.material.set_shader_parameter("static_enabled", SaverLoader.settings.static_shader)
	
	player_hud.apply_settings()
	main_camera.apply_settings()


func apply_graphics_settings() -> void:
	dust_particles.emitting = false if SaverLoader.graphics_settings.reduce_particles else true
	main_camera.apply_graphics_settings()


func save() -> Dictionary:
	var file = {
		"position": global_position if current_movement_mode != MovementMode.VAULTING else vault_position,
		"rotation": head.global_rotation,
		"look_vector": look_vector,
		"movement_mode": current_movement_mode,
		"fog_density": main_camera.environment.volumetric_fog_density
	}
	
	file["flashlight"] = {
		"disabled": flashlight.disabled,
		"visible": flashlight.light.visible,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	velocity = Vector3.ZERO
	global_position = file["position"]
	head.global_rotation = file["rotation"]
	look_vector = file["look_vector"]
	match file["movement_mode"]:
		MovementMode.CROUCHING:
			current_movement_mode = MovementMode.CROUCHING
			current_movement_speed = movement_speeds[MovementMode.CROUCHING]
			main_camera.fov = player_fov - 10
			body_collision.shape.height = player_crouch_collision_height
			body_collision.position = player_crouch_collision_position
			vault_checks.vault_distance = vault_checks.vault_distances[MovementMode.CROUCHING]
			head.position = player_crouch_head_position
		MovementMode.CRAWL:
			current_movement_mode = MovementMode.CRAWL
			current_movement_speed = movement_speeds[MovementMode.CRAWL]
			main_camera.fov = player_fov - 20
			body_collision.shape.height = player_crawl_collision_height
			body_collision.position = player_crawl_collision_position
			vault_checks.vault_distance = vault_checks.vault_distances[MovementMode.CROUCHING]
			head.position = player_crawl_head_position
	
	main_camera.environment.volumetric_fog_density = file["fog_density"]
	
	flashlight.disabled = file["flashlight"]["disabled"]
	flashlight.light.visible = file["flashlight"]["visible"]
