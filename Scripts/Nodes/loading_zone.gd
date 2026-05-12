class_name LoadingZone
extends Area3D


@export var wanted_chunks: Array[String]


func _init() -> void:
	collision_layer = 8
	collision_mask = 8


func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	body_entered.connect(_load_chunks)
	body_exited.connect(_exit_zone)


func _load_chunks(_body: Node3D):
	var chunks_to_load: Array[String] = wanted_chunks.duplicate(true)
	
	for current_chunk: Node in Game.get_chunks():
		var current_chunk_uid: String = ResourceUID.path_to_uid(current_chunk.scene_file_path)
		if chunks_to_load.has(current_chunk_uid):
			chunks_to_load.erase(current_chunk_uid)
	
	for chunk_to_load in chunks_to_load:
		SaverLoader.load_chunk_data(chunk_to_load)


func _exit_zone(_body: Node3D) -> void:
	for current_chunk: Node in Game.get_chunks():
		var current_chunk_uid: String = ResourceUID.path_to_uid(current_chunk.scene_file_path)
		if wanted_chunks.has(current_chunk_uid):
			SaverLoader.save_chunk_data(current_chunk)
