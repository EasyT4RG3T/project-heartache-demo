extends Control


const MENU_BUTTON_SOUND = preload("uid://dyf7ad2tflj7r")

@onready var camera_3d: Camera3D = %Camera3D
@onready var lights: Node3D = %Lights
@onready var dynamic_lightmap_gi: DynamicLightmapGI = %DynamicLightmapGI
@onready var monster: Node3D = %monster

var camera_tween: Tween

@onready var start: Control = %Start

@onready var start_new_game_button: Button = %NewGameButton
@onready var start_continue_button: Button = %ContinueButton
@onready var start_load_game_button: Button = %LoadGameButton
@onready var start_settings_button: Button = %SettingsButton
@onready var start_quit_button: Button = %QuitButton
@onready var version_label: Label = %VersionLabel


const settings_menu_uid: String = "uid://0ogoc8tlkqfx"
const saves_menu_uid: String = "uid://cs7mrt6rnpmfp"
const accept_menu_uid: String = "uid://dckjpcj38rsvw"


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		start_quit_button.pressed.emit()


func _ready() -> void:
	InputManager.menu = self
	
	camera_3d.make_current()
	camera_3d.environment = GameManager.DEFAULT_ENVIRONMENT
	monster.hide()
	
	version_label.text = "Version: " + ProjectSettings.get_setting("application/config/version")
	_setup_start()
	_move_camera()
	
	$Helper/AnimationPlayer.play("Map")
	$Node3D/Helper/HelperAnimationPlayer.play("Map")
	
	if Console.menu_hint:
		%ConsoleLabel.show()
		Console.menu_hint = false
		%ConsoleLabel/Timer.timeout.connect(func():
			%ConsoleLabel.modulate = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1), 1.0)
			%ConsoleLabel/Timer.start(0.5))
		%ConsoleLabel/Timer.start(0.5)
	else:
		%ConsoleLabel.hide()
	
	if SaverLoader.settings.first_time:
		SaverLoader.settings.first_time = false
		SaverLoader.save_settings()


var blink_timer: float = 0.0
var monster_reapear: int = 0
func _physics_process(delta: float) -> void:
	blink_timer += delta
	if blink_timer > 0.3:
		if !lights.visible:
			if randi_range(0, 1) == 1:
				lights.show()
				dynamic_lightmap_gi.show()
				if !monster.visible:
					if monster_reapear >= 1:
						monster.show()
					else:
						monster_reapear += randi_range(0, 1)
		elif randi_range(0, 10) == 10:
			lights.hide()
			dynamic_lightmap_gi.hide()
			if monster.visible and randi_range(0, 5) == 5:
				monster.hide()
				monster_reapear = 0
		
		blink_timer = 0.0


func _move_camera() -> void:
	if camera_tween:
		camera_tween.kill()
	
	var new_pos: Vector3 = Vector3(
		randf_range(0.766, 0.806),
		randf_range(1.23, 1.27),
		0.7
	)
	
	camera_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_ease(Tween.EASE_IN_OUT)
	camera_tween.tween_property(camera_3d, "position", new_pos, 5.0)
	camera_tween.finished.connect(_move_camera, PROPERTY_HINT_ONESHOT)


func _setup_start() -> void:
	start_new_game_button.pressed.connect(func():
		var name_input_menu: AcceptMenu = load(accept_menu_uid).instantiate()
		
		var int_files: Array[int] = []
		if DirAccess.dir_exists_absolute(SaverLoader.GAME_DATA_PATH):
			for file: String in DirAccess.get_files_at(SaverLoader.GAME_DATA_PATH):
				if !file.begins_with("NewGame"):
					continue
				file = file.trim_prefix("NewGame")
				file = file.trim_suffix(".dat")
				if file.is_valid_int():
					if !int_files.has(file.to_int()):
						int_files.append(file.to_int())
		var current_try: int = 0
		for i in int_files.size():
			if int_files.has(i):
				current_try += 1
			else:
				break
		var new_slot: String = "NewGame" + str(current_try)
		
		name_input_menu.editable = true
		name_input_menu.message = ""
		name_input_menu.placeholder_message = new_slot
		name_input_menu.accept_text = "Start"
		name_input_menu.cancel_text = "Return"
		
		name_input_menu.accepted.connect(func():
			if name_input_menu.line_edit.text.is_empty():
				SaverLoader.current_slot = name_input_menu.line_edit.placeholder_text
			else:
				SaverLoader.current_slot = name_input_menu.line_edit.text
			AudioManager.play_sound("Menus", MENU_BUTTON_SOUND, 0.0, 1.0)
			GameManager.new_game())
		name_input_menu.cancelled.connect(func():
			name_input_menu.queue_free()
			InputManager.menu = self)
		
		add_child(name_input_menu)
		InputManager.menu = name_input_menu)
	
	if !FileAccess.file_exists(SaverLoader.GAME_DATA_PATH + SaverLoader.current_slot + ".dat"):
		start_continue_button.hide()
	
	start_continue_button.pressed.connect(func():
		if !FileAccess.file_exists(SaverLoader.GAME_DATA_PATH + SaverLoader.current_slot + ".dat"):
			return
		SaverLoader.load_game_data(SaverLoader.current_slot))
	
	start_load_game_button.pressed.connect(func():
		var saves_menu_packed: PackedScene = load(saves_menu_uid)
		var saves_menu: Node = saves_menu_packed.instantiate()
		add_child(saves_menu)
		start.hide()
		saves_menu.tree_exiting.connect(func():
			start.show()
			InputManager.menu = self))
	
	start_settings_button.pressed.connect(func():
		var settings_menu_packed: PackedScene = load(settings_menu_uid)
		var settings_menu: Node = settings_menu_packed.instantiate()
		add_child(settings_menu)
		start.hide()
		settings_menu.tree_exiting.connect(func():
			start.show()
			InputManager.menu = self))
	
	start_quit_button.pressed.connect(func():
		var accept_menu_packed: PackedScene = load(accept_menu_uid)
		var accept_menu: AcceptMenu = accept_menu_packed.instantiate()
		accept_menu.message = "Quit Game?"
		accept_menu.accept_text = "Yes"
		accept_menu.cancel_text = "No"
		add_child(accept_menu)
		accept_menu.accepted.connect(func():
			AudioManager.play_sound("Menus", MENU_BUTTON_SOUND, 0.2, 0.6)
			await get_tree().create_timer(1.0).timeout
			get_tree().quit())
		accept_menu.cancelled.connect(func():
			accept_menu.queue_free()
			InputManager.menu = self)
		InputManager.menu = accept_menu)
