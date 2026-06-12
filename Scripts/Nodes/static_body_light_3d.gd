@tool
class_name StaticBodyLight3D
extends StaticBody3D


@export var on_material: StandardMaterial3D
@export var off_material: StandardMaterial3D
@export var mesh: MeshInstance3D
@export var light_slot: int = 1

@export_tool_button("Switch") var switch: Callable = func():
		if turned_on:
			turn_off()
		else:
			turn_on()

var turned_on: bool = true


func turn_on() -> void:
	mesh.set_surface_override_material(light_slot, on_material)
	turned_on = true


func turn_off() -> void:
	mesh.set_surface_override_material(light_slot, off_material)
	turned_on = false
