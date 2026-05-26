extends Control


const MENU_BUTTON_SOUND = preload("uid://dyf7ad2tflj7r")

const graphics_low: String = "uid://cutv363x14c4e"
const graphics_medium: String = "uid://cr40bmj55qsks"
const graphics_high: String = "uid://cn4cbbs6h71o1"


@onready var save_button: Button = %SaveButton
@onready var return_button: Button = %ReturnButton
@onready var default_button: Button = %DefaultButton
@onready var revert_button: Button = %RevertButton
@onready var files_button: Button = %FilesButton

var temp_settings: SettingsResource = SaverLoader.settings.duplicate(true)
var temp_graphics_settings: GraphicsSettingsResource = SaverLoader.graphics_settings.duplicate(true)

var sensitivity: float = temp_settings.sensitivity:
	set(value):
		value = clamp(value, 0.0, 100.0)
		sensitivity = value
		temp_settings.sensitivity = value
		%SensitivityHSlider.value = value
		%SensitivityLineEdit.text = str(value)
		unsaved = true
var max_fps: int = temp_settings.max_fps:
	set(value):
		value = clamp(value, 0, 999)
		max_fps = value
		temp_settings.max_fps = value
		%MaxFPSLineEdit.text = str(value)
		unsaved = true
var vsync: DisplayServer.VSyncMode = temp_settings.vsync:
	set(value):
		if value > 0:
			value = DisplayServer.VSyncMode.VSYNC_ENABLED
			%VsyncCheckButton.button_pressed = true
		else:
			value = DisplayServer.VSyncMode.VSYNC_DISABLED
			%VsyncCheckButton.button_pressed = false
		vsync = value
		temp_settings.vsync = value
		unsaved = true
var fov: int = temp_settings.fov:
	set(value):
		value = clamp(value, 50, 110)
		fov = value
		temp_settings.fov = value
		%FOVLineEdit.text = str(value)
		unsaved = true
var dynamic_fov: bool = temp_settings.dynamic_fov:
	set(value):
		dynamic_fov = value
		temp_settings.dynamic_fov = value
		%DynamicFOVCheckButton.button_pressed = value
		unsaved = true
var window_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode():
	set(value):
		window_mode = value
		temp_settings.window_mode = value
		match value:
			DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
				%WindowModeOptionButton.selected = 0
			DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
				%WindowModeOptionButton.selected = 1
			DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
				%WindowModeOptionButton.selected = 3
			DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				%WindowModeOptionButton.selected = 4
		unsaved = true
var persistent_crosshair: bool = temp_settings.persistent_crosshair:
	set(value):
		persistent_crosshair = value
		temp_settings.persistent_crosshair = value
		%PersistentCrosshairCheckButton.button_pressed = value
		unsaved = true
var hud_size: float = temp_settings.hud_size:
	set(value):
		value = clamp(value, 0.5, 5)
		hud_size = value
		temp_settings.hud_size = value
		%HUDSizeLineEdit.text = str(value)
		unsaved = true
var subtitles: int = temp_settings.subtitles:
	set(value):
		value = clamp(value, 10, 80)
		subtitles = value
		temp_settings.subtitles = value
		%SubtitlesSizeLineEdit.text = str(value)
		unsaved = true
var head_bob: bool = temp_settings.head_bob:
	set(value):
		head_bob = value
		temp_settings.head_bob = value
		%HeadBobCheckButton.button_pressed = value
		unsaved = true
var static_shader: bool = temp_settings.static_shader:
	set(value):
		static_shader = value
		temp_settings.static_shader = value
		%StaticShaderCheckButton.button_pressed = value
		unsaved = true

var preset: GraphicsSettingsResource = null:
	set(value):
		preset = value
		temp_graphics_settings = value
		_set_all_settings(true)
		unsaved = true
		changed_graphics = true

var brightness: float = temp_graphics_settings.brightness:
	set(value):
		value = clampf(value, 0.0, 5.0)
		brightness = value
		temp_graphics_settings.brightness = value
		%BrightnessHSlider.value = value
		%BrightnessLineEdit.text = str(int(value * 100))
		GameManager.DEFAULT_ENVIRONMENT.adjustment_brightness = value
		unsaved = true
		changed_graphics = true

var master_volume: float = temp_settings.master_volume:
	set(value):
		value = clamp(value, 0.0, 1.0)
		master_volume = value
		temp_settings.master_volume = value
		%MasterHSlider.value = value
		%MasterLineEdit.text = str(int(value * 100))
		unsaved = true
var sfx_volume: float = temp_settings.sfx_volume:
	set(value):
		value = clamp(value, 0.0, 100.0)
		sfx_volume = value
		temp_settings.sfx_volume = value
		%SFXHSlider.value = value
		%SFXLineEdit.text = str(int(value * 100))
		unsaved = true
var dialogue_volume: float = temp_settings.dialogue_volume:
	set(value):
		value = clamp(value, 0.0, 100.0)
		dialogue_volume = value
		temp_settings.dialogue_volume = value
		%DialogueHSlider.value = value
		%DialogueLineEdit.text = str(int(value * 100))
		unsaved = true
var ambient_volume: float = temp_settings.ambient_volume:
	set(value):
		value = clamp(value, 0.0, 100.0)
		ambient_volume = value
		temp_settings.ambient_volume = value
		%AmbientHSlider.value = value
		%AmbientLineEdit.text = str(int(value * 100))
		unsaved = true
var music_volume: float = temp_settings.music_volume:
	set(value):
		value = clamp(value, 0.0, 100.0)
		music_volume = value
		temp_settings.music_volume = value
		%MusicHSlider.value = value
		%MusicLineEdit.text = str(int(value * 100))
		unsaved = true
var menus_volume: float = temp_settings.menus_volume:
	set(value):
		value = clamp(value, 0.0, 100.0)
		menus_volume = value
		temp_settings.menus_volume = value
		%MenusHSlider.value = value
		%MenusLineEdit.text = str(int(value * 100))
		unsaved = true
var unsaved: bool = false:
	set(value):
		unsaved = value
		leave_unsaved = false
		return_button.text = "Return"
var changed_graphics: bool = false
var leave_unsaved: bool = false


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		return_button.pressed.emit()


func _ready() -> void:
	InputManager.menu = self
	
	_set_up_game()
	_set_up_controls()
	_set_up_graphics()
	_set_up_sound()
	
	save_button.pressed.connect(func():
		AudioManager.play_sound("Menus", MENU_BUTTON_SOUND, 0.0, 1.2)
		_save_settings())
	
	return_button.pressed.connect(func():
		if unsaved and !leave_unsaved:
			return_button.text = "Return unsaved"
			leave_unsaved = true
		else:
			if %Game.visible:
				SaverLoader.settings.last_opened_settings_tab = 0
			elif %Controls.visible:
				SaverLoader.settings.last_opened_settings_tab = 1
			elif %Graphics.visible:
				SaverLoader.settings.last_opened_settings_tab = 2
			elif %Sound.visible:
				SaverLoader.settings.last_opened_settings_tab = 3
			
			if unsaved:
				GameManager.DEFAULT_ENVIRONMENT.adjustment_brightness = SaverLoader.graphics_settings.brightness
			
			queue_free())
	
	default_button.pressed.connect(func():
		_default_settings())
	
	revert_button.pressed.connect(func():
		_revert_settings())
	
	files_button.pressed.connect(func():
		OS.shell_show_in_file_manager(SaverLoader.GAME_PATH, true)
		DirAccess.open(SaverLoader.GAME_PATH))
	
	match temp_settings.last_opened_settings_tab:
		0:
			%Game.show()
		1:
			%Controls.show()
		2:
			%Graphics.show()
		3:
			%Sound.show()
		_:
			%Game.show()


func _set_up_game() -> void:
	%SensitivityHSlider.value = temp_settings.sensitivity
	%SensitivityHSlider.value_changed.connect(func(value: float):
		sensitivity = value)
	%SensitivityLineEdit.text = str(temp_settings.sensitivity)
	%SensitivityLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%SensitivityLineEdit.text.is_valid_float():
			%SensitivityLineEdit.text = str(sensitivity)
		sensitivity = %SensitivityLineEdit.text.to_float())
	%MaxFPSLineEdit.text = str(temp_settings.max_fps)
	%MaxFPSLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%MaxFPSLineEdit.text.is_valid_int():
			%MaxFPSLineEdit.text = str(max_fps)
		max_fps = %MaxFPSLineEdit.text.to_int())
	%VsyncCheckButton.button_pressed = true if temp_settings.vsync > 0 else false
	%VsyncCheckButton.pressed.connect(func():
		if %VsyncCheckButton.button_pressed:
			vsync = DisplayServer.VSyncMode.VSYNC_ENABLED
		else:
			vsync = DisplayServer.VSyncMode.VSYNC_DISABLED)
	%FOVLineEdit.text = str(temp_settings.fov)
	%FOVLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%FOVLineEdit.text.is_valid_int():
			%FOVLineEdit.text = str(fov)
		fov = %FOVLineEdit.text.to_int())
	%DynamicFOVCheckButton.button_pressed = temp_settings.dynamic_fov
	%DynamicFOVCheckButton.pressed.connect(func():
		dynamic_fov = %DynamicFOVCheckButton.button_pressed)
	temp_settings.window_mode = DisplayServer.window_get_mode()
	get_viewport().size_changed.connect(func():
		temp_settings.window_mode = DisplayServer.window_get_mode()
		match temp_settings.window_mode:
			DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
				%WindowModeOptionButton.selected = 0
			DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
				%WindowModeOptionButton.selected = 1
			DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
				%WindowModeOptionButton.selected = 2
			DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				%WindowModeOptionButton.selected = 3
		)
	match temp_settings.window_mode:
			DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
				%WindowModeOptionButton.selected = 0
			DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
				%WindowModeOptionButton.selected = 1
			DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
				%WindowModeOptionButton.selected = 2
			DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
				%WindowModeOptionButton.selected = 3
	%WindowModeOptionButton.item_selected.connect(func(index: int):
		match index:
			0:
				window_mode = DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
			1:
				window_mode = DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
			2:
				window_mode = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
			3:
				window_mode = DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		)
	%PersistentCrosshairCheckButton.button_pressed = temp_settings.persistent_crosshair
	%PersistentCrosshairCheckButton.pressed.connect(func():
		persistent_crosshair = %PersistentCrosshairCheckButton.button_pressed)
	%HUDSizeLineEdit.text = str(temp_settings.hud_size)
	%HUDSizeLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%HUDSizeLineEdit.text.is_valid_float():
			%HUDSizeLineEdit.text = str(hud_size)
		hud_size = %HUDSizeLineEdit.text.to_float())
	%SubtitlesSizeLineEdit.text = str(temp_settings.subtitles)
	%SubtitlesSizeLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%SubtitlesSizeLineEdit.text.is_valid_int():
			%SubtitlesSizeLineEdit.text = str(subtitles)
		subtitles = %SubtitlesSizeLineEdit.text.to_int())
	%HeadBobCheckButton.button_pressed = temp_settings.head_bob
	%HeadBobCheckButton.pressed.connect(func():
		head_bob = %HeadBobCheckButton.button_pressed)
	%StaticShaderCheckButton.button_pressed = temp_settings.static_shader
	%StaticShaderCheckButton.pressed.connect(func():
		static_shader = %StaticShaderCheckButton.button_pressed)


func _set_up_controls() -> void:
	pass


func _set_up_graphics() -> void:
	%PresetButtonLow.pressed.connect(func():
		preset = load(graphics_low))
	%PresetButtonMedium.pressed.connect(func():
		preset = load(graphics_medium))
	%PresetButtonHigh.pressed.connect(func():
		preset = load(graphics_high))
	
	%BrightnessHSlider.value = temp_graphics_settings.brightness
	%BrightnessHSlider.value_changed.connect(func(value: float):
		brightness = value)
	%BrightnessLineEdit.text = str(int(temp_graphics_settings.brightness * 100))
	%BrightnessLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%BrightnessLineEdit.text.is_valid_int():
			%BrightnessLineEdit.text = str(int(temp_graphics_settings.brightness * 100))
		brightness = %BrightnessLineEdit.text.to_float() * 0.01)
	%BrightnessTest.hide()
	var camera: Camera3D
	if GameManager.player_character:
		camera = GameManager.player_character.main_camera
	else:
		camera = get_viewport().get_camera_3d()
	%BrightnessTest.global_position = camera.global_position - camera.global_basis.z
	%BrightnessTest.global_rotation = camera.global_rotation
	%BrightnessHSlider.mouse_entered.connect(func():
		if !is_queued_for_deletion():
			%BrightnessTest.show())
	%BrightnessHSlider.mouse_exited.connect(func():
		if !is_queued_for_deletion():
			%BrightnessTest.hide())
	%BrightnessLineEdit.mouse_entered.connect(func():
		if !is_queued_for_deletion():
			%BrightnessTest.show())
	%BrightnessLineEdit.mouse_exited.connect(func():
		if !is_queued_for_deletion():
			%BrightnessTest.hide())


func _set_up_sound() -> void:
	%MasterHSlider.value = temp_settings.master_volume
	%MasterHSlider.value_changed.connect(func(value: float):
		master_volume = value)
	%MasterLineEdit.text = str(int(temp_settings.master_volume * 100))
	%MasterLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%MasterLineEdit.text.is_valid_int():
			%MasterLineEdit.text = str(int(temp_settings.master_volume * 100))
		master_volume = %MasterLineEdit.text.to_float() * 0.01)
	
	%SFXHSlider.value = temp_settings.sfx_volume
	%SFXHSlider.value_changed.connect(func(value: float):
		sfx_volume = value)
	%SFXLineEdit.text = str(int(temp_settings.sfx_volume * 100))
	%SFXLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%SFXLineEdit.text.is_valid_int():
			%SFXLineEdit.text = str(int(temp_settings.sfx_volume * 100))
		sfx_volume = %SFXLineEdit.text.to_float() * 0.01)
	
	%DialogueHSlider.value = temp_settings.dialogue_volume
	%DialogueHSlider.value_changed.connect(func(value: float):
		dialogue_volume = value)
	%DialogueLineEdit.text = str(int(temp_settings.dialogue_volume * 100))
	%DialogueLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%DialogueLineEdit.text.is_valid_int():
			%DialogueLineEdit.text = str(int(temp_settings.dialogue_volume * 100))
		dialogue_volume = %DialogueLineEdit.text.to_float() * 0.01)
	
	%AmbientHSlider.value = temp_settings.ambient_volume
	%AmbientHSlider.value_changed.connect(func(value: float):
		ambient_volume = value)
	%AmbientLineEdit.text = str(int(temp_settings.ambient_volume * 100))
	%AmbientLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%AmbientLineEdit.text.is_valid_int():
			%AmbientLineEdit.text = str(int(temp_settings.ambient_volume * 100))
		ambient_volume = %AmbientLineEdit.text.to_float() * 0.01)
	
	%MusicHSlider.value = temp_settings.music_volume
	%MusicHSlider.value_changed.connect(func(value: float):
		music_volume = value)
	%MusicLineEdit.text = str(int(temp_settings.music_volume * 100))
	%MusicLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%MusicLineEdit.text.is_valid_int():
			%MusicLineEdit.text = str(int(temp_settings.music_volume * 100))
		music_volume = %MusicLineEdit.text.to_float() * 0.01)
	
	%MenusHSlider.value = temp_settings.menus_volume
	%MenusHSlider.value_changed.connect(func(value: float):
		menus_volume = value)
	%MenusLineEdit.text = str(int(temp_settings.menus_volume * 100))
	%MenusLineEdit.editing_toggled.connect(func(editing: bool):
		if editing: return
		if !%MenusLineEdit.text.is_valid_int():
			%MenusLineEdit.text = str(int(temp_settings.menus_volume * 100))
		menus_volume = %MenusLineEdit.text.to_float() * 0.01)


func _default_settings() -> void:
	temp_settings = SettingsResource.new()
	
	_set_all_settings()


func _revert_settings() -> void:
	temp_settings = SaverLoader.settings.duplicate(true)
	temp_graphics_settings = SaverLoader.graphics_settings.duplicate(true)
	
	_set_all_settings(true)


func _set_all_settings(graphics: bool = false) -> void:
	sensitivity = temp_settings.sensitivity
	max_fps = temp_settings.max_fps
	vsync = temp_settings.vsync
	fov = temp_settings.fov
	dynamic_fov = temp_settings.dynamic_fov
	window_mode = temp_settings.window_mode
	persistent_crosshair = temp_settings.persistent_crosshair
	hud_size = temp_settings.hud_size
	head_bob = temp_settings.head_bob
	static_shader = temp_settings.static_shader
	
	master_volume = temp_settings.master_volume
	sfx_volume = temp_settings.sfx_volume
	dialogue_volume = temp_settings.dialogue_volume
	ambient_volume = temp_settings.ambient_volume
	music_volume = temp_settings.music_volume
	menus_volume = temp_settings.menus_volume
	
	if !graphics: return
	
	brightness = temp_graphics_settings.brightness


func _save_settings() -> void:
	unsaved = false
	SaverLoader.settings = temp_settings.duplicate(true)
	SaverLoader.save_settings()
	GameManager.apply_settings_data()
	if changed_graphics:
		SaverLoader.graphics_settings = temp_graphics_settings.duplicate(true)
		SaverLoader.save_graphics_settings()
		GameManager.apply_graphics_settings_data()
