@tool
class_name Hinge3D
extends Node3D


signal opened_positive
signal opened_negative
signal closed


@export var open_positive: bool = true:
	set(value):
		open_positive = value
		if value == false and open_negative == false:
			open_negative = true
@export var open_negative: bool = true:
	set(value):
		open_negative = value
		if value == false and open_positive == false:
			open_positive = true
@export var duration: float = 0.8
@export var locked: bool = false
@export var locked_message: String = "Locked"
enum AUnlock { NONE, POSITIVE, NEGATIVE }
@export var auto_unlock: AUnlock = AUnlock.NONE
@export var id: int = 0
@export_range(0.0, 360.0) var max_positive: float = 165.0:
	set(value):
		max_positive = value
		if open_progress > value:
			open_progress = value
		if !is_node_ready(): return
		rotation.y = deg_to_rad(max_positive)
@export_range(0.0, 360.0) var max_negative: float = 165.0:
	set(value):
		max_negative = value
		if open_progress < -value:
			open_progress = -value
		if !is_node_ready(): return
		rotation.y = deg_to_rad(-max_negative)
@export_range(-360.0, 360.0) var open_progress: float = 0.0:
	set(value):
		value = clamp(value, -max_negative, max_positive)
		open_progress = value
		if !is_node_ready(): return
		rotation.y = deg_to_rad(open_progress)
@export var open: bool = false
@export_tool_button("Reset Preview") var reset_preview: Callable = func():
	rotation.y = deg_to_rad(open_progress)


var static_direction: Vector3 = Vector3.ZERO
var direction: float = 0.0
var hinge_tween: Tween


func _ready() -> void:
	static_direction = global_basis.z
	
	rotation.y = deg_to_rad(open_progress)


func interact(player: PlayerCharacter) -> void:
	_direction_check(player)
	
	if locked:
		if !_can_unlock(player):
			return
	
	_move_hinge()


func _direction_check(player: PlayerCharacter) -> void:
	if !open_positive:
		direction = -1
	elif !open_negative:
		direction = 1
	else:
		direction = static_direction.dot(player.main_camera.global_basis.z)


func _can_unlock(player: PlayerCharacter) -> bool:
	if auto_unlock == AUnlock.POSITIVE and static_direction.dot(player.main_camera.global_basis.z) < 0:
		return true
	elif auto_unlock == AUnlock.NEGATIVE and static_direction.dot(player.main_camera.global_basis.z) > 0:
		return true
	
	if locked_message:
		player.add_thought(locked_message)
	return false


func _move_hinge() -> void:
	if hinge_tween:
		hinge_tween.kill()
	
	hinge_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	if !open:
		if direction >= 0:
			hinge_tween.tween_property(self, "open_progress", max_positive, duration)
			opened_positive.emit()
		else:
			hinge_tween.tween_property(self, "open_progress", -max_negative, duration)
			opened_negative.emit()
		open = true
	else:
		hinge_tween.tween_property(self, "open_progress", 0, duration)
		closed.emit()
		open = false
