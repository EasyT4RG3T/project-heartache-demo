@tool
class_name Cutscene
extends Node3D


@export var animation_player: AnimationPlayer
@export var animated_player: Node3D
@export var exit_modes: Dictionary[String, PlayerCharacter.MovementMode]

const UI_SKIP = preload("uid://b2fn5yvvmjf2m")
var skip_progress_bar: TextureProgressBar

var rigid_bodies: Array[DynamicRigidBody3D] = []

var skip_dialogue: bool = false

var holding: bool = false:
	set(value):
		holding = value
		
		while holding == true and skip_progress_bar:
			hold_timer -= get_process_delta_time()
			skip_progress_bar.value = 1.0 - hold_timer
			await get_tree().process_frame
		if holding == false:
			hold_timer = 1.0
			if skip_progress_bar:
				skip_progress_bar.value = 0.0
var hold_timer: float = 1.0:
	set(value):
		hold_timer = value
		if value <= 0.0:
			holding = false
			if animation_player.is_playing():
				skip_dialogue = true
				DialogueManager.clear()
				animation_player.advance(
					animation_player.current_animation_length - animation_player.current_animation_position
					- 0.01
					)
var holding_key: InputEvent


func take_input(event: InputEvent) -> void:
	if event is not InputEventMouse:
		if holding_key and !event.is_match(holding_key, false): return
		if event.is_pressed():
			if holding: return
			holding_key = event
			holding = true
		if event.is_released():
			holding_key = null
			holding = false


func play_animation(anim_name: String) -> void:
	while InputManager.menu:
		await get_tree().process_frame
	
	var animation: Animation = animation_player.get_animation(anim_name)
	
	skip_dialogue = false
	
	SaverLoader.can_save += 1
	
	if animated_player:
		animated_player.global_transform = GameManager.player_character.head.global_transform
	
	for track in animation.get_track_count():
		var node_path: String = animation.track_get_path(track)
		var node = get_node(node_path)
		
		if node is DynamicRigidBody3D:
			if node.picked_up:
				node.put_down(node.current_player)
			rigid_bodies.append(node)
		
		match animation.track_get_type(track):
			Animation.TrackType.TYPE_VALUE:
				animation.track_insert_key(track, 0.0, node.get(node_path.get_slice(":", 1)))
			Animation.TrackType.TYPE_POSITION_3D:
				animation.position_track_insert_key(track, 0.0, node.position)
			Animation.TrackType.TYPE_ROTATION_3D:
				animation.rotation_track_insert_key(track, 0.0, node.quaternion)
			Animation.TrackType.TYPE_SCALE_3D:
				animation.scale_track_insert_key(track, 0.0, node.scale)
	
	animation_player.animation_finished.connect(_finish_animation, CONNECT_ONE_SHOT)
	animation_player.play(anim_name)
	
	if animated_player:
		GameManager.player_character.change_movement_mode(PlayerCharacter.MovementMode.CUTSCENE)
		
		InputManager.menu = self
		
		skip_progress_bar = TextureProgressBar.new()
		add_child(skip_progress_bar)
		skip_progress_bar.fill_mode = TextureProgressBar.FILL_CLOCKWISE
		skip_progress_bar.nine_patch_stretch = true
		skip_progress_bar.texture_progress = UI_SKIP
		skip_progress_bar.max_value = 1.0
		skip_progress_bar.step = 0.01
		skip_progress_bar.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		skip_progress_bar.offset_left = -74
		skip_progress_bar.offset_top = -74
		skip_progress_bar.offset_right = -10
		skip_progress_bar.offset_bottom = -10
		skip_progress_bar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
		
		while animation_player.is_playing():
			GameManager.player_character.head.global_position = animated_player.global_position
			GameManager.player_character.head.global_rotation = animated_player.global_rotation
			await get_tree().process_frame


func _finish_animation(anim_name: StringName) -> void:
	for rigid: DynamicRigidBody3D in rigid_bodies:
		rigid.linear_velocity = Vector3.ZERO
		rigid.angular_velocity = Vector3.ZERO
	
	rigid_bodies.clear()
	
	if animated_player:
		var animation: Animation = animation_player.get_animation(anim_name)
		var pos_track: int = animation.find_track(get_path_to(animated_player), Animation.TYPE_POSITION_3D)
		GameManager.player_character.global_position = animation.track_get_key_value(pos_track, animation.track_get_key_count(pos_track) - 1)
		GameManager.player_character.global_position -= Vector3(0, 1.6, 0)
		var movement_mode: PlayerCharacter.MovementMode = exit_modes.get(anim_name, PlayerCharacter.MovementMode.WALKING)
		GameManager.player_character.change_movement_mode(movement_mode, true)
		
		InputManager.menu = null
		
		skip_progress_bar.queue_free()
	
	SaverLoader.can_save -= 1


func _say(text: String) -> void:
	if skip_dialogue: return
	DialogueManager.say(text)
