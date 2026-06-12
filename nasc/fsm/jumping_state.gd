extends NascState
class_name NascJumpingState

var jump_duration : float = 0.6
var jump_timer : float = 0.0

func _ready() -> void:
	await super._ready()

func blocks_actions() -> bool:
	return true

func enter() -> void:
	jump_timer = 0.0
	nasc.velocity = nasc.jump_momentum
	nasc.play_animation("jump_" + nasc.facing)

func physics_update(delta: float) -> void:
	jump_timer += delta
	if jump_timer >= jump_duration:
		if nasc.velocity.length_squared() > 0.1:
			finished.emit(self, "walking")
		else:
			finished.emit(self, "idle")

func handle_command( command: Command ) -> void:
	if command is MoveCommand:
		nasc.update_facing(command.direction)
		command.execute( nasc )
	elif command is IdleCommand:
		command.execute( nasc )

func exit() -> void:
	nasc.jump_momentum = Vector2.ZERO
