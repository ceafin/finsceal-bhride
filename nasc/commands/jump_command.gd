extends Command
class_name JumpCommand

var jump_velocity : Vector2  # Store the momentum when jump is initiated

func _init( momentum: Vector2 = Vector2.ZERO ) -> void:
	is_discrete = true
	jump_velocity = momentum

func execute( nasc: Nasc ) -> void:
	# Store the jump momentum on nasc for the jumping state to use
	nasc.jump_momentum = jump_velocity
	nasc.is_performing_discrete_action = true

func can_execute( nasc: Nasc ) -> bool:
	return not nasc.is_performing_discrete_action and nasc.is_grounded()
