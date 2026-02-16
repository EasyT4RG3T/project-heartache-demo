class_name OnScreenNotifier3D
extends VisibleOnScreenNotifier3D


signal screen_entered_plus()


@export var distance: float = 0.0


var disabled: bool = false:
	set(value):
		disabled = value
		if value:
			layers = 0
		else:
			layers = 1

var is_on_screen_plus: bool = false


func _init() -> void:
	screen_entered.connect(func():
		if distance <= 0.0:
			screen_entered_plus.emit()
			return
		while is_on_screen():
			await get_tree().process_frame
			var p_distance = (GameManager.player_character.global_position - global_position).length()
			if p_distance < distance:
				screen_entered_plus.emit()
				is_on_screen_plus = true
				break)
	
	screen_exited.connect(func():
		is_on_screen_plus = false)
