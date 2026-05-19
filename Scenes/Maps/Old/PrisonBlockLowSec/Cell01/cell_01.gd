extends Node3D


@onready var cell_01_door_hinge_3d: Hinge3D = %Cell01DoorHinge3D


var reflection_update: Timer = Timer.new()


func _ready() -> void:
	cell_01_door_hinge_3d.force_open(1)
	
	add_child(reflection_update)
	var nudge: bool = false
	reflection_update.timeout.connect(func():
		if nudge:
			$ReflectionProbe2.global_position.y += 0.0001
		else:
			$ReflectionProbe2.global_position.y -= 0.0001
		reflection_update.start(0.5))
	reflection_update.start(0.5)
