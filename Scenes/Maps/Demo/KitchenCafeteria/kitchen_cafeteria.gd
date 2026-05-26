extends Node3D


@onready var static_cafeteria: StaticBody3D = %StaticCafeteria
const MESH_BURGER = preload("uid://bryahiae8bwhl")

var burger_pos: Vector3 = Vector3(-0.085, 0.088, 0.001)
var burger_rot: Vector3 = Vector3(0.409848, -0.142662, -0.220846)


func _ready() -> void:
	var prisoners: Array = []
	prisoners.append_array(_find_prisoners(static_cafeteria))
	
	for prisoner in prisoners:
		match randi_range(0, 2):
			0:
				_prisoner_sit_2(prisoner)
			1:
				_prisoner_sit_2_burger(prisoner)
			2:
				_prisoner_sit_2_burger_2(prisoner)


func _prisoner_sit_2(prisoner: Node) -> void:
	for child in prisoner.get_children():
		if child is AnimationPlayer:
			child.play("Sit2")
			child.seek(randf_range(0, child.current_animation_length), true)
			child.animation_finished.connect(func(_anim_name: StringName):
				child.play("Sit2"))


func _prisoner_sit_2_burger(prisoner: Node) -> void:
	var burger = MESH_BURGER.instantiate()
	burger.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC
	for child in prisoner.get_children():
		if child.name == "RightHandIK":
			child.add_child(burger)
			burger.position = burger_pos
			burger.rotation = burger_rot
		
		if child is AnimationPlayer:
			child.play("Sit2(Burger)")
			child.seek(randf_range(0, child.current_animation_length), true)
			child.animation_finished.connect(func(_anim_name: StringName):
				match randi_range(0, 1):
					0:
						child.play("Sit2(Burger)")
					1:
						child.play("Sit2(Burger)_Eat")
				)


func _prisoner_sit_2_burger_2(prisoner: Node) -> void:
	var burger: MeshInstance3D = MESH_BURGER.instantiate()
	burger.gi_mode = GeometryInstance3D.GI_MODE_DYNAMIC
	for child in prisoner.get_children():
		if child.name == "RightHandIK":
			child.add_child(burger)
			burger.position = burger_pos
			burger.rotation = burger_rot
		
		if child is AnimationPlayer:
			child.play("Sit2(Burger2)")
			child.seek(randf_range(0, child.current_animation_length), true)
			child.animation_finished.connect(func(_anim_name: StringName):
				match randi_range(0, 1):
					0:
						child.play("Sit2(Burger2)")
					1:
						child.play("Sit2(Burger2)_Eat")
				)


func _find_prisoners(node: Node) -> Array:
	var array: Array = []
	for child in node.get_children():
		if child.name.contains("DefaultPrisoner"):
			array.append(child)
		elif child.get_child_count() > 0:
			array.append_array(_find_prisoners(child))
	
	return array
