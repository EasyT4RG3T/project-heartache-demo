extends Node


signal GameFullyLoaded


const main_menu_uid: String = "uid://evmnqmy0k477"
const new_game_uid: String = "uid://cxen7otwqul1c"
const debug_uid: String = "uid://be8nto6fraipm"

var debug_overlay: DebugOverlay

var player_character_uid: String = "uid://c28pkwyvm76o1"
var player_character: PlayerCharacter

var is_new_game: bool = false


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	get_tree().auto_accept_quit = false


func screenshot(ss_name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	if !DirAccess.dir_exists_absolute(SaverLoader.GAME_PATH + "/screenshots"):
		DirAccess.make_dir_absolute(SaverLoader.GAME_PATH + "/screenshots")
	image.save_png(SaverLoader.GAME_PATH + "/screenshots/" + ss_name + ".png")


func load_player() -> void:
	var player = load(player_character_uid)
	player = player.instantiate()
	Game.add_child(player)
	player_character = player
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	InputManager.player_character = player
	InputManager.player_character_input = true
	player_character.main_camera.make_current()


func load_main_menu() -> void:
	SaverLoader.progress_message = "Loading Menu"
	SaverLoader.show_loading_screen()
	SaverLoader.can_save = 1
	player_character = null
	InputManager.player_character = null
	
	Game.clear()
	Game.running = false
	AudioManager.clear()
	DialogueManager.clear()
	
	await get_tree().process_frame
	
	var menu = load(main_menu_uid)
	menu = menu.instantiate()
	Game.add_child(menu)
	SaverLoader.hide_loading_screen()


func set_debug_overlay(value: int) -> void:
	if value >= 1:
		if !debug_overlay:
			debug_overlay = load(debug_uid).instantiate()
			add_child(debug_overlay)
		debug_overlay.overlay_layer = value
	else:
		debug_overlay.queue_free()
		await get_tree().process_frame
		debug_overlay = null


func apply_settings_data() -> void:
	SaverLoader.current_slot = SaverLoader.settings.last_save
	
	DisplayServer.window_set_vsync_mode(SaverLoader.settings.vsync)
	Engine.max_fps = SaverLoader.settings.max_fps
	
	if SaverLoader.settings.window_mode != DisplayServer.window_get_mode():
		DisplayServer.window_set_mode(SaverLoader.settings.window_mode)
	
	AudioServer.set_bus_volume_db(0, linear_to_db(clamp(SaverLoader.settings.master_volume, 0.0, 1.0)))
	AudioServer.set_bus_volume_db(1, linear_to_db(clamp(SaverLoader.settings.sfx_volume, 0.0, 1.0)))
	AudioServer.set_bus_volume_db(2, linear_to_db(clamp(SaverLoader.settings.dialogue_volume, 0.0, 1.0)))
	AudioServer.set_bus_volume_db(3, linear_to_db(clamp(SaverLoader.settings.ambient_volume, 0.0, 1.0)))
	AudioServer.set_bus_volume_db(4, linear_to_db(clamp(SaverLoader.settings.music_volume, 0.0, 1.0)))
	AudioServer.set_bus_volume_db(5, linear_to_db(clamp(SaverLoader.settings.menus_volume, 0.0, 1.0)))
	
	DialogueManager.apply_settings()
	
	if player_character:
		player_character.apply_settings()


func apply_graphics_settings_data() -> void:
	get_viewport().scaling_3d_mode = SaverLoader.graphics_settings.scaling_3d_mode
	get_viewport().scaling_3d_scale = SaverLoader.graphics_settings.scaling_3d_scale
	get_viewport().msaa_2d = SaverLoader.graphics_settings.msaa_2d
	get_viewport().msaa_3d = SaverLoader.graphics_settings.msaa_3d
	get_viewport().screen_space_aa = SaverLoader.graphics_settings.ssaa
	get_viewport().use_taa = SaverLoader.graphics_settings.taa
	get_viewport().use_debanding = SaverLoader.graphics_settings.debanding
	
	RenderingServer.environment_set_ssao_quality(
		SaverLoader.graphics_settings.ssao_quality,
		SaverLoader.graphics_settings.ssao_half_size,
		SaverLoader.graphics_settings.ssao_adaptive_target,
		SaverLoader.graphics_settings.ssao_blur_passes,
		SaverLoader.graphics_settings.ssao_fadeout_from,
		SaverLoader.graphics_settings.ssao_fadeout_to
	)
	
	RenderingServer.environment_set_ssil_quality(
		SaverLoader.graphics_settings.ssil_quality,
		SaverLoader.graphics_settings.ssil_half_size,
		SaverLoader.graphics_settings.ssil_adaptive_target,
		SaverLoader.graphics_settings.ssil_blur_passes,
		SaverLoader.graphics_settings.ssil_fadeout_from,
		SaverLoader.graphics_settings.ssil_fadeout_to
	)
	
	RenderingServer.environment_glow_set_use_bicubic_upscale(SaverLoader.graphics_settings.glow_upscale_mode)
	RenderingServer.sub_surface_scattering_set_quality(SaverLoader.graphics_settings.sss_quality)
	
	RenderingServer.environment_set_volumetric_fog_volume_size(
		SaverLoader.graphics_settings.volumetric_fog_volume_size,
		SaverLoader.graphics_settings.volumetric_fog_volume_depth
	)
	RenderingServer.environment_set_volumetric_fog_filter_active(SaverLoader.graphics_settings.volumetric_fog_volume_use_filter)
	
	RenderingServer.directional_shadow_atlas_set_size(SaverLoader.graphics_settings.directional_shadow_size, true)
	RenderingServer.directional_soft_shadow_filter_set_quality(SaverLoader.graphics_settings.directional_shadow_quality)
	
	get_viewport().positional_shadow_atlas_size = SaverLoader.graphics_settings.positional_shadow_size
	RenderingServer.positional_soft_shadow_filter_set_quality(SaverLoader.graphics_settings.positional_shadow_quality)
	get_viewport().positional_shadow_atlas_16_bits = SaverLoader.graphics_settings.positional_shadow_16bit
	get_viewport().positional_shadow_atlas_quad_0 = SaverLoader.graphics_settings.positional_shadow_atlas0
	get_viewport().positional_shadow_atlas_quad_1 = SaverLoader.graphics_settings.positional_shadow_atlas1
	get_viewport().positional_shadow_atlas_quad_2 = SaverLoader.graphics_settings.positional_shadow_atlas2
	get_viewport().positional_shadow_atlas_quad_3 = SaverLoader.graphics_settings.positional_shadow_atlas3
	
	if player_character:
		player_character.apply_graphics_settings()


func new_game() -> void:
	SaverLoader.show_loading_screen()
	
	Game.clear()
	AudioManager.clear()
	DialogueManager.clear()
	
	await get_tree().process_frame
	
	SaverLoader.clear_temp()
	await Game.load_chunk(new_game_uid)
	load_player()
	await get_tree().process_frame
	
	is_new_game = true
	SaverLoader.can_save = 0
	GameFullyLoaded.emit()
	Game.running = true
	SaverLoader.hide_loading_screen()


func save(file: Dictionary) -> void:
	file["player"] = player_character.save()
	file["game"] = Game.save()


func load_save(file: Dictionary) -> void:
	SaverLoader.show_loading_screen()
	
	player_character = null
	InputManager.player_character = null
	InputManager.player_character_input = false
	
	Game.clear()
	AudioManager.clear()
	DialogueManager.clear()
	
	await get_tree().process_frame
	
	await Game.load_save(file["game"])
	
	load_player()
	player_character.load_save(file["player"])
	await get_tree().process_frame
	SaverLoader.can_save = 0
	get_tree().paused = false
	GameFullyLoaded.emit()
	Game.running = true
	SaverLoader.hide_loading_screen()
