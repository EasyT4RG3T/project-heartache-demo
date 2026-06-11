extends Node3D


const MESH_BURGER = preload("uid://bryahiae8bwhl")

var burger_pos: Vector3 = Vector3(-0.085, 0.088, 0.001)
var burger_rot: Vector3 = Vector3(0.409848, -0.142662, -0.220846)


var key_picked_up: bool = false:
	set(value):
		key_picked_up = value
		if value:
			%Key.queue_free()


func _ready() -> void:
	%Key/KeyInteractable.interacted.connect(func(player: PlayerCharacter):
		player.inventory.add_key("Security Key")
		AudioManager.play_uid_sound("SFX", "uid://cn3tdffsy22my")
		key_picked_up = true)
	
	var prisoners: Array = []
	prisoners.append_array(_find_prisoners(%StaticCafeteria/Assets))
	
	for prisoner in prisoners:
		match randi_range(0, 2):
			0:
				_prisoner_sit_2(prisoner)
			1:
				_prisoner_sit_2_burger(prisoner)
			2:
				_prisoner_sit_2_burger_2(prisoner)
	
	%Friend1/AnimationPlayer.play("Sit2")
	%Friend1/AnimationPlayer.get_animation("Sit2").loop_mode = Animation.LOOP_LINEAR
	%Friend2/AnimationPlayer.play("Sit2")
	%Friend2/AnimationPlayer.get_animation("Sit2").loop_mode = Animation.LOOP_LINEAR
	
	%Friends/InteractableFaze1.interacted.connect(func(player: PlayerCharacter):
		get_parent().faze1()
		player.interactable = null)
	
	%Friends/InteractableFaze2.active = false
	%Friends/InteractableFaze2.interacted.connect(func(player: PlayerCharacter):
		get_parent().faze3()
		player.interactable = null)


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


func faze1() -> void:
	%Friends/InteractableFaze1.queue_free()


func faze2() -> void:
	%Friends/InteractableFaze2.active = true


func faze3() -> void:
	%Friends/InteractableFaze2.queue_free()


func save() -> Dictionary:
	var file: Dictionary = {
		"key_picked_up" = key_picked_up
	}
	
	return file


func load_save(file: Dictionary) -> void:
	key_picked_up = file["key_picked_up"]
