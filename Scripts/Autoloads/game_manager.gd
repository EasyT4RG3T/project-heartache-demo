extends Node

const main_menu: String = "res://Scenes/Menus/MainMenu/main_menu.tscn"

var debug_overlay: DebugOverlay

var player_character: PlayerCharacter

var can_save: bool = false


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func load_chunk(dir: String) -> void:
	var chunk = load(dir)
	chunk = chunk.instantiate()
	Game.add_child(chunk)
	load_player()


func load_player() -> void:
	var player = load("res://Entities/Player/player_character.tscn")
	player = player.instantiate()
	Game.add_child(player)
	player_character = player
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	InputManager.player_character = player
	InputManager.player_character_input = true


func load_main_menu() -> void:
	if can_save:
		SaverLoader.save_game_data(0)
	
	player_character = null
	InputManager.player_character = null
	InputManager.player_character_input = false
	
	for child in Game.get_children():
		child.queue_free()
	
	var menu = load(main_menu)
	menu = menu.instantiate()
	get_tree().root.add_child(menu)


func apply_settings_data() -> void:
	DisplayServer.window_set_vsync_mode(SaverLoader.settings.vsync)
	Engine.max_fps = SaverLoader.settings.max_fps
	DisplayServer.window_set_mode(SaverLoader.settings.window_mode)
	
	if player_character:
		player_character.apply_settings()


func apply_graphics_settings_data() -> void:
	get_viewport().scaling_3d_mode = SaverLoader.graphics_settings.scaling_3d_mode
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
	RenderingServer.environment_set_ssr_roughness_quality(SaverLoader.graphics_settings.ssr_rougness_quality)
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
		player_character.main_camera.apply_settings()


func set_debug_overlay(value: int) -> void:
	if value >= 1:
		if !debug_overlay:
			debug_overlay = load("uid://be8nto6fraipm").instantiate()
			add_child(debug_overlay)
		debug_overlay.overlay_layer = value
	else:
		debug_overlay.queue_free()
		await get_tree().process_frame
		debug_overlay = null


func save(file: Dictionary) -> void:
	# save some game stats
	
	file["player"] = player_character.save()


func load_save(file: Dictionary) -> void:
	# load some game stats
	
	player_character.load_save(file["player"])
