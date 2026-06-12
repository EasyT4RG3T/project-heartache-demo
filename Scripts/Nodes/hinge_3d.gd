@tool
class_name Hinge3D
extends Node3D


signal opened_positive
signal opened_negative
signal opened
signal closed
signal failed_to_open


const lock_sounds: Array[String] = [
	"uid://buwb4k4rsr8rw",
]
const unlock_sounds: Array[String] = [
	"uid://c65lpm6mkrtu0",
	"uid://dm22gi7yerl1i",
]


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
@export var lock_sound: bool = false
@export var locked_message: String = "Locked"
enum AUnlock { NONE, POSITIVE, NEGATIVE }
@export var auto_unlock: AUnlock = AUnlock.NONE
@export var id: String = "0"
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
var left_duration: float = 0.0


func _ready() -> void:
	rotation.y = 0
	
	static_direction = global_basis.z
	
	rotation.y = deg_to_rad(open_progress)


func interact(player: PlayerCharacter) -> void:
	_direction_check(player)
	
	if locked:
		if player.inventory.keys.has(id) or player.inventory.keys.has("0"):
			locked = false
			AudioManager.play_uid_sound_at("SFX", unlock_sounds.pick_random(), global_position, 0, randf_range(0.9, 1.1))
			_move_hinge()
			return
		
		if _can_unlock(player):
			locked = false
			AudioManager.play_uid_sound_at("SFX", unlock_sounds.pick_random(), global_position, 0, randf_range(0.9, 1.1))
			_move_hinge()
			return
		
		failed_to_open.emit()
		if locked_message:
			if lock_sound:
				AudioManager.play_uid_sound_at("SFX", lock_sounds.pick_random(), global_position, 0, randf_range(0.9, 1.1))
			player.add_thought(locked_message)
		return
	
	_move_hinge()


func force_open(dir: float = 0.0) -> void:
	if !open:
		if hinge_tween:
			hinge_tween.kill()
		
		hinge_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		if dir >= 0:
			hinge_tween.tween_property(self, "open_progress", max_positive, duration)
			opened_positive.emit()
			opened.emit()
		else:
			hinge_tween.tween_property(self, "open_progress", -max_negative, duration)
			opened_negative.emit()
			opened.emit()
		open = true
		locked = false


func force_close() -> void:
	if open:
		if hinge_tween:
			hinge_tween.kill()
		
		hinge_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		hinge_tween.tween_property(self, "open_progress", 0, duration)
		closed.emit()
		open = false


func _direction_check(player: PlayerCharacter) -> void:
	if !open_positive:
		direction = -1
	elif !open_negative:
		direction = 1
	else:
		direction = static_direction.dot(player.main_camera.global_basis.z)


func _can_unlock(player: PlayerCharacter) -> bool:
	if auto_unlock == AUnlock.POSITIVE and static_direction.dot(player.main_camera.global_basis.z) > 0:
		return true
	elif auto_unlock == AUnlock.NEGATIVE and static_direction.dot(player.main_camera.global_basis.z) < 0:
		return true
	
	return false


func _move_hinge() -> void:
	if hinge_tween:
		hinge_tween.kill()
	
	hinge_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	
	if !open:
		if direction >= 0:
			left_duration = duration * ((max_positive - open_progress) / max_positive)
			hinge_tween.tween_property(self, "open_progress", max_positive, left_duration)
			opened_positive.emit()
			opened.emit()
		else:
			left_duration = duration * ((-max_negative - open_progress) / -max_negative)
			hinge_tween.tween_property(self, "open_progress", -max_negative, left_duration)
			opened_negative.emit()
			opened.emit()
		open = true
	else:
		if open_progress > 0:
			left_duration = duration * (open_progress / max_positive)
		else:
			left_duration = duration * (open_progress / -max_negative)
		hinge_tween.tween_property(self, "open_progress", 0, left_duration)
		closed.emit()
		open = false


func save() -> Dictionary:
	var data: Dictionary = {
		"open_positive": open_positive,
		"open_negative": open_negative,
		"duration": duration,
		"locked": locked,
		"locked_message": locked_message,
		"auto_unlock": auto_unlock,
		"id": id,
		"max_positive": max_positive,
		"max_negative": max_negative,
		"open_progress": open_progress,
		"open": open,
	}
	if hinge_tween and hinge_tween.is_running():
		data["mid_move"] = direction
	
	return data


func load_save(data: Dictionary) -> void:
	open_positive = data["open_positive"]
	open_negative = data["open_negative"]
	duration = data["duration"]
	locked = data["locked"]
	locked_message = data["locked_message"]
	auto_unlock = data["auto_unlock"]
	id = data["id"]
	max_positive = data["max_positive"]
	max_negative = data["max_negative"]
	open_progress = data["open_progress"]
	open = data["open"]
	if data.has("mid_move"):
		direction = data["mid_move"]
		if hinge_tween:
			hinge_tween.kill()
		hinge_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		if open:
			if direction >= 0:
				left_duration = duration * ((max_positive - open_progress) / max_positive)
				hinge_tween.tween_property(self, "open_progress", max_positive, left_duration)
			else:
				left_duration = duration * ((-max_negative - open_progress) / -max_negative)
				hinge_tween.tween_property(self, "open_progress", -max_negative, left_duration)
		else:
			if open_progress > 0:
				left_duration = duration * (open_progress / max_positive)
			else:
				left_duration = duration * (open_progress / -max_negative)
			hinge_tween.tween_property(self, "open_progress", 0, left_duration)
