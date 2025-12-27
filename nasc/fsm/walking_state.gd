extends NascState
class_name NascWalkingState

var input_vector : Vector2 = Vector2.ZERO

func _ready() -> void:
	await super._ready()


func physics_update(_delta: float) -> void:
	input_vector = Input.get_vector( "move_left", "move_right", "move_up", "move_down" )

	nasc.velocity = input_vector * nasc.movement_speed
	
	if is_equal_approx( nasc.velocity.x, 0.0 ) and is_equal_approx( nasc.velocity.y, 0.0 ):
		finished.emit( self, "idle" )
