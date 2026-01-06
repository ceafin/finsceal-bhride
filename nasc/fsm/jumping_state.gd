extends NascState
class_name NascJumpingState

var jump_duration : float = 0.6
var jump_timer : float = 0.0

func _ready() -> void:
	await super._ready()

func enter() -> void:
	jump_timer = 0.0

	# Apply the stored momentum
	nasc.velocity = nasc.jump_momentum
	
	# Play appropriate jump animation
	nasc.animated_sprite_2d.play("jump_" + nasc.facing)

func physics_update(delta: float) -> void:
	jump_timer += delta
	
	# Check if jump is complete
	if jump_timer >= jump_duration:
		nasc.is_performing_discrete_action = false
		nasc.jump_momentum = Vector2.ZERO
		
		# Transition based on whether we're still moving
		if nasc.velocity.length_squared() > 0.1:
			finished.emit(self, "walking")
		else:
			finished.emit(self, "idle")
