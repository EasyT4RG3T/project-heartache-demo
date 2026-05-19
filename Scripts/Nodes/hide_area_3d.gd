class_name HideArea3D
extends Area3D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 8
	monitorable = false
	
	body_entered.connect(_show)
	body_exited.connect(_hide)


func _hide(_body) -> void:
	print("\nhuh")
	for child in get_children():
		print(child)
		child.hide()


func _show(_body) -> void:
	print("\nuhu")
	for child in get_children():
		print(child)
		child.show()
