## Sound effects autoload — lives as a global singleton called [code]SFX[/code].
## The whole point here is dead-simple fire-and-forget audio: you hand it a stream,
## it spins up a fresh [AudioStreamPlayer], plays it, and cleans itself up when done.
## No pooling, no management, nothing fancy — just call [code]SFX.play(my_stream)[/code]
## from anywhere in the project and it just works.
extends Node


## Plays the given [param stream] once and then immediately frees the player node.
## You never have to think about cleanup — it's wired up automatically via signal.
## [param stream] any AudioStream resource (wav, ogg, mp3, whatever)
func play(stream: AudioStream) -> void:
	var audio : AudioStreamPlayer = AudioStreamPlayer.new()  # spin up a fresh player each call so sounds never stomp each other
	audio.stream = stream                                    # point it at the audio file we actually want to play
	audio.finished.connect( audio.queue_free )              # when it's done playing, it deletes itself — no manual cleanup needed
	add_child( audio )                                       # has to be in the tree before play() does anything
	audio.play()                                             # kick it off
