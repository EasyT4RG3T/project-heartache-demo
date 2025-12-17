class_name Flashlight
extends Node3D


@onready var light: SpotLight3D = %Light


var disabled: bool = false

var batteries: Array[float] = []
var current_battery: float = 0.0


func switch() -> void:
	if light.visible:
		turn_off()
	else:
		turn_on()


func turn_on() -> void:
	light.show()


func turn_off() -> void:
	light.hide()
