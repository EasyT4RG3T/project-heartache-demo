extends Control


@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var saves_v_box_container: VBoxContainer = %SavesVBoxContainer
@onready var new_save_button: Button = %NewSaveButton
@onready var selected_texture: TextureRect = %SelectedTexture
@onready var selected_name: LineEdit = %SelectedName
@onready var selected_description: Label = %SelectedDescription
@onready var selected_version: Label = %SelectedVersion
@onready var delete_button: Button = %DeleteButton
@onready var load_button: Button = %LoadButton
@onready var save_button: Button = %SaveButton
@onready var return_button: Button = %ReturnButton


var current_selection: String = "":
	set(value):
		current_selection = value
		if value.is_empty():
			delete_button.hide()
			load_button.hide()
			save_button.hide()
		else:
			delete_button.show()
			load_button.show()
			save_button.show()
var saves: Dictionary = {}
var buttons: Array = []


func take_input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		return_button.pressed.emit()


func _ready() -> void:
	delete_button.hide()
	load_button.hide()
	save_button.hide()
	
	InputManager.menu = self
	get_viewport().size_changed.connect(func():
		scroll_container.custom_minimum_size.y = get_viewport_rect().size.y - 30)
	scroll_container.custom_minimum_size.y = get_viewport_rect().size.y - 30
	
	return_button.pressed.connect(func():
		queue_free())
	
	delete_button.pressed.connect(func():
		SaverLoader.erase_game_data(current_selection)
		saves[current_selection]["button"].queue_free()
		saves.erase(current_selection))
	
	load_button.pressed.connect(func():
		SaverLoader.load_game_data(current_selection))
	
	save_button.pressed.connect(func():
		SaverLoader.save_game_data(current_selection))
	
	new_save_button.pressed.connect(func():
		if SaverLoader.can_save > 0: return
		var int_files: Array[int] = []
		for file: String in saves:
			if !file.begins_with("Save_"):
				continue
			file = file.trim_prefix("Save_")
			if file.is_valid_int():
				if !int_files.has(file.to_int()):
					int_files.append(file.to_int())
		var current_try: int = 0
		for i in int_files.size():
			if int_files.has(i):
				current_try += 1
			else:
				break
		SaverLoader.current_slot = "Save_" + str(current_try)
		var bton = _create_button(SaverLoader.current_slot, Time.get_datetime_string_from_system(false, true),\
					   ProjectSettings.get_setting("application/config/version"))
		saves_v_box_container.add_child(bton)
		SaverLoader.save_game_data(SaverLoader.current_slot))
	if SaverLoader.can_save > 0:
		new_save_button.disabled = true
		save_button.disabled = true
	
	_update_list()

#self.hide()
#await RenderingServer.frame_post_draw
#var image: Image = get_viewport().get_texture().get_image()
#self.show()
#image.resize(256, 144)
#image.save_png(OS.get_data_dir() + "/project_heartache/ss.png")
#)

#if SaverLoader.can_save > 0:
#			var accept_menu_packed: PackedScene = load(accept_menu_uid)
#			var accept_menu: AcceptMenu = accept_menu_packed.instantiate()
#			accept_menu.message = "Cannot save at this moment"
#			accept_menu.accept_text = "Okay"
#			accept_menu.cancel_button = false
#			add_child(accept_menu)
#			accept_menu.accepted.connect(func():
#				accept_menu.queue_free()
#				InputManager.menu = self)
#			InputManager.menu = accept_menu
#			return
#		SaverLoader.save_game_data(SaverLoader.current_slot)


func _update_list() -> void:
	if !DirAccess.dir_exists_absolute(SaverLoader.GAME_DATA_PATH):
		return
	
	var files_paths: PackedStringArray = DirAccess.get_files_at(SaverLoader.GAME_DATA_PATH)
	for file_path: String in files_paths:
		if !file_path.ends_with(".dat"): continue
		file_path = file_path.trim_suffix(".dat")
		var file_read := FileAccess.open(SaverLoader.GAME_DATA_PATH + file_path + ".dat", FileAccess.READ)
		if !file_read:
			print(SaverLoader.GAME_DATA_PATH + file_path + ".dat" + " didn't open")
			continue
		var read_data_byte = file_read.get_buffer(file_read.get_length())
		var game_data = bytes_to_var(read_data_byte)
		file_read.close()
		saves[file_path] = {
			"datetime" = game_data["system"]["datetime"],
			"version" = game_data["system"]["version"],
			"story_description" = game_data["game"]["data"]["story_description"]
		}
	
	for save_name in saves:
		var button = _create_button(save_name, saves[save_name]["datetime"], saves[save_name]["version"])
		saves_v_box_container.add_child(button)
		saves["button"] = button


func _save_select(save_name: String) -> void:
	if FileAccess.file_exists(SaverLoader.GAME_DATA_PATH + save_name + ".png"):
		var image = Image.load_from_file(SaverLoader.GAME_DATA_PATH + save_name + ".png")
		if image:
			selected_texture.texture = ImageTexture.create_from_image(image)
	selected_name.text = save_name
	selected_description.text = saves[save_name]["story_description"]
	selected_version.text = "version " + saves[save_name]["version"]
	current_selection = save_name


func _create_button(save_name: String, date: String, version: String) -> Button:
	var button: Button = Button.new()
	button.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	button.custom_minimum_size.x = 160
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.add_theme_constant_override("line_spacing", -5)
	button.text = save_name + "\n-----------------------------\n" +\
				  date + "\n-----------------------------\n" +\
				  version
	button.pressed.connect(_save_select.bind(save_name))
	buttons.append(button)
	return button
