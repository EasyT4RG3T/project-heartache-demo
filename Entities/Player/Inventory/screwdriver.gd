class_name Screwdriver
extends Node3D


var p: PlayerCharacter

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


var disabled: bool = true:
	set(value):
		disabled = value
		if value:
			collision_shape_3d.disabled = true
			hide()
			if journal_entry:
				journal_entry.queue_free()
		else:
			journal_entry = GameManager.journal.add("Screwdriver", "[color=red][ ][/color] Screwdriver")
var journal_entry: RichTextLabel

var move_tween: Tween


func _ready() -> void:
	collision_shape_3d.disabled = true
	hide()


func start_unscrewing(pos: Transform3D, screw: Screw3D) -> void:
	if move_tween:
		move_tween.kill()
	
	global_position = p.head.global_position - p.head.basis.y * 0.4 + p.head.basis.x * 0.1
	
	show()
	
	move_tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "transform", pos, 0.2)
	move_tween.finished.connect(func():
		collision_shape_3d.disabled = false
		screw.start_unscrewing(p))

func stop_unscrewing() -> void:
	if move_tween:
		move_tween.kill()
	
	collision_shape_3d.disabled = true
	
	var origin: Vector3 = p.head.global_position - p.head.basis.y * 0.4 + p.head.basis.x * 0.1
	var pos: Transform3D = Transform3D(p.basis, origin)
	
	move_tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_ease(Tween.EASE_IN)
	move_tween.tween_property(self, "transform", pos, 0.2)
	move_tween.finished.connect(func():
		hide())
