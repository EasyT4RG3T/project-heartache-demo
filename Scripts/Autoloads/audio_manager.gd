extends Node


func play_sound_at(sound: AudioStream, pos: Vector3, db: float = 0.0) -> void:
	var audio_player: RaytracedAudioPlayer3D = RaytracedAudioPlayer3D.new()
	add_child(audio_player)
	audio_player.stream = sound
	audio_player.volume_db = db
	audio_player.global_position = pos
	audio_player.finished.connect(func():
		audio_player.queue_free())
	audio_player.play()


func play_uid_sound_at(uid_sound: String, pos: Vector3, db: float = 0.0) -> void:
	var audio_player: RaytracedAudioPlayer3D = RaytracedAudioPlayer3D.new()
	add_child(audio_player)
	var sound = load(ResourceUID.uid_to_path(uid_sound))
	audio_player.stream = sound
	audio_player.volume_db = db
	audio_player.global_position = pos
	audio_player.finished.connect(func():
		audio_player.queue_free())
	audio_player.play()
