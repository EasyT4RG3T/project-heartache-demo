class_name Interactable
extends Resource


signal interacted(player)
signal started_interacting(player)
signal stopped_interacting(player)

enum ShowType { PRESS, TAP, HOLD }
@export var show_type: ShowType = ShowType.PRESS

var active: bool = true

@export var hold_time: float = 0.2
var hold: bool = false:
	set(value):
		if value == hold: return
		if value:
			if !hold_timer:
				hold_timer = Timer.new()
				hold_timer.one_shot = true
				hold_timer.autostart = false
				hold_timer.timeout.connect(_start_interacting)
		
		elif hold_timer:
			hold_timer.queue_free()
		
		hold = value
var hold_timer: Timer
var is_interacting: bool = false
var current_player: PlayerCharacter


func start_looking(player: PlayerCharacter) -> void:
	current_player = player
	if hold:
		player.add_child(hold_timer)


func stop_looking(player: PlayerCharacter) -> void:
	current_player = null
	if hold:
		if !hold_timer.is_stopped():
			hold_timer.stop()
		elif is_interacting:
			stopped_interacting.emit(player)
		is_interacting = false
		player.remove_child(hold_timer)


func interact() -> void:
	if !hold:
		interacted.emit(current_player)
	else:
		hold_timer.start(hold_time)


func _start_interacting() -> void:
	is_interacting = true
	started_interacting.emit(current_player)


func stop_interacting() -> void:
	if !hold: return
	if !hold_timer.is_stopped():
		hold_timer.stop()
		interacted.emit(current_player)
	elif is_interacting:
		stopped_interacting.emit(current_player)
