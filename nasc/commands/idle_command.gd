extends Command
class_name IdleCommand

func execute(nasc: Nasc) -> void:
	nasc.velocity = Vector2.ZERO
	
