extends NascState
class_name NascIdleState

func _ready() -> void:
	await super._ready()

func enter() -> void:
	nasc.velocity = Vector2.ZERO

	if nasc.is_carrying:
		nasc.animated_sprite_2d.play( "carry_" + nasc.facing )
	elif nasc.has_shield == Nasc.SHIELD_1:
		nasc.animated_sprite_2d.play( "walk_s1_" + nasc.facing )
	elif nasc.has_shield == Nasc.SHIELD_2:
		nasc.animated_sprite_2d.play( "walk_s2_" + nasc.facing )
	else:
		nasc.animated_sprite_2d.play( "walk_" + nasc.facing )

	nasc.animated_sprite_2d.pause()

func handle_command( command: Command ) -> void:
	super.handle_command( command )

	if command is MoveCommand and command.direction != Vector2.ZERO:
		finished.emit( self, "walking" )
	elif command is JumpCommand:
		finished.emit( self, "jumping" )
	elif command is DigCommand:
		finished.emit( self, "digging" )
