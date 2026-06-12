extends NascState
class_name NascIdleState

func _ready() -> void:
	await super._ready()

func enter() -> void:
	nasc.velocity = Vector2.ZERO
	nasc.play_animation(nasc.get_walk_animation_name())
	nasc.pause_animation()

func handle_command( command: Command ) -> void:
	if not command.can_execute( nasc ):
		return
	if command is MoveCommand:
		nasc.update_facing(command.direction)
	command.execute( nasc )

	if command is MoveCommand and command.direction != Vector2.ZERO:
		finished.emit( self, "walking" )
	elif command is JumpCommand:
		finished.emit( self, "jumping" )
	elif command is DigCommand:
		finished.emit( self, "digging" )
	elif command is SwordCommand:
		finished.emit( self, "sword" )
