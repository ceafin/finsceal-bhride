extends NascState
class_name NascWalkingState

var input_vector : Vector2 = Vector2.ZERO

func _ready() -> void:
	await super._ready()

func enter() -> void:
	if nasc.is_carrying:
		nasc.animated_sprite_2d.play( "carry_" + nasc.facing )
	elif nasc.has_shield == Nasc.SHIELD_1:
		nasc.animated_sprite_2d.play( "walk_s1_" + nasc.facing )
	elif nasc.has_shield == Nasc.SHIELD_2:
		nasc.animated_sprite_2d.play( "walk_s2_" + nasc.facing )
	else:
		nasc.animated_sprite_2d.play( "walk_" + nasc.facing )

func handle_command( command: Command ) -> void:
	super.handle_command( command )

	if command is IdleCommand:
		finished.emit( self, "idle" )
	elif command is JumpCommand:
		finished.emit( self, "jumping" )
	elif command is DigCommand:
		finished.emit( self, "digging" )
