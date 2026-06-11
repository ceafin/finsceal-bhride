extends Command
class_name MoveCommand

var direction: Vector2

func _init( dir: Vector2 ) -> void:
	direction = dir

func execute( nasc: Nasc ) -> void:
	nasc.velocity = direction * nasc.movement_speed
