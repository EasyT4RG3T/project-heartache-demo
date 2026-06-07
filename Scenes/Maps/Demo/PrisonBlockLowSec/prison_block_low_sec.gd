extends Node3D


var staff_door_happened: bool = false:
	set(value):
		staff_door_happened = value
		if value:
			%StaffDoor/Hinge3D.open = false
			%StaffDoor/Hinge3D.open_progress = 0


func _ready() -> void:
	%SkeletonBlanked04/AnimationPlayer.play("Breathe")
	%Skeleton/AnimationPlayer.play("Breathe")
	
	%StaffDoorOnScreenNotifier3D.screen_entered_plus.connect(func():
		%StaffDoor/Hinge3D.force_close())
	
	%StaffDoorArea3D.body_entered.connect(func(_body):
		%StaffDoor/Hinge3D.force_close())
	
	%StaffDoor/Hinge3D.closed.connect(func():
		SaverLoader.can_save += 1
		await get_tree().create_timer(0.4).timeout
		SaverLoader.can_save -= 1
		staff_door_happened = true)


func save() -> Dictionary:
	var file: Dictionary = {
		"staff_door_happened" = staff_door_happened
	}
	
	return file


func load_save(file: Dictionary) -> void:
	staff_door_happened = file["staff_door_happened"]
