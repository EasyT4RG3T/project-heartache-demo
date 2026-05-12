class_name LoadingZoneForce
extends Area3D


@export var loading_zone: LoadingZone


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	assert(loading_zone, "no loading zone: " + str(get_path()))
	
	collision_layer = 8
	collision_mask = 8
	
	body_entered.connect(_load_check)


func _load_check(body: Node3D) -> void:
	var chunks_to_load: Array[String] = loading_zone.wanted_chunks.duplicate(true)
	
	for current_chunk: Node in Game.get_chunks():
		var current_chunk_uid: String = ResourceUID.path_to_uid(current_chunk.scene_file_path)
		if chunks_to_load.has(current_chunk_uid):
			chunks_to_load.erase(current_chunk_uid)
	
	if !chunks_to_load.is_empty():
		get_tree().paused = true
		await get_tree().physics_frame
		_load_check(body)
	
	else:
		get_tree().paused = false
