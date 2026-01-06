extends NascState
class_name NascDiggingState

func _ready() -> void:
	await super._ready()
	nasc.animated_sprite_2d.animation_finished.connect( Callable( self, "_finished_digging" ) )

func enter() -> void:
	nasc.velocity = Vector2.ZERO
	nasc.animated_sprite_2d.play( "dig_" + nasc.facing )
	
func handle_command( command: Command ) -> void:
	# Transition based on command type
	if command is IdleCommand:
		command.execute( nasc )

func _finished_digging() -> void:
	print( "Finished digging")
	if nasc.velocity.length_squared() > 0.1:
		finished.emit( self, "walking" )
	else:
		finished.emit( self, "idle" )

func exit() -> void:
	# Reset discrete action flag when leaving digging state
	nasc.is_performing_discrete_action = false
