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
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			_hint_select()
			accept_event()
			return
	
	if event.is_action_pressed("command_up"):
		if !command_line_history: return
		if command_line_history_selected <= 0: return
		command_line_history_selected -= 1
		_comman_line_history_select()
	
	if event.is_action_pressed("command_down"):
		if !command_line_history: return
		if command_line_history_selected >= command_line_history.size() - 1:
			command_line_history_selected = command_line_history.size()
			command_line.text = ""
			return
		command_line_history_selected += 1
		_comman_line_history_select()


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
	command_history.text += "\n" + "[color=blue][" + time + "][/color]" + "\n" + text


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
	
	if current is Callable:
		return current.call(tokens.slice(1))
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
		else:
			can_hint = false
			return
	
	if tokens.is_empty():
		for key in tree.keys():
			hints.append(key)
	else:
		for key in tree.keys():
			if key.begins_with(tokens[0]):
				hints.append(key)
	
	if hints.is_empty():
		can_hint = false
		return
	
	hints.sort()
	
	for hint in hints:
		command_hint.text += hint + "\n"
	
	command_hint.position.x = command_line.get_caret_draw_pos().x


func _hint_select() -> void:
	if !can_hint:
		can_hint = true
		_update_hint(command_tree, [])
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
	"settings": {
		"save": _command_settings_save,
		"load": _command_settings_load,
	},
	"player": {
		"fly": _command_player_fly,
		"cfly": _command_player_cfly,
	},
	"system": {
		"quit": _command_system_quit,
	}
}


func _command_settings_save(_tokens: PackedStringArray) -> String:
	SaverLoader.save_settings()
	return "saved personal settings"

func _command_settings_load(_tokens: PackedStringArray) -> String:
	SaverLoader.load_settings()
	return "loaded personal settings"

func _command_player_fly(_tokens: PackedStringArray) -> String:
	var player: PlayerCharacter = get_tree().get_first_node_in_group("PlayerCharacter")
	if !player:
		return "[color=red]couldn't find player[/color]"
	
	if player.current_movement_mode != player.MovementMode.FLY:
		player.body_collision.disabled = true
		player.head_collision.disabled = true
		player.pre_fly_movement_mode = player.current_movement_mode
		player.pre_fly_movement_speed = player.current_movement_speed
		player.current_movement_mode = player.MovementMode.FLY
		player.current_movement_speed = player.movement_speeds[player.MovementMode.FLY]
		return "changed " + player.to_string() + " movement mode to fly"
	elif player.body_collision.disabled == false:
		player.body_collision.disabled = true
		player.head_collision.disabled = true
		return "disabled fly collision"
	else:
		player.body_collision.disabled = false
		player.current_movement_mode = player.pre_fly_movement_mode
		player.current_movement_speed = player.pre_fly_movement_speed
		return "changed " + player.to_string() + " movement mode back from fly"

func _command_player_cfly(_tokens: PackedStringArray) -> String:
	var player: PlayerCharacter = get_tree().get_first_node_in_group("PlayerCharacter")
	if !player:
		return "[color=red]couldn't find player[/color]"
	
	if player.current_movement_mode != player.MovementMode.FLY:
		player.pre_fly_movement_mode = player.current_movement_mode
		player.pre_fly_movement_speed = player.current_movement_speed
		player.current_movement_mode = player.MovementMode.FLY
		player.current_movement_speed = player.movement_speeds[player.MovementMode.FLY]
		return "changed " + player.to_string() + " movement mode to fly with collision"
	elif player.body_collision.disabled == true:
		player.body_collision.disabled = false
		player.head_collision.disabled = false
		return "enabled fly collision"
	else:
		player.current_movement_mode = player.pre_fly_movement_mode
		player.current_movement_speed = player.pre_fly_movement_speed
		return "changed " + player.to_string() + " movement mode back from fly with collision"

func _command_system_quit(_tokens: PackedStringArray) -> String:
	get_tree().quit.call_deferred()
	return "quitting..."
