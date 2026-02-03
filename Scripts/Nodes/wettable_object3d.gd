class_name WettableObject3D
extends DynamicObject3D


@export var swap: String


func _ready() -> void:
	super()
	set_collision_layer_value(7, true)


func wet() -> void:
	if !swap: return
	
	var pscene: PackedScene = load(swap)
	var scene: DynamicRigidBody3D = pscene.instantiate()
	
	add_sibling(scene)
	
	scene.global_transform = global_transform
	
	if picked_up:
		scene.pick_up(current_player)
		current_player.phys_object = scene
		current_player.interactable = scene.interactable
	
	queue_free()
