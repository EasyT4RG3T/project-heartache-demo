extends Node


func play_sound_at(sound: AudioStream, pos: Vector3, db: float = 0.0) -> void:
	var d_audio_player: MeshInstance3D = ShapeHelper.create_sphere_mesh(0.2, Color.RED, 0.5)
	add_child(d_audio_player)
	d_audio_player.global_position = pos
	var audio_player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	add_child(audio_player)
	audio_player.stream = sound
	audio_player.max_db = 10
	audio_player.volume_db = db
	audio_player.global_position = pos
	audio_player.finished.connect(func():
		audio_player.queue_free()
		d_audio_player.queue_free())
	audio_player.play()
