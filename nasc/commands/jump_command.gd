extends Command
class_name JumpCommand

var jump_velocity : Vector2

func _init( momentum: Vector2 = Vector2.ZERO ) -> void:
	is_discrete = true
	jump_velocity = momentum

func execute( nasc: Nasc ) -> void:
	nasc.jump_momentum = jump_velocity

func can_execute( nasc: Nasc ) -> bool:
	return nasc.is_grounded()
