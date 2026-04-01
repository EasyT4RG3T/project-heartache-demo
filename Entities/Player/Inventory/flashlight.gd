class_name Flashlight
extends Node3D


@onready var light: SpotLight3D = %Light


var disabled: bool = true:
	set(value):
		disabled = value
		if value == true:
			light.hide()

var batteries: Array[float] = []
var current_battery: float = 0.0


func _ready() -> void:
	if disabled:
		light.hide()


func switch() -> void:
	if disabled:
		return
	if light.visible:
		turn_off()
	else:
		turn_on()


func turn_on() -> void:
	if disabled:
		return
	light.show()


func turn_off() -> void:
	if disabled:
		return
	light.hide()
