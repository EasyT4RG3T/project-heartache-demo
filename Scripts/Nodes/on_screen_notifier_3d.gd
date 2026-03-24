class_name OnScreenNotifier3D
extends VisibleOnScreenNotifier3D


signal screen_entered_plus


@export var distance: float = 0.0
@export var area: Area3D


var disabled: bool = false:
	set(value):
		disabled = value
		if value:
			layers = 0
		else:
			layers = 1

var is_on_screen_plus: bool = false


func _ready() -> void:
	if area:
		area.collision_layer = 8
		area.collision_mask = 8
		area.monitoring = true
		area.monitorable = false
	
	await get_tree().process_frame
	
	screen_entered.connect(func():
		if distance <= 0.0:
			if area and area.overlaps_body(GameManager.player_character):
				screen_entered_plus.emit()
				return
		while is_on_screen():
			var p_distance = (GameManager.player_character.global_position - global_position).length()
			if p_distance < distance:
				if area and area.overlaps_body(GameManager.player_character):
					screen_entered_plus.emit()
					is_on_screen_plus = true
					break
			await get_tree().process_frame)
	
	screen_exited.connect(func():
		is_on_screen_plus = false)
