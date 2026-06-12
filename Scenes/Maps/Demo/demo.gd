extends Node3D


signal first_talk_signal
var first_talk: bool = false:
	set(value):
		first_talk = value
		if value:
			first_talk_signal.emit()
signal cell_jumpscare_signal
var cell_jumpscare: bool = false:
	set(value):
		cell_jumpscare = value
		if value:
			cell_jumpscare_signal.emit()
signal second_talk_signal
var second_talk: bool = false:
	set(value):
		second_talk = value
		if value:
			second_talk_signal.emit()
signal kitchen_door_signal
var kitchen_door: bool = false:
	set(value):
		kitchen_door = value
		if value:
			kitchen_door_signal.emit()
signal security_key_signal
var security_key: bool = false:
	set(value):
		security_key = value
		if value:
			security_key_signal.emit()


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
