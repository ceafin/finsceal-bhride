extends NascState
class_name NascIdleState

func _ready() -> void:
	await super._ready()

func enter() -> void:
	nasc.velocity = Vector2.ZERO
	
	# Update animation based on equipment
	if nasc.is_carrying:
		nasc.animated_sprite_2d.play( "carry_" + nasc.facing )
	elif nasc.has_shield:
		if nasc.has_shield == 1:
			nasc.animated_sprite_2d.play( "walk_s1_" + nasc.facing )
		elif nasc.has_shield == 2:
			nasc.animated_sprite_2d.play( "walk_s2_" + nasc.facing )
		else:
			nasc.animated_sprite_2d.play( "walk_" + nasc.facing )
	else:
		nasc.animated_sprite_2d.play( "walk_" + nasc.facing )
	
	nasc.animated_sprite_2d.pause()

# func physics_update(_delta: float) -> void:
# 	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
# 	if input_vector != Vector2.ZERO:
# 		finished.emit(self, "walking")

func handle_command( command: Command ) -> void:
	super.handle_command( command )
	
	# Transition based on command type
	if command is MoveCommand and command.direction != Vector2.ZERO:
		finished.emit( self, "walking" )
	elif command is JumpCommand:
		finished.emit( self, "jumping" )
	elif command is DigCommand:
		finished.emit( self, "digging" )
