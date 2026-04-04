class_name Inventory
extends Node3D


var p: PlayerCharacter


@onready var flashlight: Flashlight = %Flashlight
@onready var screwdriver: Node3D = %Screwdriver
@onready var pistol: Node3D = %Pistol


func _process(delta: float) -> void:
	flashlight.global_position = p.head.global_position - p.head.basis.y * 0.2 - p.head.basis.x * 0.1
	
	flashlight.global_rotation.x = lerpf(
		flashlight.global_rotation.x,
		p.head.global_rotation.x,
		delta * 20
	)
	flashlight.global_rotation.y = lerp_angle(
		flashlight.global_rotation.y,
		p.head.global_rotation.y,
		delta * 20)


func save() -> Dictionary:
	var file: Dictionary = {}
	
	file["flashlight"] = {
		"disabled": flashlight.disabled,
		"visible": flashlight.light.visible,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	flashlight.disabled = file["flashlight"]["disabled"]
	flashlight.light.visible = file["flashlight"]["visible"]
