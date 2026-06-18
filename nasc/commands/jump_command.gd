## Command for making Nasc jump. Carries the velocity she was already moving at
## when the jump was triggered so [NascJumpingState] can keep that momentum going
## through the air — same as Zelda: LA where your lateral speed carries into jumps.
extends Command
class_name JumpCommand


## The velocity baked in at the moment the jump was requested.
## [NascJumpingState] reads this from [member Nasc.jump_momentum] during [method enter].
var jump_velocity : Vector2


## Bakes in the momentum at construction time.
## [param momentum] Nasc's velocity vector at the moment the jump input was pressed.
##                   Defaults to zero which gives a straight-up stationary hop.
func _init( momentum: Vector2 = Vector2.ZERO ) -> void:
	jump_velocity = momentum  # lock in whatever speed she was going so we can carry it into the air


## Writes the captured velocity into Nasc's jump_momentum property.
## [NascJumpingState.enter] will pick that up immediately when the FSM transitions.
## [param nasc] the player character to hand the momentum off to
func execute( nasc: Nasc ) -> void:
	nasc.jump_momentum = jump_velocity  # FSM reads this in jumping_state.enter()


## Gates the jump so you can't double-jump or air-jump.
## Right now is_grounded always returns true since there's no platformer physics,
## but the hook is here for when that changes.
## [param nasc] the player character whose ground state we're checking
## [return] true only if Nasc is currently on the ground
func can_execute( nasc: Nasc ) -> bool:
	return nasc.is_grounded()  # no double-jumping — must be on the ground first
