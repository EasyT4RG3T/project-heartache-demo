@tool
class_name Slider3D
extends Node3D


signal opened
signal closed


@export var duration: float = 0.8
@export var locked: bool = false
@export var locked_message: String = "Locked"
@export var id: int = 0
@export var bounce: bool = false
@export var bounce_delay: float = 1.0
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
		if slide_distance >= 0:
			value = clamp(value, 0, slide_distance)
			slide_progress = value
			if slide_progress > (slide_distance * 0.5):
				open = true
			else:
				open = false
		
		else:
			value = clamp(value, slide_distance, 0)
			slide_progress = value
			if slide_progress < (slide_distance * 0.5):
				open = true
			else:
				open = false
		
		if !is_node_ready(): return
		position.z = slide_progress
@export var open: bool = false
@export_tool_button("Reset Preview") var reset_preview: Callable = func():
	position.z = deg_to_rad(slide_progress)


var slide_tween: Tween 
var bounce_timer: Timer


func _ready() -> void:
	position.z = slide_progress
	if bounce:
		bounce_timer = Timer.new()
		add_child(bounce_timer)
		bounce_timer.timeout.connect(_bounce)


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
		
		slide_tween.tween_property(self, "position", Vector3(0, 0, slide_distance), duration)
		opened.emit()
		open = true
		if bounce:
			if !bounce_timer.is_stopped():
				bounce_timer.stop()
			bounce_timer.start(bounce_delay)


func force_close() -> void:
	if open:
		if slide_tween:
			slide_tween.kill()
		
		slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		slide_tween.tween_property(self, "position", Vector3(0, 0, 0), duration)
		closed.emit()
		open = false


func _slide() -> void:
	if !open:
		if slide_tween:
			slide_tween.kill()
		
		slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		slide_tween.tween_property(self, "position", Vector3(0, 0, slide_distance), duration)
		opened.emit()
		open = true
		if bounce:
			if !bounce_timer.is_stopped():
				bounce_timer.stop()
			bounce_timer.start(bounce_delay)
	
	elif !bounce:
		if slide_tween:
			slide_tween.kill()
		
		slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		
		slide_tween.tween_property(self, "position", Vector3(0, 0, 0), duration)
		closed.emit()
		open = false


func _bounce() -> void:
	if slide_tween:
		slide_tween.kill()
	
	slide_tween = create_tween().set_ease(Tween.EASE_OUT).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	slide_tween.tween_property(self, "position", Vector3(0, 0, 0), duration)
	closed.emit()
	open = false
