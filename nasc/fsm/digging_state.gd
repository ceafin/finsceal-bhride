extends NascState
class_name NascDiggingState

func _ready() -> void:
	await super._ready()

func blocks_actions() -> bool:
	return true

func enter() -> void:
	nasc.velocity = Vector2.ZERO
	nasc.animated_sprite_2d.play( "dig_" + nasc.facing )
	nasc.animated_sprite_2d.animation_finished.connect(_finished_digging)

func handle_command( command: Command ) -> void:
	if command is IdleCommand:
		command.execute( nasc )

func _finished_digging() -> void:
	if nasc.velocity.length_squared() > 0.1:
		finished.emit( self, "walking" )
	else:
		finished.emit( self, "idle" )

func exit() -> void:
	if nasc.animated_sprite_2d.animation_finished.is_connected(_finished_digging):
		nasc.animated_sprite_2d.animation_finished.disconnect(_finished_digging)
