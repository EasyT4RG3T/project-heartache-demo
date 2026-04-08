class_name Vent3D
extends StaticBody3D

@export var screw_01: Screw3D
@export var screw_02: Screw3D
@export var hinge: Hinge3D
@export var collision: CollisionShape3D


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


func _ready() -> void:
	screw_01.unscrewed.connect(func():
		unlock_01 = true)
	screw_02.unscrewed.connect(func():
		unlock_02 = true)
	
	hinge.opened_negative.connect(func():
		collision.disabled = true)
	hinge.closed.connect(func():
		collision.disabled = false)


func _unlock() -> void:
	unlocked = true
	hinge.locked = false
	hinge.force_open(-1)


func save() -> Dictionary:
	var file: Dictionary = {
		"unlocked": unlocked,
		"unlock_01": unlock_01,
		"unlock_02": unlock_02,
	}
	
	return file


func load_save(file: Dictionary) -> void:
	unlocked = file["unlocked"]
	unlock_01 = file["unlock_01"]
	unlock_02 = file["unlock_02"]
