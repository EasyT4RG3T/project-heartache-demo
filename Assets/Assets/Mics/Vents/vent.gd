class_name Vent3D
extends StaticBody3D


const VENT_SQUEAK_01 = "uid://dfd6nswnuicaj"
const VENT_SQUEAK_02 = "uid://hmbn2podfjw1"
const VENT_SQUEAK_03 = "uid://b0mmhko7qwi4t"
var vent_squeaks: Array = [
	VENT_SQUEAK_01,
	VENT_SQUEAK_02,
	VENT_SQUEAK_03
]

@export var screw_01: Screw3D
@export var screw_02: Screw3D
@export var hinge: Hinge3D
@export var collision: CollisionShape3D
@export var interactable_static_body_3d: InteractableStaticBody3D
@export var locked: bool = false


var unlock_01: bool = false:
	set(value):
		unlock_01 = value
		if unlock_02 and !unlocked:
			_unlock()
var unlock_02: bool = false:
	set(value):
		unlock_02 = value
		if unlock_01 and !unlocked:
			_unlock()
var unlocked: bool = false
var open: bool = false:
	set(value):
		open = value
		collision.disabled = value


func _ready() -> void:
	screw_01.unscrewed.connect(func():
		unlock_01 = true)
	screw_02.unscrewed.connect(func():
		unlock_02 = true)
	
	hinge.opened_negative.connect(func():
		open = true
		interactable_static_body_3d.active = false
		if screw_01:
			screw_01.interactable.active = false
		if screw_02:
			screw_02.interactable.active = false)
	hinge.closed.connect(func():
		open = false
		interactable_static_body_3d.active = true
		if screw_01:
			screw_01.interactable.active = true
		if screw_02:
			screw_02.interactable.active = true)
	
	interactable_static_body_3d.interacted.connect(func(_p):
		if locked: return
		_unlock())


func _unlock() -> void:
	unlocked = true
	hinge.locked = false
	hinge.force_open(-1)
	AudioManager.play_uid_sound_at("SFX", vent_squeaks.pick_random(), global_position)


func save() -> Dictionary:
	var file: Dictionary = {
		"unlocked": unlocked,
		"unlock_01": unlock_01,
		"unlock_02": unlock_02,
		"open": open
	}
	
	return file


func load_save(file: Dictionary) -> void:
	unlocked = file["unlocked"]
	unlock_01 = file["unlock_01"]
	unlock_02 = file["unlock_02"]
	open = file["open"]
