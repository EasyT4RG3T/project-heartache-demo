class_name Water
extends Area3D


func _ready() -> void:
	collision_layer = 64
	collision_mask = 64
	
	monitoring = true
	monitorable = false
	
	body_entered.connect(wet)


func wet(body: Node3D) -> void:
	if body is WettableObject3D:
		body.wet()
