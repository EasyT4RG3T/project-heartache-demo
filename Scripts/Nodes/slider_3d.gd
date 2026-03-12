@tool
class_name Slider3D
extends Node3D


signal opened
signal closed


@export var duration: float = 0.8
@export var locked: bool = false
@export var locked_message: String = "Locked"
@export var id: int = 0
@export var slide_distance: float = 1.0:
	set(value):
		slide_distance = value
		if value >= 0:
			if slide_progress > slide_distance:
				slide_progress = slide_distance
		else:
			if slide_progress < slide_distance:
				slide_progress = slide_distance
		if !is_node_ready(): return
		position.z = slide_distance
@export var slide_progress: float = 0.0:
	set(value):
		value = clamp(value, 0, slide_distance)
		slide_progress = value
		if !is_node_ready(): return
		position.z = slide_progress
@export var open: bool = false
@export_tool_button("Reset Preview") var reset_preview: Callable = func():
	position.z = deg_to_rad(slide_progress)


var slide_tween: Tween 
var left_duration: float = 0.0


func _ready() -> void:
	position.z = slide_progress


func interact(player: PlayerCharacter) -> void:
	if locked:
		if locked_message:
			player.add_thought(locked_message)
		return
	
	_slide()


func force_open() -> void:
	if !open:
		if slide_tween:
			slide_tween.kill()
		
		slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		slide_tween.tween_property(self, "slide_progress", slide_distance, duration)
		opened.emit()
		open = true


func force_close() -> void:
	if open:
		if slide_tween:
			slide_tween.kill()
		
		slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		slide_tween.tween_property(self, "slide_progress", 0, duration)
		closed.emit()
		open = false


func _slide() -> void:
	if !open:
		if slide_tween:
			slide_tween.kill()
		
		slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		left_duration = duration * ((slide_distance - slide_progress) / slide_distance)
		
		slide_tween.tween_property(self, "slide_progress", slide_distance, left_duration)
		opened.emit()
		open = true
	
	else:
		if slide_tween:
			slide_tween.kill()
		
		slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		left_duration = duration * (slide_progress / slide_distance)
		
		slide_tween.tween_property(self, "slide_progress", 0, duration)
		closed.emit()
		open = false


func save() -> Dictionary:
	var data: Dictionary = {
		"duration": duration,
		"locked": locked,
		"locked_message": locked_message,
		"id": id,
		"slide_distance": slide_distance,
		"slide_progress": slide_progress,
		"open": open,
		"mid_move": false,
	}
	if slide_tween and slide_tween.is_running():
		data["mid_move"] = true
	return data


func load_save(data: Dictionary) -> void:
	duration = data["duration"]
	locked = data["locked"]
	locked_message = data["locked_message"]
	id = data["id"]
	slide_distance = data["slide_distance"]
	slide_progress = data["slide_progress"]
	open = data["open"]
	if data["mid_move"]:
		if slide_tween:
			slide_tween.kill()
		slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		if open:
			left_duration = duration * ((slide_distance - slide_progress) / slide_distance)
			slide_tween.tween_property(self, "slide_progress", slide_distance, left_duration)
		else:
			left_duration = duration * (slide_progress / slide_distance)
			slide_tween.tween_property(self, "slide_progress", 0, duration)
