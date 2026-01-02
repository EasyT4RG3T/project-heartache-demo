class_name HeavyItem3D
extends Interactable


const ITEM_DROP_VALID = preload("uid://dtutwt0pvs6xq")
const ITEM_DROP_INVALID = preload("uid://ov8441f6kvfv")


var meshes: Array[MeshInstance3D]
var collisions: Array[CollisionShape3D]

var previews: Node3D = Node3D.new()

var collision_query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()

@export var rest_offset: Vector3 = Vector3.ZERO
@export var rest_rot: Vector3 = Vector3.ZERO
@export var hand_offset: Vector3 = Vector3.ZERO
@export var hand_rot: Vector3 = Vector3.ZERO


enum ItemState { OnGround, InHand }


func _ready() -> void:
	interacted.connect(_pick_up)
	add_child(previews)


func _pick_up(player: PlayerCharacter) -> void:
	if player.current_movement_mode != player.MovementMode.WALKING:
		match player.current_movement_mode:
			player.MovementMode.CROUCHING:
				player.add_thought("I have to stand up to pick this up")
				return
			player.MovementMode.CARRYING:
				player.add_thought("I can't carry multiple heavy objects")
				return
			_:
				player.add_thought("I can't carry this right now")
				return
	
	meshes = []
	collisions = []
	
	for child in get_children():
		if child is HeavyItem3D:
			player.add_thought("I can't carry it if it has another heavy object on top")
			return
		elif child is MeshInstance3D:
			meshes.append(child)
		elif child is CollisionShape3D:
			collisions.append(child)
	
	for collision in collisions:
		collision.disabled = true
	
	for mesh in meshes:
		previews.add_child(mesh.duplicate())
		
		mesh.layers = 2
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	#if player.held_item:
	#	player.held_item.put_to_inventory(player)
	
	reparent(player.hands)
	global_position = player.hands.global_position
	position = hand_offset
	global_rotation = player.hands.global_rotation
	rotation = hand_rot
	player.heavy_item = self


func drop(player: PlayerCharacter, ray_result: Dictionary) -> void:
	var reason: String = _check_drop(player, ray_result)
	
	if reason == "":
		for collision in collisions:
			collision.disabled = false
		
		for mesh in meshes:
			mesh.layers = 1
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		
		reparent(ray_result["collider"], false)
		global_position = ray_result["position"] + rest_offset
		global_rotation = rest_rot + Vector3(0, player.head.rotation.y, 0)
		player.heavy_item = null
		previews.queue_free()
		collisions = []
		meshes = []
	else:
		player.add_thought(reason)


func show_preview(player: PlayerCharacter, ray_result: Dictionary) -> void:
	previews.show()
	previews.global_position = ray_result["position"] + rest_offset
	previews.global_rotation = rest_rot + Vector3(0, player.head.rotation.y, 0)
	
	if _check_drop(player, ray_result) == "":
		for child in previews.get_children():
			if child == MeshInstance3D:
				previews.material_override = ITEM_DROP_VALID
	else:
		for child in previews.get_children():
			if child == MeshInstance3D:
				previews.material_override = ITEM_DROP_INVALID


func hide_preview() -> void:
	previews.hide()


func _check_drop(player: PlayerCharacter, ray_result: Dictionary) -> String:
	collision_query.transform.origin = ray_result["position"] + rest_offset + Vector3(0, 0.01, 0)
	collision_query.transform.basis = Basis.from_euler(rest_rot) *\
		Basis().rotated(Vector3.UP, player.head.rotation.y)
	if get_world_3d().direct_space_state.get_rest_info(collision_query):
		return "I can't place this here"
	
	if !_check_stack(ray_result["collider"]):
		return "This would be unstable"
	
	return ""


func _check_stack(object: Node3D) -> bool:
	if object is HeavyItem3D:
		if object.get_parent() is HeavyItem3D:
			return false
	return true


func save(file: Dictionary) -> void:
	pass


func load_save(file: Dictionary) -> void:
	pass
