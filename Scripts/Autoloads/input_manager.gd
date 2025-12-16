extends Node


var player_character: PlayerCharacter
var menu: Node
var inventory: Node

var console_input: bool = false
var menu_input: bool = false
var inventory_input: bool = false
var player_character_input: bool = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("console"):
		match console_input:
			false:
				Console.open()
			true:
				Console.close()
	
	if console_input:
		Console.take_input(event)
		return
	
	if menu_input and menu:
		menu.take_input(event)
		return
	
	if inventory_input and inventory:
		inventory.take_input(event)
		return
	
	if player_character_input and player_character:
		player_character.take_input(event)
		return
