extends NascState
class_name NascJumpingState

var jump_duration : float = 0.6
var jump_timer : float = 0.0

func _ready() -> void:
	await super._ready()

func enter() -> void:
	jump_timer = 0.0
	nasc.velocity = nasc.jump_momentum
	nasc.animated_sprite_2d.play("jump_" + nasc.facing)


func physics_update(delta: float) -> void:
	jump_timer += delta

	if jump_timer >= jump_duration:
		if nasc.velocity.length_squared() > 0.1:
			finished.emit(self, "walking")
		else:
			finished.emit(self, "idle")

func handle_command( command: Command ) -> void:
	# During jumping, allow movement commands to change velocity but don't transition states
	if command is MoveCommand:
		command.execute( nasc )
	elif command is IdleCommand:
		command.execute( nasc )

func exit() -> void:
	nasc.is_performing_discrete_action = false
	nasc.jump_momentum = Vector2.ZERO
