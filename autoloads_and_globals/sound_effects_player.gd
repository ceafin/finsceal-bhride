extends Node

func play( sound_file_path ):
	var audio : AudioStreamPlayer = AudioStreamPlayer.new()
	audio.stream = sound_file_path
	#audio.volume_db = -25
	audio.finished.connect( audio.queue_free )
	add_child( audio )
	audio.play()
