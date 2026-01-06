extends NascState
class_name NascIdleState

func _ready() -> void:
	await super._ready()

func enter() -> void:
	nasc.velocity = Vector2.ZERO
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
