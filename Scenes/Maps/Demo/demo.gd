extends Node3D


signal first_talk_signal
var first_talk: bool = false:
	set(value):
		first_talk = value
		refresh_hint_timer()
		if value:
			first_talk_signal.emit()
signal cell_jumpscare_signal
var cell_jumpscare: bool = false:
	set(value):
		cell_jumpscare = value
		refresh_hint_timer()
		if value:
			cell_jumpscare_signal.emit()
signal second_talk_signal
var second_talk: bool = false:
	set(value):
		second_talk = value
		refresh_hint_timer()
		if value:
			second_talk_signal.emit()
signal kitchen_door_signal
var kitchen_door: bool = false:
	set(value):
		refresh_hint_timer()
		kitchen_door = value
		if value:
			kitchen_door_signal.emit()
signal security_key_signal
var security_key: bool = false:
	set(value):
		refresh_hint_timer()
		security_key = value
		if value:
			security_key_signal.emit()
signal vent_open_signal
var vent_open: bool = false:
	set(value):
		$HintTimer.stop()
		vent_open = value
		if value:
			vent_open_signal.emit()


func _ready() -> void:
	$HintTimer.timeout.connect(func():
		GameManager.player_character.add_thought("[Tab] Journal"))
	
	await get_tree().process_frame
	GameManager.player_character.global_position = Vector3(-0.817, 0, 0.041)
	if GameManager.is_new_game:
		%Cutscene.play_animation("Wake")


func refresh_hint_timer() -> void:
	$HintTimer.start(60)


func save() -> Dictionary:
	var file: Dictionary = {
		"first_talk" = first_talk,
		"cell_jumpscare" = cell_jumpscare,
		"second_talk" = second_talk,
		"security_key" = security_key,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	first_talk = file["first_talk"]
	cell_jumpscare = file["cell_jumpscare"]
	second_talk = file["second_talk"]
	security_key = file["security_key"]
