extends Node


var ambient_player: AudioStreamPlayer

var audio_players: Array = []


func clear() -> void:
	if ambient_player.playing:
		ambient_player.stop()
	for audio_player in audio_players:
		if audio_player:
			audio_players.erase(audio_player)
			audio_player.queue_free()


func _init() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func _ready() -> void:
	ambient_player = AudioStreamPlayer.new()
	add_child(ambient_player)
	ambient_player.bus = "Ambient"


func play_sound(bus: StringName, sound: AudioStream, db: float = 0.0, pitch: float = 1.0) -> AudioStreamPlayer:
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.bus = bus
	audio_player.stream = sound
	audio_player.volume_db = db
	audio_player.pitch_scale = pitch
	audio_player.finished.connect(func():
		audio_players.erase(audio_player)
		audio_player.queue_free())
	audio_player.play()
	audio_players.append(audio_player)
	return audio_player


func play_uid_sound(bus: StringName, uid_sound: String, db: float = 0.0, pitch: float = 1.0) -> AudioStreamPlayer:
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_player)
	var sound: AudioStream = load(ResourceUID.uid_to_path(uid_sound))
	audio_player.bus = bus
	audio_player.stream = sound
	audio_player.volume_db = db
	audio_player.pitch_scale = pitch
	audio_player.finished.connect(func():
		audio_players.erase(audio_player)
		audio_player.queue_free())
	audio_player.play()
	audio_players.append(audio_player)
	return audio_player


func play_sound_at(bus: StringName, sound: AudioStream, pos: Vector3, db: float = 0.0, pitch: float = 1.0, unit: float = 10.0) -> AudioStreamPlayer3D:
	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	add_child(audio_player)
	audio_player.bus = bus
	audio_player.stream = sound
	audio_player.volume_db = db
	audio_player.pitch_scale = pitch
	audio_player.unit_size = unit
	audio_player.max_distance = unit * 2
	audio_player.global_position = pos
	audio_player.finished.connect(func():
		audio_players.erase(audio_player)
		audio_player.queue_free())
	audio_player.play()
	audio_players.append(audio_player)
	return audio_player


func play_uid_sound_at(bus: StringName, uid_sound: String, pos: Vector3, db: float = 0.0, pitch: float = 1.0, unit: float = 10.0) -> AudioStreamPlayer3D:
	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	add_child(audio_player)
	var sound: AudioStream = load(ResourceUID.uid_to_path(uid_sound))
	audio_player.bus = bus
	audio_player.stream = sound
	audio_player.volume_db = db
	audio_player.pitch_scale = pitch
	audio_player.unit_size = unit
	audio_player.max_distance = unit * 2
	audio_player.global_position = pos
	audio_player.finished.connect(func():
		audio_players.erase(audio_player)
		audio_player.queue_free())
	audio_player.play()
	audio_players.append(audio_player)
	return audio_player


func play_ambient(uid: String, db: float = 0.0, pitch: float = 1.0) -> void:
	var new_ambient_player = AudioStreamPlayer.new()
	add_child(new_ambient_player)
	var sound: AudioStream = load(ResourceUID.uid_to_path(uid))
	new_ambient_player.stream = sound
	new_ambient_player.volume_db = db
	new_ambient_player.pitch_scale = pitch
	new_ambient_player.play()
	await get_tree().create_timer(1.0).timeout
	ambient_player.queue_free()
	ambient_player = new_ambient_player
