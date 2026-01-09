extends StaticBody3D


signal pressed
signal depressed


@onready var area_3d: Area3D = $Area3D
@onready var slider_3d: Slider3D = $Slider3D

var is_active: bool = false


func _ready() -> void:
	area_3d.body_entered.connect(func(_body: Node3D):
		if !is_active:
			pressed.emit()
			is_active = true
			slider_3d.interact(GameManager.player_character))
	area_3d.body_exited.connect(func(_body: Node3D):
		if area_3d.has_overlapping_bodies():
			return
		else:
			depressed.emit()
			is_active = false
			slider_3d.interact(GameManager.player_character))
