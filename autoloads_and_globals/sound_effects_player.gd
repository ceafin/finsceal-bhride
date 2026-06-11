extends Node

func play(stream: AudioStream) -> void:
	var audio : AudioStreamPlayer = AudioStreamPlayer.new()
	audio.stream = stream
	audio.finished.connect( audio.queue_free )
	add_child( audio )
	audio.play()
