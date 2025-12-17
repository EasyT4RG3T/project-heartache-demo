extends Node


var player_character: PlayerCharacter


func load_playground() -> void:
	var playground = load("res://Scenes/Maps/Playground/playground.tscn")
	playground = playground.instantiate()
	add_child(playground)
	var player = load("res://Entities/Player/player_character.tscn")
	player = player.instantiate()
	add_child(player)
	player_character = player
	DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
	InputManager.player_character = player
	InputManager.player_character_input = true
