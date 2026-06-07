extends Control


@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var saves_v_box_container: VBoxContainer = %SavesVBoxContainer
@onready var new_save_button: Button = %NewSaveButton
@onready var selected_texture: TextureRect = %SelectedTexture
@onready var selected_name: LineEdit = %SelectedName
@onready var selected_description: RichTextLabel = %SelectedDescription
@onready var selected_version: Label = %SelectedVersion
@onready var delete_button: Button = %DeleteButton
@onready var load_button: Button = %LoadButton
@onready var save_button: Button = %SaveButton
@onready var return_button: Button = %ReturnButton

var accept_menu_uid: String = "uid://dckjpcj38rsvw"

var current_selection: String = "":
	set(value):
		current_selection = value
		if value.is_empty():
			delete_button.hide()
			load_button.hide()
			save_button.hide()
		elif value.contains("AutoSave"):
			delete_button.hide()
			load_button.show()
			save_button.show()
			save_button.disabled = true
		else:
			delete_button.show()
			load_button.show()
			save_button.show()
			if SaverLoader.can_save <= 0:
				save_button.disabled = false
var saves: Dictionary = {}


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
		var accept_menu: AcceptMenu = load(accept_menu_uid).instantiate()
		accept_menu.message = "Are you sure you want to/nDELETE this save file?"
		accept_menu.accept_text = "Yes"
		accept_menu.cancel_text = "No"
		add_child(accept_menu)
		
		accept_menu.accepted.connect(func():
			delete_button.hide()
			load_button.hide()
			save_button.hide()
			SaverLoader.erase_game_data(current_selection)
			saves[current_selection]["button"].queue_free()
			saves.erase(current_selection)
			accept_menu.queue_free())
		
		accept_menu.cancelled.connect(func():
			accept_menu.queue_free()))
	
	load_button.pressed.connect(func():
		SaverLoader.load_game_data(current_selection))
	
	save_button.pressed.connect(func():
		if current_selection != SaverLoader.current_slot:
			var accept_menu: AcceptMenu = load(accept_menu_uid).instantiate()
			accept_menu.message = "Override save file?"
			accept_menu.accept_text = "Yes"
			accept_menu.cancel_text = "No"
			add_child(accept_menu)
			
			accept_menu.accepted.connect(func():
				SaverLoader.save_game_data(current_selection)
				accept_menu.queue_free())
			accept_menu.cancelled.connect(func():
				accept_menu.queue_free())
			
			return
		SaverLoader.save_game_data(current_selection))
	
	new_save_button.pressed.connect(func():
		if SaverLoader.can_save > 0: return
		var int_files: Array[int] = []
		for file: String in saves:
			if !file.begins_with("NewSave_"):
				continue
			file = file.trim_prefix("NewSave_")
			if file.is_valid_int():
				if !int_files.has(file.to_int()):
					int_files.append(file.to_int())
		var current_try: int = 0
		for i in int_files.size():
			if int_files.has(i):
				current_try += 1
			else:
				break
		var full_slot: String = "NewSave_" + str(current_try)
		saves[full_slot] = {
			"datetime" = Time.get_datetime_string_from_system(false, true),
			"version" = ProjectSettings.get_setting("application/config/version"),
			"story_description" = Game.story_description,
		}
		var button = _create_button(
			full_slot,
			Time.get_datetime_string_from_system(false, true),
			ProjectSettings.get_setting("application/config/version")
		)
		saves[full_slot]["button"] = button
		SaverLoader.save_game_data(full_slot))
	
	selected_name.text_submitted.connect(func(new_text: String):
		if saves.has(new_text) or new_text.contains("AutoSave"):
			selected_name.text = current_selection
			return
		DirAccess.rename_absolute(SaverLoader.GAME_DATA_PATH + current_selection + ".dat",\
		SaverLoader.GAME_DATA_PATH + new_text + ".dat")
		DirAccess.rename_absolute(SaverLoader.GAME_DATA_PATH + current_selection + ".png",\
		SaverLoader.GAME_DATA_PATH + new_text + ".png")
		#if SaverLoader.current_slot == current_selection:
		#	SaverLoader.current_slot = current_selection
		
		saves[new_text] = {
			"datetime" = saves[current_selection]["datetime"],
			"version" = saves[current_selection]["version"],
			"story_description" = saves[current_selection]["story_description"]
		}
		
		saves[current_selection]["button"].queue_free()
		saves.erase(current_selection)
		
		await get_tree().process_frame
		await get_tree().process_frame
		
		saves[new_text]["button"] = _create_button(
			new_text,
			saves[new_text]["datetime"],
			saves[new_text]["version"],
		)
		
		current_selection = new_text)
	
	if SaverLoader.can_save > 0:
		new_save_button.disabled = true
		save_button.disabled = true
	
	_update_list()


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
			"story_description" = game_data["game"]["data"]["story_description"],
		}
		var button = _create_button(
			file_path,
			game_data["system"]["datetime"],
			game_data["system"]["version"]
		)
		saves[file_path]["button"] = button


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
	button.text = save_name + "\n-------------\n" +\
				  date.get_slice(" ", 0) + "\n" + date.get_slice(" ", 1) + "\n-------------\n" +\
				  version
	button.pressed.connect(_save_select.bind(save_name))
	saves_v_box_container.add_child(button)
	
	var children = saves_v_box_container.get_children()
	for child in children:
		if child.name == "NewSaveButton" or child.name.contains("AutoSave"):
			children.erase(child)
	children.sort_custom(func(a: Button, b: Button) -> bool:
		var save_a = a.text.get_slice("\n", 0)
		var save_b = b.text.get_slice("\n", 0)
		
		var datetime_a = saves[save_a]["datetime"]
		var datetime_b = saves[save_b]["datetime"]
		
		return datetime_a > datetime_b)
	
	for child in children:
		saves_v_box_container.move_child(child, -1)
	
	return button
