class_name OnCenterScreenNotifier3D
extends StaticBody3D


signal center_entered
signal center_entered_plus
signal center_exited


@export var distance: float = 0.0


var is_on_center: bool = false
var is_on_center_plus: bool = false


func _ready() -> void:
	collision_layer = 16
	collision_mask = 16


func enter_center() -> void:
	is_on_center = true
	center_entered.emit()
	if distance <= 0.0:
		center_entered_plus.emit()
		return
	while is_on_center:
		await get_tree().process_frame
		var p_distance = (GameManager.player_character.global_position - global_position).length()
		if p_distance < distance:
			center_entered_plus.emit()
			is_on_center_plus = true
			break


func exit_center() -> void:
	center_exited.emit()
	is_on_center = false
	is_on_center_plus = false
