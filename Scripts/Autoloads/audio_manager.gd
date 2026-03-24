extends Node


var ambient_player: AudioStreamPlayer


func clear() -> void:
	if ambient_player.playing:
		ambient_player.stop()


func _ready() -> void:
	ambient_player = AudioStreamPlayer.new()
	add_child(ambient_player)
	ambient_player.bus = "Ambient"


func play_sound(bus: StringName, sound: AudioStream, db: float = 0.0, pitch: float = 1.0) -> void:
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.bus = bus
	audio_player.stream = sound
	audio_player.volume_db = db
	audio_player.pitch_scale = pitch
	audio_player.finished.connect(func():
		audio_player.queue_free())
	audio_player.play()


func play_uid_sound(bus: StringName, uid_sound: String, db: float = 0.0, pitch: float = 1.0) -> void:
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(audio_player)
	var sound: AudioStream = load(ResourceUID.uid_to_path(uid_sound))
	audio_player.bus = bus
	audio_player.stream = sound
	audio_player.volume_db = db
	audio_player.pitch_scale = pitch
	audio_player.finished.connect(func():
		audio_player.queue_free())
	audio_player.play()


func play_sound_at(bus: StringName, sound: AudioStream, pos: Vector3, db: float = 0.0, pitch: float = 1.0) -> void:
	var audio_player: RaytracedAudioPlayer3D = RaytracedAudioPlayer3D.new()
	add_child(audio_player)
	audio_player.bus = bus
	audio_player.stream = sound
	audio_player.volume_db = db
	audio_player.pitch_scale = pitch
	audio_player.global_position = pos
	audio_player.finished.connect(func():
		audio_player.queue_free())
	audio_player.play()


func play_uid_sound_at(bus: StringName, uid_sound: String, pos: Vector3, db: float = 0.0, pitch: float = 1.0) -> void:
	var audio_player: RaytracedAudioPlayer3D = RaytracedAudioPlayer3D.new()
	add_child(audio_player)
	var sound: AudioStream = load(ResourceUID.uid_to_path(uid_sound))
	audio_player.bus = bus
	audio_player.stream = sound
	audio_player.volume_db = db
	audio_player.pitch_scale = pitch
	audio_player.global_position = pos
	audio_player.finished.connect(func():
		audio_player.queue_free())
	audio_player.play()


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
