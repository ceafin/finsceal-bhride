extends Command
class_name MoveCommand

var direction: Vector2

func _init( dir: Vector2 ) -> void:
	direction = dir
	is_discrete = false

func execute( nasc: Nasc ) -> void:
	nasc.velocity = direction * nasc.movement_speed

func can_execute( nasc: Nasc ) -> bool:
	return not nasc.is_performing_discrete_action
	
