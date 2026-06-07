extends Node


signal GameFullyLoaded

var DEFAULT_ENVIRONMENT = preload("uid://b5hbq6dr1gixx")
var STRIPPED_ENVIRONMENT = preload("uid://d2m0td6ed2a2t")

const main_menu_uid: String = "uid://evmnqmy0k477"
const debug_uid: String = "uid://be8nto6fraipm"

var debug_overlay: DebugOverlay

var player_character_uid: String = "uid://c28pkwyvm76o1"
var player_character: PlayerCharacter
var journal: Journal

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
	journal = player.inventory.journal
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
	
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	
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
	SaverLoader.autosave_slot = SaverLoader.settings.last_autosave
	
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
	
	DEFAULT_ENVIRONMENT.tonemap_mode = SaverLoader.graphics_settings.tonemap_mode
	DEFAULT_ENVIRONMENT.tonemap_exposure = SaverLoader.graphics_settings.tonemap_exposure
	DEFAULT_ENVIRONMENT.tonemap_white = SaverLoader.graphics_settings.tonemap_white
	
	DEFAULT_ENVIRONMENT.ssao_enabled = SaverLoader.graphics_settings.ssao_enabled
	DEFAULT_ENVIRONMENT.ssao_radius = SaverLoader.graphics_settings.ssao_radius
	DEFAULT_ENVIRONMENT.ssao_intensity = SaverLoader.graphics_settings.ssao_intensity
	DEFAULT_ENVIRONMENT.ssao_power = SaverLoader.graphics_settings.ssao_power
	DEFAULT_ENVIRONMENT.ssao_detail = SaverLoader.graphics_settings.ssao_detail
	DEFAULT_ENVIRONMENT.ssao_horizon = SaverLoader.graphics_settings.ssao_horizon
	DEFAULT_ENVIRONMENT.ssao_sharpness = SaverLoader.graphics_settings.ssao_sharpness
	DEFAULT_ENVIRONMENT.ssao_light_affect = SaverLoader.graphics_settings.ssao_light_affect
	
	DEFAULT_ENVIRONMENT.ssil_enabled = SaverLoader.graphics_settings.ssil_enabled
	DEFAULT_ENVIRONMENT.ssil_radius = SaverLoader.graphics_settings.ssil_radius
	DEFAULT_ENVIRONMENT.ssil_intensity = SaverLoader.graphics_settings.ssil_intensity
	DEFAULT_ENVIRONMENT.ssil_sharpness = SaverLoader.graphics_settings.ssil_sharpness
	DEFAULT_ENVIRONMENT.ssil_normal_rejection = SaverLoader.graphics_settings.ssil_normal_rejection
	
	DEFAULT_ENVIRONMENT.glow_enabled = SaverLoader.graphics_settings.glow_enabled
	var current_level: int = 1
	for level in SaverLoader.graphics_settings.glow_levels:
		DEFAULT_ENVIRONMENT.set("glow_levels/" + str(current_level), level)
		current_level += 1
	DEFAULT_ENVIRONMENT.glow_normalized = SaverLoader.graphics_settings.glow_normalized
	DEFAULT_ENVIRONMENT.glow_intensity = SaverLoader.graphics_settings.glow_intensity
	DEFAULT_ENVIRONMENT.glow_strength = SaverLoader.graphics_settings.glow_strength
	DEFAULT_ENVIRONMENT.glow_bloom = SaverLoader.graphics_settings.glow_bloom
	DEFAULT_ENVIRONMENT.glow_blend_mode = SaverLoader.graphics_settings.glow_blend_mode
	
	DEFAULT_ENVIRONMENT.ssr_enabled = SaverLoader.graphics_settings.ssr_enabled
	
	DEFAULT_ENVIRONMENT.fog_enabled = SaverLoader.graphics_settings.fog_enabled
	DEFAULT_ENVIRONMENT.fog_mode = SaverLoader.graphics_settings.fog_mode
	DEFAULT_ENVIRONMENT.fog_light_energy = SaverLoader.graphics_settings.fog_light_energy
	DEFAULT_ENVIRONMENT.fog_sun_scatter = SaverLoader.graphics_settings.fog_sun_scatter
	DEFAULT_ENVIRONMENT.fog_density = SaverLoader.graphics_settings.fog_density
	DEFAULT_ENVIRONMENT.fog_sky_affect = SaverLoader.graphics_settings.fog_sky_affect
	DEFAULT_ENVIRONMENT.fog_height = SaverLoader.graphics_settings.fog_height
	DEFAULT_ENVIRONMENT.fog_height_density = SaverLoader.graphics_settings.fog_height_density
	DEFAULT_ENVIRONMENT.fog_depth_curve = SaverLoader.graphics_settings.fog_depth_curve
	DEFAULT_ENVIRONMENT.fog_depth_begin = SaverLoader.graphics_settings.fog_depth_begin
	DEFAULT_ENVIRONMENT.fog_depth_end = SaverLoader.graphics_settings.fog_depth_end
	
	DEFAULT_ENVIRONMENT.volumetric_fog_enabled = SaverLoader.graphics_settings.volumetric_fog_enabled
	
	DEFAULT_ENVIRONMENT.adjustment_brightness = SaverLoader.graphics_settings.brightness
	DEFAULT_ENVIRONMENT.adjustment_contrast = SaverLoader.graphics_settings.contrast
	DEFAULT_ENVIRONMENT.adjustment_saturation = SaverLoader.graphics_settings.saturation
	
	STRIPPED_ENVIRONMENT.adjustment_brightness = SaverLoader.graphics_settings.brightness
	STRIPPED_ENVIRONMENT.adjustment_contrast = SaverLoader.graphics_settings.contrast
	STRIPPED_ENVIRONMENT.adjustment_saturation = SaverLoader.graphics_settings.saturation
	
	if player_character:
		player_character.apply_graphics_settings()


func new_game() -> void:
	SaverLoader.show_loading_screen()
	
	Game.clear()
	AudioManager.clear()
	DialogueManager.clear()
	
	get_tree().paused = true
	
	await get_tree().process_frame
	
	SaverLoader.clear_temp()
	await Game.new_game()
	load_player()
	await get_tree().process_frame
	
	is_new_game = true
	SaverLoader.can_save = 0
	GameFullyLoaded.emit()
	Game.running = true
	SaverLoader.hide_loading_screen()
	
	get_tree().paused = false


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
	
	get_tree().paused = true
	
	await get_tree().process_frame
	
	load_player()
	player_character.load_save(file["player"])
	
	await Game.load_save(file["game"])
	
	await get_tree().process_frame
	SaverLoader.can_save = 0
	get_tree().paused = false
	GameFullyLoaded.emit()
	Game.running = true
	SaverLoader.hide_loading_screen()
	
	get_tree().paused = false
