extends NascState
class_name NascWalkingState

var input_vector : Vector2 = Vector2.ZERO

func _ready() -> void:
	await super._ready()

func enter() -> void:
	print( "Entered Walking State")
	
func physics_update(_delta: float) -> void:
	
	# Update animation based on state
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
	
	# input_vector = Input.get_vector( "move_left", "move_right", "move_up", "move_down" )
	# nasc.velocity = input_vector * nasc.movement_speed
	# 
	# if is_equal_approx( nasc.velocity.x, 0.0 ) and is_equal_approx( nasc.velocity.y, 0.0 ):
	# 	finished.emit( self, "idle" )

func handle_command( command: Command ) -> void:
	super.handle_command( command )
	
	# Transition based on command type
	if command is IdleCommand:
		finished.emit( self, "idle" )
	elif command is JumpCommand:
		finished.emit( self, "jumping" )
	elif command is DigCommand:
		finished.emit( self, "digging" )
	
