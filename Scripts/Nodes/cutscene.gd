@tool
class_name Cutscene
extends AnimationPlayer


## First key will be replaced for smooth transition into cutscene /!\


@export var player_anim: Node3D

@export var setup: Dictionary[String, Dictionary]
@export_tool_button("Refresh Animation List") var refresh: Callable = func():
	for anim in get_animation_list():
		if setup.has(anim):
			temp_setup[anim] = setup[anim]
		else:
			temp_setup[anim] = {}
			temp_setup[anim]["EnterAngle"] = +1
			temp_setup[anim]["ExitMode"] = PlayerCharacter.MovementMode.WALKING
	setup.clear()
	setup = temp_setup
var temp_setup: Dictionary[String, Dictionary]

var player: PlayerCharacter

var set_up: bool = false


func _ready() -> void:
	assert(player_anim, "No player_anim in cutscene node")
	
	animation_started.connect(_set_up_anim)
	
	animation_finished.connect(_exit_anim)


func _set_up_anim(anim_name: StringName) -> void:
	if Engine.is_editor_hint(): return
	
	if set_up: return
	
	player = GameManager.player_character
	
	pause()
	var adjusted_player_rotation: Vector3 = player.head.global_rotation
	if setup[anim_name]["EnterAngle"] > 0 and adjusted_player_rotation.y < 0:
		adjusted_player_rotation.y += TAU
	elif setup[anim_name]["EnterAngle"] < 0 and adjusted_player_rotation.y > 0:
		adjusted_player_rotation.y -= TAU
	get_animation(anim_name).track_set_key_value(0, 0, player.head.global_position)
	get_animation(anim_name).track_set_key_value(1, 0, adjusted_player_rotation)
	player_anim.global_position = player.head.global_position
	player_anim.global_rotation = adjusted_player_rotation
	player._change_fov_smooth(80, get_animation(anim_name).track_get_key_time(0, 1))
	set_up = true
	_play_anim()


func _play_anim() -> void:
	player.change_movement_mode(PlayerCharacter.MovementMode.CUTSCENE)
	InputManager.player_character_input = false
	SaverLoader.can_save += 1
	play()
	while is_playing():
		player.head.global_position = player_anim.global_position
		player.head.global_rotation = player_anim.global_rotation
		await get_tree().process_frame


func _exit_anim(anim_name: StringName) -> void:
	player.current_movement_mode = setup[anim_name]["ExitMode"]
	var last_pos_key = get_animation(anim_name).track_get_key_count(0) - 1
	var last_rot_key = get_animation(anim_name).track_get_key_count(1) - 1
	match setup[anim_name]["ExitMode"]:
		PlayerCharacter.MovementMode.WALKING:
			player.global_position = get_animation(anim_name).track_get_key_value(0, last_pos_key) - Vector3(0, 1.7, 0)
			player.head.global_rotation = get_animation(anim_name).track_get_key_value(1, last_rot_key)
			player.current_movement_speed = player.movement_speeds[player.MovementMode.WALKING]
			player._change_fov_smooth(player.player_fov, 0.5)
			player.body_collision.shape.height = player.player_collision_height
			player.body_collision.position.y = player.player_collision_position.y
			player.vault_checks.vault_distance = player.vault_checks.vault_distances[player.MovementMode.WALKING]
			player.head.position = player.player_head_position
		PlayerCharacter.MovementMode.SPRINTING:
			player.global_position = get_animation(anim_name).track_get_key_value(0, last_pos_key) - Vector3(0, 1.7, 0)
			player.head.global_rotation = get_animation(anim_name).track_get_key_value(1, last_rot_key)
			player.current_movement_speed = player.movement_speeds[player.MovementMode.SPRINTING]
			player._change_fov_smooth(player.player_fov + 10, 0.5)
			player.body_collision.shape.height = player.player_collision_height
			player.body_collision.position.y = player.player_collision_position.y
			player.vault_checks.vault_distance = player.vault_checks.vault_distances[player.MovementMode.SPRINTING]
			player.head.position = player.player_head_position
		PlayerCharacter.MovementMode.CROUCHING:
			player.global_position = get_animation(anim_name).track_get_key_value(0, last_pos_key) - Vector3(0, 0.7, 0)
			player.head.global_rotation = get_animation(anim_name).track_get_key_value(1, last_rot_key)
			player.current_movement_speed = player.movement_speeds[player.MovementMode.CROUCHING]
			player._change_fov_smooth(player.player_fov - 10, 0.5)
			player.body_collision.shape.height = player.player_crouch_collision_height
			player.body_collision.position = player.player_crouch_collision_position
			player.vault_checks.vault_distance = player.vault_checks.vault_distances[player.MovementMode.CROUCHING]
			player.head.position = player.player_crouch_head_position
		PlayerCharacter.MovementMode.CRAWL:
			player.global_position = get_animation(anim_name).track_get_key_value(0, last_pos_key) - Vector3(0, 0.4, 0)
			player.head.global_rotation = get_animation(anim_name).track_get_key_value(1, last_rot_key)
			player.current_movement_speed = player.movement_speeds[player.MovementMode.CRAWL]
			player._change_fov_smooth(player.player_fov - 20, 0.5)
			player.body_collision.shape.height = player.player_crawl_collision_height
			player.body_collision.position = player.player_crawl_collision_position
			player.head.position = player.player_crawl_head_position
			player.can_vault = false
			await get_tree().process_frame
			player.can_vault = false
	player.last_pos = player.global_position
	player.look_vector.x = player.head.global_rotation.y
	player.look_vector.y = player.head.global_rotation.x
	InputManager.player_character_input = true
	set_up = false
	SaverLoader.can_save -= 1
