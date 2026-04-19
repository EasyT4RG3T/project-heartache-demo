extends Control


@onready var command_line: TextEdit = %CommandLine
@onready var command_history: RichTextLabel = %CommandHistory
@onready var command_hint: RichTextLabel = %CommandHint


var previous_mouse_mode: DisplayServer.MouseMode

var command_line_history: Array[String] = []
var command_line_history_selected: int = 0

var can_hint: bool = false:
	set(value):
		can_hint = value
		if value:
			command_hint.show()
		else:
			command_hint.hide()
var hints: PackedStringArray = []
var hint_index: int = -1
var last_tokens: PackedStringArray = []


func _ready() -> void:
	hide()
	command_hint.hide()
	
	_update_hint(command_tree, [""])
	
	command_history.finished.connect(
		func():
			command_history.scroll_to_line(command_history.get_line_count() - 1)
	)


func open() -> void:
	show()
	previous_mouse_mode = DisplayServer.mouse_get_mode()
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	InputManager.console_input = true
	await get_tree().process_frame
	command_line.grab_focus()


func close() -> void:
	hide()
	DisplayServer.mouse_set_mode(previous_mouse_mode)
	get_tree().paused = false
	InputManager.console_input = false


func take_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			_on_command_line_text_submitted()
			accept_event()
			return
	
		if event.keycode == KEY_TAB:
			_hint_select()
			accept_event()
			return
	
		if event.keycode == KEY_BACKSPACE:
			await get_tree().process_frame
			await get_tree().process_frame
			can_hint = false
	
	if event.is_action_pressed("command_up"):
		if !command_line_history: return
		if command_line_history_selected <= 0: return
		command_line_history_selected -= 1
		_comman_line_history_select()
		can_hint = false
	
	if event.is_action_pressed("command_down"):
		if !command_line_history: return
		if command_line_history_selected >= command_line_history.size() - 1:
			command_line_history_selected = command_line_history.size()
			command_line.text = ""
			return
		command_line_history_selected += 1
		_comman_line_history_select()
		can_hint = false


func _on_command_line_text_changed() -> void:
	var tokens: PackedStringArray = command_line.text.split(" ", true)
	last_tokens = tokens
	if command_line.text:
		can_hint = true
	else:
		can_hint = false
	_update_hint(command_tree, tokens)


func _on_command_line_text_submitted() -> void:
	if !command_line.text: return
	_command_line_history_update(command_line.text)
	_add_command_history(_execute_command(command_line.text))
	command_line.text = ""
	command_hint.text = ""
	hints.clear()
	hint_index = -1
	last_tokens.clear()
	can_hint = false


func console_print(text: String = "[color=red]print error[/color]"):
	_add_command_history(text)


func _add_command_history(text: String) -> void:
	if !text: return
	var time: String = Time.get_time_string_from_system()
	command_history.append_text("\n" + "[color=blue][" + time + "][/color]" + "\n" + text)
	command_history.pop_all()


func _command_line_history_update(value: String) -> void:
	if command_line_history:
		if value == command_line_history.back():
			command_line_history_selected = command_line_history.size()
			return
	if command_line_history.size() > 50:
		command_line_history.pop_front()
	command_line_history.append(value)
	command_line_history_selected = command_line_history.size()


func _comman_line_history_select() -> void:
	if command_line_history_selected < 0: return
	command_line.text = command_line_history[command_line_history_selected]
	await get_tree().process_frame
	command_line.set_caret_column(command_line.text.length()) 


func _execute_command(text: String) -> String:
	var tokens: PackedStringArray = text.split(" ", false)
	
	return _process_command(command_tree, tokens)


func _process_command(tree: Dictionary, tokens: PackedStringArray) -> String:
	if !tokens:
		return "[color=yellow]incomplete command[/color]"
	
	var current = tree.get(tokens[0])
	if !current:
		return "[color=red]invalid command[/color]"
	
	if current is Array:
		if current.size() > 1:
			if current[1] is Callable:
				if tokens.size() < 2:
					return "[color=yellow]incomplete command[/color]"
				var valid = current[1].call(tokens.slice(1))
				if valid[0]:
					return current[0].call(valid[1])
				else:
					return valid[1]
			else:
				return current[0].call(current[1])
		else:
			return current[0].call()
	
	elif current is Callable:
		return current.call()
	
	elif current is Dictionary:
		return _process_command(current, tokens.slice(1))
	
	else:
		return "[color=red]invalid command[/color]"


func _update_hint(tree: Dictionary, tokens: PackedStringArray) -> void:
	command_hint.text = ""
	hints.clear()
	hint_index = -1
	
	if tokens.size() > 1:
		var current = tree.get(tokens[0])
		if current is Dictionary:
			return _update_hint(current, tokens.slice(1))
		
		elif !tokens[1] and current is Array and current[1] is Callable:
			if current[2] is Callable:
				hints.append(str(current[2].call()))
			else:
				hints.append(current[2])
		
		else:
			can_hint = false
			return
	
	if hints.is_empty():
		for key in tree.keys():
			if key.begins_with(tokens[0]):
				hints.append(key)
		
		if hints.is_empty():
			can_hint = false
			return
	
	for hint in hints:
		command_hint.text += hint + "\n"
	
	command_hint.offset_bottom = 0
	command_hint.offset_left = 0
	command_hint.offset_right = 0
	command_hint.offset_top = 0
	command_hint.position.x = command_line.get_caret_draw_pos().x


func _hint_select() -> void:
	if !can_hint:
		can_hint = true
		var tokens: PackedStringArray = command_line.text.split(" ", true)
		_update_hint(command_tree, tokens)
		return
	
	if hints.is_empty():
		return
	
	hint_index = (hint_index + 1) % hints.size()
	
	var hint = hints[hint_index]
	
	var text: String = command_line.text
	
	if last_tokens.is_empty() or last_tokens.size() == 1:
		command_line.text = hint
		command_line.set_caret_column(command_line.text.length()) 
	else:
		var previous_tokens = last_tokens.slice(0, last_tokens.size() - 1)
		command_line.text = " ".join(previous_tokens) + " " + hint
		command_line.set_caret_column(command_line.text.length()) 


var command_tree: Dictionary = {
	"run": _command_run,
	"settings": {
		"save": _command_settings_save,
		"load": _command_settings_load,
		"erase": _command_settings_erase,
		"max_fps": [_command_settings_max_fps, _need_int, func(): return Engine.max_fps],
		"vsync": {
			"disable": [_command_settings_vsync, DisplayServer.VSYNC_DISABLED],
			"enable": [_command_settings_vsync, DisplayServer.VSYNC_ENABLED],
			"adaptive": [_command_settings_vsync, DisplayServer.VSYNC_ADAPTIVE],
			"mailbox": [_command_settings_vsync, DisplayServer.VSYNC_MAILBOX],
			"get": [func(): return str(DisplayServer.window_get_vsync_mode())],
		},
		"fov": [_command_settings_fov, _need_int, func(): return SaverLoader.settings.fov],
		"window_mode": {
			"ex_fullscreen": [_command_settings_window_mode, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN],
			"fullscreen": [_command_settings_window_mode, DisplayServer.WINDOW_MODE_FULLSCREEN],
			"borderless": [_command_settings_window_mode_borderless],
			"maximized": [_command_settings_window_mode, DisplayServer.WINDOW_MODE_MAXIMIZED],
			"windowed": [_command_settings_window_mode, DisplayServer.WINDOW_MODE_WINDOWED],
			"minimized": [_command_settings_window_mode, DisplayServer.WINDOW_MODE_MINIMIZED],
			"get": [func(): return str(DisplayServer.window_get_mode())],
			},
		"sensitivity": [_command_settings_sensitivity, _need_float, func():
			return SaverLoader.settings.sensitivity],
		"hud_size": [_command_settings_hud_size, _need_float, func(): return SaverLoader.settings.hud_size],
		"subtitles": {
			"on": [_command_settings_subtitles, true],
			"off": [_command_settings_subtitles, false],
		},
	},
	"graphics": {
		"save": _command_graphics_save,
		"load": {
			"user": [_command_graphics_load, 0],
			"low": [_command_graphics_load, 1],
			"medium": [_command_graphics_load, 2],
			"high": [_command_graphics_load, 3],
		},
		"erase": _command_graphics_erase,
		"3d_scale_mode": {
			"bilinear": [_command_graphics_3d_scale_mode, Viewport.SCALING_3D_MODE_BILINEAR],
			"fsr": [_command_graphics_3d_scale_mode, Viewport.SCALING_3D_MODE_FSR],
			"fsr2": [_command_graphics_3d_scale_mode, Viewport.SCALING_3D_MODE_FSR2],
			"max": [_command_graphics_3d_scale_mode, Viewport.SCALING_3D_MODE_MAX],
			"get": [func(): return str(get_viewport().scaling_3d_mode)]
		},
		"3d_scale": [_command_graphics_3d_scale, _need_float,
		func(): return str(get_viewport().scaling_3d_scale)],
		"anti_aliasing": {
			"2d_msaa": {
				"disabled": [_command_graphics_anti_aliasing_2d_msaa, Viewport.MSAA_DISABLED],
				"2x": [_command_graphics_anti_aliasing_2d_msaa, Viewport.MSAA_2X],
				"4x": [_command_graphics_anti_aliasing_2d_msaa, Viewport.MSAA_4X],
				"8x": [_command_graphics_anti_aliasing_2d_msaa, Viewport.MSAA_8X],
				"max": [_command_graphics_anti_aliasing_2d_msaa, Viewport.MSAA_MAX],
				"get": [func(): return str(get_viewport().msaa_2d)]
			},
			"3d_msaa": {
				"disabled": [_command_graphics_anti_aliasing_3d_msaa, Viewport.MSAA_DISABLED],
				"2x": [_command_graphics_anti_aliasing_3d_msaa, Viewport.MSAA_2X],
				"4x": [_command_graphics_anti_aliasing_3d_msaa, Viewport.MSAA_4X],
				"8x": [_command_graphics_anti_aliasing_3d_msaa, Viewport.MSAA_8X],
				"max": [_command_graphics_anti_aliasing_3d_msaa, Viewport.MSAA_MAX],
				"get": [func(): return str(get_viewport().msaa_3d)]
			},
			"ssaa": {
				"disabled": [_command_graphics_anti_aliasing_ssaa, Viewport.SCREEN_SPACE_AA_DISABLED],
				"fxaa": [_command_graphics_anti_aliasing_ssaa, Viewport.SCREEN_SPACE_AA_FXAA],
				"smaa": [_command_graphics_anti_aliasing_ssaa, Viewport.SCREEN_SPACE_AA_SMAA],
				"get": [func(): return str(get_viewport().screen_space_aa)],
			},
			"taa": {
				"disabled": [_command_graphics_anti_aliasing_taa, false],
				"enabled": [_command_graphics_anti_aliasing_taa, true],
				"get": [func(): return str(get_viewport().use_taa)],
			},
			"debanding": {
				"disabled": [_command_graphics_anti_aliasing_debanding, false],
				"enabled": [_command_graphics_anti_aliasing_debanding, true],
				"get": [func(): return str(get_viewport().use_debanding)],
			},
		},
		"tonemap": {
			"mode": {
				"linear": [_command_graphics_tonemap_mode, Environment.TONE_MAPPER_LINEAR],
				"reinhard": [_command_graphics_tonemap_mode, Environment.TONE_MAPPER_REINHARDT],
				"filmic": [_command_graphics_tonemap_mode, Environment.TONE_MAPPER_FILMIC],
				"aces": [_command_graphics_tonemap_mode, Environment.TONE_MAPPER_ACES],
				"agx": [_command_graphics_tonemap_mode, Environment.TONE_MAPPER_AGX],
				"get": [func(): return str(SaverLoader.graphics_settings.tonemap_mode)],
			},
			"exposure": [_command_graphics_tonemap_exposure, _need_float, func():
				return str(SaverLoader.graphics_settings.tonemap_exposure)],
			"white": [_command_graphics_tonemap_white, _need_float, func():
				return str(SaverLoader.graphics_settings.tonemap_white)],
		},
		"ssao": {
			"enable": [_command_graphics_ssao_enabled, true],
			"disable": [_command_graphics_ssao_enabled, false],
			"get": [func(): return str(SaverLoader.graphics_settings.ssao_enabled)],
			"radius": [_command_graphics_ssao_radius, _need_float, func():
				return str(SaverLoader.graphics_settings.ssao_radius)],
			"intensity": [_command_graphics_ssao_intensity, _need_float, func():
				return str(SaverLoader.graphics_settings.ssao_intensity)],
			"power": [_command_graphics_ssao_power, _need_float, func():
				return str(SaverLoader.graphics_settings.ssao_power)],
			"detail": [_command_graphics_ssao_detail, _need_float, func():
				return str(SaverLoader.graphics_settings.ssao_detail)],
			"horizon": [_command_graphics_ssao_horizon, _need_float, func():
				return str(SaverLoader.graphics_settings.ssao_horizon)],
			"sharpness": [_command_graphics_ssao_sharpness, _need_float, func():
				return str(SaverLoader.graphics_settings.ssao_sharpness)],
			"light_affect": [_command_graphics_ssao_light_affect, _need_float, func():
				return str(SaverLoader.graphics_settings.ssao_light_affect)],
			"ao_channel_affect": [_command_graphics_ssao_ao_channel_affect, _need_float, func():
				return str(SaverLoader.graphics_settings.ssao_ao_channel_affect)],
			"quality": {
				"very_low": [_command_graphics_ssao_quality, RenderingServer.ENV_SSAO_QUALITY_VERY_LOW],
				"low": [_command_graphics_ssao_quality, RenderingServer.ENV_SSAO_QUALITY_LOW],
				"medium": [_command_graphics_ssao_quality, RenderingServer.ENV_SSAO_QUALITY_MEDIUM],
				"high": [_command_graphics_ssao_quality, RenderingServer.ENV_SSAO_QUALITY_HIGH],
				"ultra": [_command_graphics_ssao_quality, RenderingServer.ENV_SSAO_QUALITY_ULTRA],
				"get": [func(): return str(SaverLoader.graphics_settings.ssao_quality)]
			},
			"half_size": {
				"on": [_command_graphics_ssao_half_size, true],
				"off": [_command_graphics_ssao_half_size, false],
				"get": [func(): return str(SaverLoader.graphics_settings.ssao_half_size)],
			},
			"adaptive_target": [_command_graphics_ssao_adaptive_target, _need_float, func():
				return str(SaverLoader.graphics_settings.ssil_adaptive_target)],
			"blur_passes": [_command_graphics_ssao_blur_passes, _need_int, func():
				return str(SaverLoader.graphics_settings.ssao_blur_passes)],
			"fadeout_from": [_command_graphics_ssao_fadeout_from, _need_float, func():
				return str(SaverLoader.graphics_settings.ssao_fadeout_from)],
			"fadeout_to": [_command_graphics_ssao_fadeout_to, _need_float, func():
				return str(SaverLoader.graphics_settings.ssao_fadeout_to)],
		},
		"ssil": {
			"enable": [_command_graphics_ssil_enabled, true],
			"disable": [_command_graphics_ssil_enabled, false],
			"get": [func(): return str(SaverLoader.graphics_settings.ssil_enabled)],
			"radius": [_command_graphics_ssil_radius, _need_float, func():
				return str(SaverLoader.graphics_settings.ssil_radius)],
			"intensity": [_command_graphics_ssil_intensity, _need_float, func():
				return str(SaverLoader.graphics_settings.ssil_intensity)],
			"sharpness": [_command_graphics_ssil_sharpness, _need_float, func():
				return str(SaverLoader.graphics_settings.ssil_sharpness)],
			"normal_rejection": [_command_graphics_ssil_normal_rejection, _need_float, func():
				return str(SaverLoader.graphics_settings.ssil_normal_rejection)],
			"quality": {
				"very_low": [_command_graphics_ssil_quality, RenderingServer.ENV_SSIL_QUALITY_VERY_LOW],
				"low": [_command_graphics_ssil_quality, RenderingServer.ENV_SSIL_QUALITY_LOW],
				"medium": [_command_graphics_ssil_quality, RenderingServer.ENV_SSIL_QUALITY_MEDIUM],
				"high": [_command_graphics_ssil_quality, RenderingServer.ENV_SSIL_QUALITY_HIGH],
				"ultra": [_command_graphics_ssil_quality, RenderingServer.ENV_SSIL_QUALITY_ULTRA],
				"get": [func(): return str(SaverLoader.graphics_settings.ssil_quality)]
			},
			"half_size": {
				"on": [_command_graphics_ssil_half_size, true],
				"off": [_command_graphics_ssil_half_size, false],
				"get": [func(): return str(SaverLoader.graphics_settings.ssil_half_size)],
			},
			"adaptive_target": [_command_graphics_ssil_adaptive_target, _need_float, func():
				return str(SaverLoader.graphics_settings.ssil_adaptive_target)],
			"blur_passes": [_command_graphics_ssil_blur_passes, _need_int, func():
				return str(SaverLoader.graphics_settings.ssil_blur_passes)],
			"fadeout_from": [_command_graphics_ssil_fadeout_from, _need_float, func():
				return str(SaverLoader.graphics_settings.ssil_fadeout_from)],
			"fadeout_to": [_command_graphics_ssil_fadeout_to, _need_float, func():
				return str(SaverLoader.graphics_settings.ssil_fadeout_to)],
		},
		"glow": {
			"enable": [_command_graphics_glow_enabled, true],
			"disable": [_command_graphics_glow_enabled, false],
			"get": [func(): return str(SaverLoader.graphics_settings.glow_enabled)],
			"levels": [_command_graphics_glow_levels, func(tokens: PackedStringArray):
				if tokens.size() < 7:
					return [false, "[color=red]must contain 7 values[/color]"]
				var levels: Array[float]
				for i in 7:
					if !tokens[i].is_valid_float():
						return [false, "[color=red]value " + str(i+1) + " isn't a valid float[/color]"]
					levels.append(tokens[i].to_float())
				return [true, levels],
				func(): return str(SaverLoader.graphics_settings.glow_levels)],
			"upscale_mode": {
				"linear": [_command_graphics_glow_upscale_mode, false],
				"bicubic": [_command_graphics_glow_upscale_mode, true],
				"get": [func(): return str(SaverLoader.graphics_settings.glow_upscale_mode)],
			},
			"normalized": {
				"on": [_command_graphics_glow_normalized, true],
				"off": [_command_graphics_glow_normalized, false],
				"get": [func(): return str(SaverLoader.graphics_settings.glow_normalized)],
			},
			"intensity": [_command_graphics_glow_intensity, _need_float, func():
				return str(SaverLoader.graphics_settings.glow_intensity)],
			"strength": [_command_graphics_glow_strength, _need_float, func():
				return str(SaverLoader.graphics_settings.glow_strength)],
			"bloom": [_command_graphics_glow_bloom, _need_float, func():
				return str(SaverLoader.graphics_settings.glow_bloom)],
			"blend_mode": {
				"additive": [_command_graphics_glow_blend_mode, Environment.GLOW_BLEND_MODE_ADDITIVE],
				"screen": [_command_graphics_glow_blend_mode, Environment.GLOW_BLEND_MODE_SCREEN],
				"softlight": [_command_graphics_glow_blend_mode, Environment.GLOW_BLEND_MODE_SOFTLIGHT],
				"replace": [_command_graphics_glow_blend_mode, Environment.GLOW_BLEND_MODE_REPLACE],
				"mix": [_command_graphics_glow_blend_mode, Environment.GLOW_BLEND_MODE_MIX],
				"get": [func(): return str(SaverLoader.graphics_settings.glow_blend_mode)],
			},
		},
		"ssr": {
			"enable": [_command_graphics_ssr_enabled, true],
			"disable": [_command_graphics_ssr_enabled, false],
			"get": [func(): return str(SaverLoader.graphics_settings.ssr_enabled)],
			"roughness_quality": {
				"disabled": [_command_graphics_ssr_roughness_quality,
				RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_DISABLED],
				"low": [_command_graphics_ssr_roughness_quality,
				RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_LOW],
				"medium": [_command_graphics_ssr_roughness_quality,
				RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_MEDIUM],
				"high": [_command_graphics_ssr_roughness_quality,
				RenderingServer.ENV_SSR_ROUGHNESS_QUALITY_HIGH],
				"get": [func(): return str(SaverLoader.graphics_settings.ssr_rougness_quality)],
			},
		},
		"subsurface_scattering": {
			"quality": {
				"disabled": [_command_graphics_sss_quality,
				RenderingServer.SUB_SURFACE_SCATTERING_QUALITY_DISABLED],
				"low": [_command_graphics_sss_quality,
				RenderingServer.SUB_SURFACE_SCATTERING_QUALITY_LOW],
				"medium": [_command_graphics_sss_quality,
				RenderingServer.SUB_SURFACE_SCATTERING_QUALITY_MEDIUM],
				"high": [_command_graphics_sss_quality,
				RenderingServer.SUB_SURFACE_SCATTERING_QUALITY_HIGH],
				"get": [func(): return str(SaverLoader.graphics_settings.sss_quality)],
			},
			"scale": [_command_graphics_sss_scale, _need_float, func():
				return str(SaverLoader.graphics_settings.sss_scale)],
			"depth_scale": [_command_graphics_sss_depth_scale, _need_float, func():
				return str(SaverLoader.graphics_settings.sss_depth_scale)],
		},
		"fog": {
			"enable": [_command_graphics_fog_enabled, true],
			"disable": [_command_graphics_fog_enabled, false],
			"get": [func(): return str(SaverLoader.graphics_settings.fog_enabled)],
			"mode": {
				"exponential": [_command_graphics_fog_mode, Environment.FOG_MODE_EXPONENTIAL],
				"depth": [_command_graphics_fog_mode, Environment.FOG_MODE_DEPTH],
				"get": [func(): return str(SaverLoader.graphics_settings.fog_mode)],
			},
			"light_energy": [_command_graphics_fog_light_energy, _need_float, func():
				return str(SaverLoader.graphics_settings.fog_light_energy)],
			"sun_scatter": [_command_graphics_fog_sun_scatter, _need_float, func():
				return str(SaverLoader.graphics_settings.fog_sun_scatter)],
			"density": [_command_graphics_fog_density, _need_float, func():
				return str(SaverLoader.graphics_settings.fog_density)],
			"sky_affect": [_command_graphics_fog_sky_affect, _need_float, func():
				return str(SaverLoader.graphics_settings.fog_sky_affect)],
			"height": [_command_graphics_fog_height, _need_float, func():
				return str(SaverLoader.graphics_settings.fog_height)],
			"height_density": [_command_graphics_fog_height_density, _need_float, func():
				return str(SaverLoader.graphics_settings.fog_height_density)],
			"depth_curve": [_command_graphics_fog_depth_curve, _need_float, func():
				return str(SaverLoader.graphics_settings.fog_depth_curve)],
			"depth_begin": [_command_graphics_fog_depth_begin, _need_float, func():
				return str(SaverLoader.graphics_settings.fog_depth_begin)],
			"depth_end": [_command_graphics_fog_depth_end, _need_float, func():
				return str(SaverLoader.graphics_settings.fog_depth_end)],
		},
		"volumetric_fog": {
			"enable": [_command_graphics_volumetric_fog_enabled, true],
			"disable": [_command_graphics_volumetric_fog_enabled, false],
			"get": [func(): return str(SaverLoader.graphics_settings.volumetric_fog_enabled)],
			"volume_size": [_command_graphics_volumetric_fog_volume_size, _need_int, func():
				return str(SaverLoader.graphics_settings.volumetric_fog_volume_size)],
			"volume_depth": [_command_graphics_volumetric_fog_volume_depth, _need_int, func():
				return str(SaverLoader.graphics_settings.volumetric_fog_volume_depth)],
			"use_filter": {
				"on": [_command_graphics_volumetric_fog_use_filter, true],
				"off": [_command_graphics_volumetric_fog_use_filter, false],
				"get": [func(): return str(SaverLoader.graphics_settings.volumetric_fog_volume_use_filter)],
			},
			"density": [_command_graphics_volumetric_fog_density, _need_float, func():
				if GameManager.player_character:
					return GameManager.player_character.main_camera.environment.volumetric_fog_density
				else:
					return "no player"],
		},
		"brightness": [_command_graphics_brightness, _need_float, func():
			return str(SaverLoader.graphics_settings.brightness)],
		"contrast": [_command_graphics_contrast, _need_float, func():
			return str(SaverLoader.graphics_settings.contrast)],
		"saturation": [_command_graphics_saturation, _need_float, func():
			return str(SaverLoader.graphics_settings.saturation)],
		"smooth_lights": _command_graphics_smooth_lights,
		"directional_shadow": {
			"size": [_command_graphics_directional_shadow_size, _need_int, func():
				return str(SaverLoader.graphics_settings.directional_shadow_size)],
			"quality": {
				"hard": [_command_graphics_directional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_HARD],
				"very_low": [_command_graphics_directional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW],
				"low": [_command_graphics_directional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_SOFT_LOW],
				"medium": [_command_graphics_directional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM],
				"high": [_command_graphics_directional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_SOFT_HIGH],
				"ultra": [_command_graphics_directional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_SOFT_ULTRA],
				"get": [func(): return str(SaverLoader.graphics_settings.directional_shadow_quality)],
			},
		},
		"positional_shadow": {
			"size": [_command_graphics_positional_shadow_size, _need_int, func():
				return str(SaverLoader.graphics_settings.positional_shadow_size)],
			"quality": {
				"hard": [_command_graphics_positional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_HARD],
				"very_low": [_command_graphics_positional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW],
				"low": [_command_graphics_positional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_SOFT_LOW],
				"medium": [_command_graphics_positional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM],
				"high": [_command_graphics_positional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_SOFT_HIGH],
				"ultra": [_command_graphics_positional_shadow_quality,
				RenderingServer.SHADOW_QUALITY_SOFT_ULTRA],
				"get": [func(): return str(SaverLoader.graphics_settings.positional_shadow_quality)],
			},
			"bit": {
				"16": [_command_graphics_positional_shadow_16_bit, true],
				"32": [_command_graphics_positional_shadow_16_bit, false],
			},
		},
		"reduce_particles": {
			"true": [_command_graphics_reduce_particles, true],
			"false": [_command_graphics_reduce_particles, false],
		},
	},
	"game": {
		"save": [_command_game_save, _need_string, "slot"],
		"load": [_command_game_load, _need_string, "slot"],
		"erase": [_command_game_erase, _need_string, "slot"],
	},
	"player": {
		"fly": _command_player_fly,
		"fly_collision": _command_player_fly_collision,
		"flashlight": _command_player_flashlight,
		"screwdriver": _command_player_screwdriver,
		"speed": [_command_player_speed, _need_float, func():
			if GameManager.player_character:
				return str(GameManager.player_character.current_movement_speed)
			else:
				return "0"],
		"tp": [_command_player_tp, _need_vector3, func():
			if GameManager.player_character:
				return str(GameManager.player_character.global_position)
			else:
				return "0"],
	},
	"engine": {
		"speed": [_command_engine_speed, _need_float, func(): return str(Engine.time_scale)],
	},
	"system": {
		"quit": _command_system_quit,
		"debug": {
			"overlay": [_command_system_debug_overlay, _need_int, func():
				if GameManager.debug_overlay:
					return str(GameManager.debug_overlay.overlay_layer)
				else:
					return "0"],
			"full_bright": _command_debug_full_bright,
			"vault": _command_system_debug_vault,
			"crawl": _command_system_debug_crawl,
		},
		"say": [_command_system_say, _need_string, "text"],
	}
}


func _need_int(tokens: PackedStringArray) -> Array:
	if !tokens[0].is_valid_int():
		return [false, "[color=red]must be valid int[/color]"]
	else:
		return [true, tokens[0].to_int()]

func _need_float(tokens: PackedStringArray) -> Array:
	if !tokens[0].is_valid_float():
		return [false, "[color=red]must be valid float[/color]"]
	else:
		return [true, tokens[0].to_float()]

func _need_vector3(tokens: PackedStringArray) -> Array:
	if tokens.size() < 3:
		return [false, "[color=red]must contain values for x, y and z[/color]"]
	
	for i in 3:
		if !tokens[i].is_valid_float():
			return [false, "[color=red]value" + str(i+1) + "isn't a valid float[/color]"]
	
	var vec = Vector3(tokens[0].to_float(),tokens[1].to_float(),tokens[2].to_float())
	return [true, vec]

func _need_string(tokens: PackedStringArray) -> Array:
	if tokens[0].is_empty():
		return [false, "[color=red]needs string[/color]"]
	else:
		var string: String = ""
		for token in tokens.size():
			string += tokens[token] + " "
		string.trim_suffix(" ")
		return [true, string]


func _command_run() -> String:
	return "run"

func _command_settings_save() -> String:
	SaverLoader.save_settings()
	return "saving personal settings"

func _command_settings_load() -> String:
	SaverLoader.load_settings()
	return "loading personal settings"

func _command_settings_erase() -> String:
	SaverLoader.erase_settings()
	return "erasing personal settings"

func _command_settings_max_fps(value: int) -> String:
	SaverLoader.settings.max_fps = value
	Engine.max_fps = value
	return "set max fps to " + str(value)

func _command_settings_vsync(value: DisplayServer.VSyncMode) -> String:
	SaverLoader.settings.vsync = value
	DisplayServer.window_set_vsync_mode(value)
	return "set vsync mode to " + str(value)

func _command_settings_fov(value: int) -> String:
	SaverLoader.settings.fov = value
	var player: PlayerCharacter = get_tree().get_first_node_in_group("PlayerCharacter")
	if player:
		player.main_camera.fov = value
	return "set fov to " + str(value)

func _command_settings_window_mode(value: DisplayServer.WindowMode) -> String:
	SaverLoader.settings.window_mode = value
	DisplayServer.window_set_mode(value)
	return "set window mode to " + str(value)

func _command_settings_window_mode_borderless() -> String:
	if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS):
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	return "set borderless to " + str(DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS))

func _command_settings_sensitivity(value: float) -> String:
	SaverLoader.settings.sensitivity = value
	if GameManager.player_character:
		GameManager.player_character.mouse_sensitivity = value
	return "set mouse sensitivity to " + str(value)

func _command_settings_hud_size(value: float) -> String:
	SaverLoader.settings.hud_size = value
	if GameManager.player_character:
		GameManager.player_character.player_hud.apply_settings()
	return "set hud size to " + str(value)

func _command_settings_static_shader(value: bool) -> String:
	SaverLoader.settings.static_shader = value
	if GameManager.player_character:
		GameManager.player_character.shader.material.set_shader_parameter("static_enabled", value)
	return "set static shader to " + str(value)

func _command_settings_head_bob(value: bool) -> String:
	SaverLoader.settings.head_bob = value
	if GameManager.player_character:
		GameManager.player_character.do_bob = value
	return "set head bob to " + str(value)

func _command_settings_subtitles(value: bool) -> String:
	SaverLoader.settings.subtitles = value
	if GameManager.player_character:
		GameManager.player_character.player_hud.apply_settings()
	return "set subtitles to " + str(value)

func _command_graphics_save() -> String:
	SaverLoader.save_graphics_settings()
	return "saving graphics settings"

func _command_graphics_load(value: int) -> String:
	SaverLoader.load_graphics_settings(value)
	return "loading graphics settings " + str(value)

func _command_graphics_erase() -> String:
	SaverLoader.erase_graphics_settings()
	return "erasing user graphics settings"

func _command_graphics_3d_scale_mode(value: Viewport.Scaling3DMode) -> String:
	SaverLoader.graphics_settings.scaling_3d_mode = value
	get_viewport().scaling_3d_mode = value
	return "set 3d scaling mode to " + str(value)

func _command_graphics_3d_scale(value: float) -> String:
	SaverLoader.graphics_settings.scaling_3d_scale = value
	get_viewport().scaling_3d_scale = value
	return "set 3d scale to " + str(value)

func _command_graphics_anti_aliasing_2d_msaa(value: Viewport.MSAA) -> String:
	SaverLoader.graphics_settings.msaa_2d = value
	get_viewport().msaa_2d = value
	return "set 2d msaa to " + str(value)

func _command_graphics_anti_aliasing_3d_msaa(value: Viewport.MSAA) -> String:
	SaverLoader.graphics_settings.msaa_3d = value
	get_viewport().msaa_3d = value
	return "set 3d msaa to " + str(value)

func _command_graphics_anti_aliasing_ssaa(value: Viewport.ScreenSpaceAA) -> String:
	SaverLoader.graphics_settings.ssaa = value
	get_viewport().screen_space_aa = value
	return "set screen space aa to " + str(value)

func _command_graphics_anti_aliasing_taa(value: bool) -> String:
	SaverLoader.graphics_settings.taa = value
	get_viewport().use_taa = value
	return "set taa to " + str(value)

func _command_graphics_anti_aliasing_debanding(value: bool) -> String:
	SaverLoader.graphics_settings.debanding = value
	get_viewport().use_debanding = value
	return "set debanding to " + str(value)

func _command_graphics_tonemap_mode(value: Environment.ToneMapper) -> String:
	SaverLoader.graphics_settings.tonemap_mode = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.tonemap_mode = value
	return "set tonemap to " + str(value)

func _command_graphics_tonemap_exposure(value: float) -> String:
	SaverLoader.graphics_settings.tonemap_exposure = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.tonemap_exposure = value
	return "set tonemap exposure to " + str(value)

func _command_graphics_tonemap_white(value: float) -> String:
	SaverLoader.graphics_settings.tonemap_white = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.tonemap_white = value
	return "set tonemap white to " + str(value)

func _command_graphics_ssao_enabled(value: bool) -> String:
	SaverLoader.graphics_settings.ssao_enabled = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssao_enabled = value
	return "set ssao enabled to " + str(value)

func _command_graphics_ssao_radius(value: float) -> String:
	SaverLoader.graphics_settings.ssao_radius = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssao_radius = value
	return "set ssao radius to " + str(value)

func _command_graphics_ssao_intensity(value: float) -> String:
	SaverLoader.graphics_settings.ssao_intensity = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssao_intensity = value
	return "set ssao intensity to " + str(value)

func _command_graphics_ssao_power(value: float) -> String:
	SaverLoader.graphics_settings.ssao_power = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssao_power = value
	return "set ssao power to " + str(value)

func _command_graphics_ssao_detail(value: float) -> String:
	SaverLoader.graphics_settings.ssao_detail = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssao_detail = value
	return "set ssao detail to " + str(value)

func _command_graphics_ssao_horizon(value: float) -> String:
	SaverLoader.graphics_settings.ssao_horizon = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssao_horizon = value
	return "set ssao horizon to " + str(value)

func _command_graphics_ssao_sharpness(value: float) -> String:
	SaverLoader.graphics_settings.ssao_sharpness = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssao_sharpness = value
	return "set ssao sharpness to " + str(value)

func _command_graphics_ssao_light_affect(value: float) -> String:
	SaverLoader.graphics_settings.ssao_light_affect = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssao_light_affect = value
	return "set ssao light affect to " + str(value)

func _command_graphics_ssao_ao_channel_affect(value: float) -> String:
	SaverLoader.graphics_settings.ssao_ao_channel_affect = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssao_ao_channel_affect = value
	return "set ssao ao channel affect to " + str(value)

func _command_graphics_ssao_quality(value: RenderingServer.EnvironmentSSAOQuality) -> String:
	SaverLoader.graphics_settings.ssao_quality = value
	RenderingServer.environment_set_ssao_quality(
		SaverLoader.graphics_settings.ssao_quality,
		SaverLoader.graphics_settings.ssao_half_size,
		SaverLoader.graphics_settings.ssao_adaptive_target,
		SaverLoader.graphics_settings.ssao_blur_passes,
		SaverLoader.graphics_settings.ssao_fadeout_from,
		SaverLoader.graphics_settings.ssao_fadeout_to
	)
	return "set ssao quality to " + str(value)

func _command_graphics_ssao_half_size(value: bool) -> String:
	SaverLoader.graphics_settings.ssao_half_size = value
	RenderingServer.environment_set_ssao_quality(
		SaverLoader.graphics_settings.ssao_quality,
		SaverLoader.graphics_settings.ssao_half_size,
		SaverLoader.graphics_settings.ssao_adaptive_target,
		SaverLoader.graphics_settings.ssao_blur_passes,
		SaverLoader.graphics_settings.ssao_fadeout_from,
		SaverLoader.graphics_settings.ssao_fadeout_to
	)
	return "set half size to " + str(value)

func _command_graphics_ssao_adaptive_target(value: float) -> String:
	SaverLoader.graphics_settings.ssao_adaptive_target = value
	RenderingServer.environment_set_ssao_quality(
		SaverLoader.graphics_settings.ssao_quality,
		SaverLoader.graphics_settings.ssao_half_size,
		SaverLoader.graphics_settings.ssao_adaptive_target,
		SaverLoader.graphics_settings.ssao_blur_passes,
		SaverLoader.graphics_settings.ssao_fadeout_from,
		SaverLoader.graphics_settings.ssao_fadeout_to
	)
	
	return "set adaptive target to " + str(value)

func _command_graphics_ssao_blur_passes(value: int) -> String:
	SaverLoader.graphics_settings.ssao_blur_passes = value
	RenderingServer.environment_set_ssao_quality(
		SaverLoader.graphics_settings.ssao_quality,
		SaverLoader.graphics_settings.ssao_half_size,
		SaverLoader.graphics_settings.ssao_adaptive_target,
		SaverLoader.graphics_settings.ssao_blur_passes,
		SaverLoader.graphics_settings.ssao_fadeout_from,
		SaverLoader.graphics_settings.ssao_fadeout_to
	)
	return "set blur passes to " + str(value)

func _command_graphics_ssao_fadeout_from(value: float) -> String:
	SaverLoader.graphics_settings.ssao_fadeout_from = value
	RenderingServer.environment_set_ssao_quality(
		SaverLoader.graphics_settings.ssao_quality,
		SaverLoader.graphics_settings.ssao_half_size,
		SaverLoader.graphics_settings.ssao_adaptive_target,
		SaverLoader.graphics_settings.ssao_blur_passes,
		SaverLoader.graphics_settings.ssao_fadeout_from,
		SaverLoader.graphics_settings.ssao_fadeout_to
	)
	return "set fadeout_from to " + str(value)

func _command_graphics_ssao_fadeout_to(value: float) -> String:
	SaverLoader.graphics_settings.ssao_fadeout_to = value
	RenderingServer.environment_set_ssao_quality(
		SaverLoader.graphics_settings.ssao_quality,
		SaverLoader.graphics_settings.ssao_half_size,
		SaverLoader.graphics_settings.ssao_adaptive_target,
		SaverLoader.graphics_settings.ssao_blur_passes,
		SaverLoader.graphics_settings.ssao_fadeout_from,
		SaverLoader.graphics_settings.ssao_fadeout_to
	)
	return "set fadeout_to to " + str(value)

func _command_graphics_ssil_enabled(value: bool) -> String:
	SaverLoader.graphics_settings.ssil_enabled = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssil_enabled = value
	return "set ssil enabled to " + str(value)

func _command_graphics_ssil_radius(value: float) -> String:
	SaverLoader.graphics_settings.ssil_radius = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssil_radius = value
	return "set ssil radius to " + str(value)

func _command_graphics_ssil_intensity(value: float) -> String:
	SaverLoader.graphics_settings.ssil_intensity = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssil_intensity = value
	return "set ssil intensity to " + str(value)

func _command_graphics_ssil_sharpness(value: float) -> String:
	SaverLoader.graphics_settings.ssil_sharpness = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssil_sharpness = value
	return "set ssil sharpness to " + str(value)

func _command_graphics_ssil_normal_rejection(value: float) -> String:
	SaverLoader.graphics_settings.ssil_normal_rejection = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssil_normal_rejection = value
	return "set ssil normal rejection to " + str(value)

func _command_graphics_ssil_quality(value: RenderingServer.EnvironmentSSILQuality) -> String:
	SaverLoader.graphics_settings.ssil_quality = value
	RenderingServer.environment_set_ssil_quality(
		SaverLoader.graphics_settings.ssil_quality,
		SaverLoader.graphics_settings.ssil_half_size,
		SaverLoader.graphics_settings.ssil_adaptive_target,
		SaverLoader.graphics_settings.ssil_blur_passes,
		SaverLoader.graphics_settings.ssil_fadeout_from,
		SaverLoader.graphics_settings.ssil_fadeout_to
	)
	return "set ssil quality to " + str(value)

func _command_graphics_ssil_half_size(value: bool) -> String:
	SaverLoader.graphics_settings.ssil_half_size = value
	RenderingServer.environment_set_ssil_quality(
		SaverLoader.graphics_settings.ssil_quality,
		SaverLoader.graphics_settings.ssil_half_size,
		SaverLoader.graphics_settings.ssil_adaptive_target,
		SaverLoader.graphics_settings.ssil_blur_passes,
		SaverLoader.graphics_settings.ssil_fadeout_from,
		SaverLoader.graphics_settings.ssil_fadeout_to
	)
	return "set half size to " + str(value)

func _command_graphics_ssil_adaptive_target(value: float) -> String:
	SaverLoader.graphics_settings.ssil_adaptive_target = value
	RenderingServer.environment_set_ssil_quality(
		SaverLoader.graphics_settings.ssil_quality,
		SaverLoader.graphics_settings.ssil_half_size,
		SaverLoader.graphics_settings.ssil_adaptive_target,
		SaverLoader.graphics_settings.ssil_blur_passes,
		SaverLoader.graphics_settings.ssil_fadeout_from,
		SaverLoader.graphics_settings.ssil_fadeout_to
	)
	return "set adaptive target to " + str(value)

func _command_graphics_ssil_blur_passes(value: int) -> String:
	SaverLoader.graphics_settings.ssil_blur_passes = value
	RenderingServer.environment_set_ssil_quality(
		SaverLoader.graphics_settings.ssil_quality,
		SaverLoader.graphics_settings.ssil_half_size,
		SaverLoader.graphics_settings.ssil_adaptive_target,
		SaverLoader.graphics_settings.ssil_blur_passes,
		SaverLoader.graphics_settings.ssil_fadeout_from,
		SaverLoader.graphics_settings.ssil_fadeout_to
	)
	return "set blur passes to " + str(value)

func _command_graphics_ssil_fadeout_from(value: float) -> String:
	SaverLoader.graphics_settings.ssil_fadeout_from = value
	RenderingServer.environment_set_ssil_quality(
		SaverLoader.graphics_settings.ssil_quality,
		SaverLoader.graphics_settings.ssil_half_size,
		SaverLoader.graphics_settings.ssil_adaptive_target,
		SaverLoader.graphics_settings.ssil_blur_passes,
		SaverLoader.graphics_settings.ssil_fadeout_from,
		SaverLoader.graphics_settings.ssil_fadeout_to
	)
	return "set fadeout_from to " + str(value)

func _command_graphics_ssil_fadeout_to(value: float) -> String:
	SaverLoader.graphics_settings.ssil_fadeout_to = value
	RenderingServer.environment_set_ssil_quality(
		SaverLoader.graphics_settings.ssil_quality,
		SaverLoader.graphics_settings.ssil_half_size,
		SaverLoader.graphics_settings.ssil_adaptive_target,
		SaverLoader.graphics_settings.ssil_blur_passes,
		SaverLoader.graphics_settings.ssil_fadeout_from,
		SaverLoader.graphics_settings.ssil_fadeout_to
	)
	return "set fadeout_to to " + str(value)

func _command_graphics_glow_enabled(value: bool) -> String:
	SaverLoader.graphics_settings.glow_enabled = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.glow_enabled = value
	return "set glow enable to " + str(value)

func _command_graphics_glow_levels(value: Array[float]) -> String:
	SaverLoader.graphics_settings.glow_levels = value
	if GameManager.player_character:
		var current_level: int = 1
		for level in value:
			GameManager.player_character.main_camera.environment.set\
			("glow_levels/" + str(current_level), level)
			current_level += 1
	return "set glow levels to: " + str(SaverLoader.graphics_settings.glow_levels)

func _command_graphics_glow_upscale_mode(value: bool) -> String:
	SaverLoader.graphics_settings.glow_upscale_mode = value
	RenderingServer.environment_glow_set_use_bicubic_upscale(value)
	return "set glow upscale mode to " + str(value)

func _command_graphics_glow_normalized(value: bool) -> String:
	SaverLoader.graphics_settings.glow_normalized = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.glow_normalized = value
	return "set glow normalized to " + str(value)

func _command_graphics_glow_intensity(value: float) -> String:
	SaverLoader.graphics_settings.glow_intensity = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.glow_intensity = value
	return "set glow intensity to " + str(value)

func _command_graphics_glow_strength(value: float) -> String:
	SaverLoader.graphics_settings.glow_strength = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.glow_strength = value
	return "set glow strength to " + str(value)

func _command_graphics_glow_bloom(value: float) -> String:
	SaverLoader.graphics_settings.glow_bloom = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.glow_bloom = value
	return "set glow bloom to " + str(value)

func _command_graphics_glow_blend_mode(value: Environment.GlowBlendMode) -> String:
	SaverLoader.graphics_settings.glow_blend_mode = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.glow_blend_mode = value
	return "set glow blend mode to " + str(value)

func _command_graphics_ssr_enabled(value: bool) -> String:
	SaverLoader.graphics_settings.ssr_enabled = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.ssr_enabled = value
	return "set ssr enabled to " + str(value)

func _command_graphics_ssr_roughness_quality(value: RenderingServer.EnvironmentSSRRoughnessQuality) -> String:
	SaverLoader.graphics_settings.ssr_rougness_quality = value
	RenderingServer.environment_set_ssr_roughness_quality(value)
	return "set ssr roughness quality to " + str(value)

func _command_graphics_sss_quality(value: RenderingServer.SubSurfaceScatteringQuality) -> String:
	SaverLoader.graphics_settings.sss_quality = value
	RenderingServer.sub_surface_scattering_set_quality(value)
	return "set subsurface scattering quality to " + str(value)

func _command_graphics_sss_scale(value: float) -> String:
	SaverLoader.graphics_settings.sss_scale = value
	RenderingServer.sub_surface_scattering_set_scale(
		SaverLoader.graphics_settings.sss_scale,
		SaverLoader.graphics_settings.sss_depth_scale
	)
	return "set subsurface scattering scale to " + str(value)

func _command_graphics_sss_depth_scale(value: float) -> String:
	SaverLoader.graphics_settings.sss_depth_scale = value
	RenderingServer.sub_surface_scattering_set_scale(
		SaverLoader.graphics_settings.sss_scale,
		SaverLoader.graphics_settings.sss_depth_scale
	)
	return "set subsurface scattering depth scale to " + str(value)

func _command_graphics_fog_enabled(value: bool) -> String:
	SaverLoader.graphics_settings.fog_enabled = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.fog_enabled = value
	return "set fog enabled to " + str(value)

func _command_graphics_fog_mode(value: Environment.FogMode) -> String:
	SaverLoader.graphics_settings.fog_mode = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.fog_mode = value
	return "set fog mode to " + str(value)

func _command_graphics_fog_light_energy(value: float) -> String:
	SaverLoader.graphics_settings.fog_light_energy = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.fog_light_energy = value
	return "set fog light energy to " + str(value)

func _command_graphics_fog_sun_scatter(value: float) -> String:
	SaverLoader.graphics_settings.fog_sun_scatter = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.fog_sun_scatter = value
	return "set fog sun scatter to " + str(value)

func _command_graphics_fog_density(value: float) -> String:
	SaverLoader.graphics_settings.fog_density = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.fog_density = value
	return "set fog density to " + str(value)

func _command_graphics_fog_sky_affect(value: float) -> String:
	SaverLoader.graphics_settings.fog_sky_affect = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.fog_sky_affect = value
	return "set fog sky affect to " + str(value)

func _command_graphics_fog_height(value: float) -> String:
	SaverLoader.graphics_settings.fog_height = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.fog_height = value
	return "set fog height to " + str(value)

func _command_graphics_fog_height_density(value: float) -> String:
	SaverLoader.graphics_settings.fog_height_density = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.fog_height_density = value
	return "set fog height density to " + str(value)

func _command_graphics_fog_depth_curve(value: float) -> String:
	SaverLoader.graphics_settings.fog_depth_curve = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.fog_depth_curve = value
	return "set fog depth curve to " + str(value)

func _command_graphics_fog_depth_begin(value: float) -> String:
	SaverLoader.graphics_settings.fog_depth_begin = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.fog_depth_begin = value
	return "set fog depth begin to " + str(value)

func _command_graphics_fog_depth_end(value: float) -> String:
	SaverLoader.graphics_settings.fog_depth_end = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.fog_depth_end = value
	return "set fog depth end to " + str(value)

func _command_graphics_volumetric_fog_enabled(value: bool) -> String:
	SaverLoader.graphics_settings.volumetric_fog_enabled = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.volumetric_fog_enabled = value
	return "set volumetric fog enabled to " + str(value)

func _command_graphics_volumetric_fog_volume_size(value: int) -> String:
	SaverLoader.graphics_settings.volumetric_fog_volume_size = value
	RenderingServer.environment_set_volumetric_fog_volume_size(
		SaverLoader.graphics_settings.volumetric_fog_volume_size,
		SaverLoader.graphics_settings.volumetric_fog_volume_depth
	)
	return "set volumetric fog volume size to " + str(value)

func _command_graphics_volumetric_fog_volume_depth(value: int) -> String:
	SaverLoader.graphics_settings.volumetric_fog_volume_depth = value
	RenderingServer.environment_set_volumetric_fog_volume_size(
		SaverLoader.graphics_settings.volumetric_fog_volume_size,
		SaverLoader.graphics_settings.volumetric_fog_volume_depth
	)
	return "set volumetric fog volume depth to " + str(value)

func _command_graphics_volumetric_fog_use_filter(value: bool) -> String:
	SaverLoader.graphics_settings.volumetric_fog_volume_use_filter = value
	RenderingServer.environment_set_volumetric_fog_filter_active(value)
	return "set volumetric fog use filter to " + str(value)

func _command_graphics_volumetric_fog_density(value: float) -> String:
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.volumetric_fog_density = value
	return "set fog density to " + str(value)

func _command_graphics_brightness(value: float) -> String:
	SaverLoader.graphics_settings.brightness = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.adjustment_brightness = value
	return "set brighness to " + str(value)

func _command_graphics_contrast(value: float) -> String:
	SaverLoader.graphics_settings.contrast = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.adjustment_contrast = value
	return "set contrast to " + str(value)

func _command_graphics_saturation(value: float) -> String:
	SaverLoader.graphics_settings.saturation = value
	if GameManager.player_character:
		GameManager.player_character.main_camera.environment.adjustment_saturation = value
	return "set saturation to " + str(value)

func _command_graphics_smooth_lights() -> String:
	return "discontinued"

func _command_graphics_directional_shadow_size(value: int) -> String:
	SaverLoader.graphics_settings.positional_shadow_size = value
	RenderingServer.directional_shadow_atlas_set_size(value, false)
	return "set directional shadow size to " + str(value)

func _command_graphics_directional_shadow_quality(value: RenderingServer.ShadowQuality) -> String:
	SaverLoader.graphics_settings.directional_shadow_quality = value
	RenderingServer.directional_soft_shadow_filter_set_quality(value)
	return "set directional shadow quality to " + str(value)

func _command_graphics_positional_shadow_size(value: int) -> String:
	SaverLoader.graphics_settings.positional_shadow_size = value
	get_viewport().positional_shadow_atlas_size = value
	return "set positional shadow size to " + str(value)

func _command_graphics_positional_shadow_quality(value: RenderingServer.ShadowQuality) -> String:
	SaverLoader.graphics_settings.positional_shadow_quality = value
	RenderingServer.positional_soft_shadow_filter_set_quality(value)
	return "set positional shadow quality to " + str(value)

func _command_graphics_positional_shadow_16_bit(value: bool) -> String:
	SaverLoader.graphics_settings.positional_shadow_16bit = value
	get_viewport().positional_shadow_atlas_16_bits = value
	return "set positional atlas 16 bits to " + str(value)

func _command_graphics_reduce_particles(value: bool) -> String:
	SaverLoader.graphics_settings.reduce_particles = value
	if GameManager.player_character:
		GameManager.player_character.dust_particles.emitting = false if value else true
	return "set reduce particles to: " + str(value)

func _command_game_save(value: String) -> String:
	SaverLoader.save_game_data(value)
	return "saving game in slot: " + value

func _command_game_load(value: String) -> String:
	SaverLoader.load_game_data(value)
	return "loading game from slot: " + value

func _command_game_erase(value: String) -> String:
	SaverLoader.erase_game_data(value)
	return "erasing game data from slot: " + value

func _command_player_fly() -> String:
	var player = GameManager.player_character
	if !player:
		return "[color=red]couldn't find player[/color]"
	
	if player.current_movement_mode != player.MovementMode.FLY:
		player.collision_mask = 0
		#player.body_collision.disabled = true
		#player.head_collision.disabled = true
		player.pre_fly_movement_mode = player.current_movement_mode
		player.pre_fly_movement_speed = player.current_movement_speed
		player.current_movement_mode = player.MovementMode.FLY
		player.current_movement_speed = player.movement_speeds[player.MovementMode.FLY]
		return "set player movement mode to fly"
	elif player.collision_mask == 131:
	#elif player.body_collision.disabled == false:
		player.collision_mask = 0
		#player.body_collision.disabled = true
		#player.head_collision.disabled = true
		return "disabled fly collision"
	else:
		player.collision_mask = 131
		#player.body_collision.disabled = false
		#player.head_collision.disabled = false
		player.current_movement_mode = player.pre_fly_movement_mode
		player.current_movement_speed = player.pre_fly_movement_speed
		return "set player movement mode back from fly"

func _command_player_fly_collision() -> String:
	var player = GameManager.player_character
	if !player:
		return "[color=red]couldn't find player[/color]"
	
	if player.current_movement_mode != player.MovementMode.FLY:
		player.pre_fly_movement_mode = player.current_movement_mode
		player.pre_fly_movement_speed = player.current_movement_speed
		player.current_movement_mode = player.MovementMode.FLY
		player.current_movement_speed = player.movement_speeds[player.MovementMode.FLY]
		return "set player movement mode to fly with collision"
	elif player.collision_mask == 0:
	#elif player.body_collision.disabled == true:
		player.collision_mask = 131
		#player.body_collision.disabled = false
		#player.head_collision.disabled = false
		return "enabled fly collision"
	else:
		player.current_movement_mode = player.pre_fly_movement_mode
		player.current_movement_speed = player.pre_fly_movement_speed
		return "set player movement mode back from fly with collision"

func _command_player_flashlight() -> String:
	if !GameManager.player_character:
		return "[color=red]couldn't find player[/color]"
	if GameManager.player_character.inventory.flashlight.disabled:
		GameManager.player_character.inventory.flashlight.disabled = false
		return "player flashlight added"
	else:
		GameManager.player_character.inventory.flashlight.disabled = true
		return "player flashlight removed"

func _command_player_screwdriver() -> String:
	if !GameManager.player_character:
		return "[color=red]couldn't find player[/color]"
	if GameManager.player_character.inventory.screwdriver.disabled:
		GameManager.player_character.inventory.screwdriver.disabled = false
		return "player screwdriver added"
	else:
		GameManager.player_character.inventory.screwdriver.disabled = true
		return "player screwdriver removed"

func _command_player_speed(value: float) -> String:
	if !GameManager.player_character:
		return "[color=red]couldn't find player[/color]"
	GameManager.player_character.current_movement_speed = value
	return "set player speed to " + str(value)

func _command_player_tp(value: Vector3) -> String:
	if !GameManager.player_character:
		return "couldn't find player"
	GameManager.player_character.global_position = value
	return "teleported player to " + str(value)

func _command_engine_speed(value: float) -> String:
	Engine.time_scale = value
	return "set engine speed to " + str(value)

func _command_system_quit() -> String:
	get_tree().quit.call_deferred()
	return "quitting..."

func _command_system_debug_overlay(value: int) -> String:
	GameManager.set_debug_overlay(value)
	return "set debug overlay to " + str(value)

var full_bright: bool = false
var previous_env: Environment
var gis: Array = []
func _command_debug_full_bright() -> String:
	if !GameManager.player_character:
		return "can't find player"
	if !full_bright:
		full_bright = true
		previous_env = GameManager.player_character.main_camera.environment
		var env = load("res://Assets/Environments/bright_environment.tres")
		GameManager.player_character.main_camera.environment = env
		for gi in get_tree().get_nodes_in_group("GlobalIllumination"):
			gis.append(gi)
			gi.visible = false
		return "full_bright on"
	else:
		full_bright = false
		GameManager.player_character.main_camera.environment = previous_env
		previous_env = null
		for gi in gis:
			gi.visible = true
			gis.erase(gi)
		return "full_bright off"

func _command_system_debug_vault() -> String:
	if GameManager.player_character:
		if GameManager.player_character.vault_checks.debug:
			GameManager.player_character.vault_checks.debug = false
			return "turned vault debug off"
		else:
			GameManager.player_character.vault_checks.debug = true
			return "turned vault debug on"
	return "couldn't find player"

func _command_system_debug_crawl() -> String:
	if GameManager.player_character:
		if GameManager.player_character.crawl_debug:
			GameManager.player_character.crawl_debug = false
			return "turned crawl debug off"
		else:
			GameManager.player_character.crawl_debug = true
			return "turned crawl debug on"
	return "couldn't find player"

func _command_system_say(value: String) -> String:
	DialogueManager.say(value)
	return "said " + value
