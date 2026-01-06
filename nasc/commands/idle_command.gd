extends Command
class_name IdleCommand

func _init() -> void:
	is_discrete = false

func execute(nasc: Nasc) -> void:
	nasc.velocity = Vector2.ZERO
	
