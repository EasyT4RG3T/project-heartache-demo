class_name HeavyItem3D
extends Interactable


const ITEM_DROP_VALID = preload("uid://dtutwt0pvs6xq")
const ITEM_DROP_INVALID = preload("uid://ov8441f6kvfv")


@export var mesh: MeshInstance3D
@export var collision: CollisionShape3D
var preview: MeshInstance3D

var collision_query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()

@export var rest_offset: Vector3 = Vector3.ZERO
@export var rest_rot: Vector3 = Vector3.ZERO
@export var hand_offset: Vector3 = Vector3.ZERO
@export var hand_rot: Vector3 = Vector3.ZERO


enum ItemState { OnGround, InHand }


func _ready() -> void:
	mesh.layers = 4
	preview = mesh.duplicate()
	preview.hide()
	add_child(preview)
	
	collision_query.shape = collision.shape
	
	interacted.connect(_pick_up)


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
	
	for child in get_children():
		if child is HeavyItem3D:
			player.add_thought("I can't carry it if it has another heavy object on top")
			return
	
	#if player.held_item:
	#	player.held_item.put_to_inventory(player)
	
	collision.disabled = true
	mesh.layers = 2
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	reparent(player.hands)
	global_position = player.hands.global_position
	position = hand_offset
	global_rotation = player.hands.global_rotation
	rotation = hand_rot
	player.heavy_item = self


func drop(player: PlayerCharacter, ray_result: Dictionary) -> void:
	var reason: String = _check_drop(player, ray_result)
	
	if reason == "":
		collision.disabled = false
		mesh.layers = 4
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		reparent(ray_result["collider"], false)
		global_position = ray_result["position"] + rest_offset
		global_rotation = rest_rot + Vector3(0, player.head.rotation.y, 0)
		player.heavy_item = null
	else:
		player.add_thought(reason)


func show_preview(player: PlayerCharacter, ray_result: Dictionary) -> void:
	preview.show()
	preview.global_position = ray_result["position"] + rest_offset
	preview.global_rotation = rest_rot + Vector3(0, player.head.rotation.y, 0)
	
	if _check_drop(player, ray_result) == "":
		preview.material_override = ITEM_DROP_VALID
	else:
		preview.material_override = ITEM_DROP_INVALID


func hide_preview() -> void:
	preview.hide()


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
