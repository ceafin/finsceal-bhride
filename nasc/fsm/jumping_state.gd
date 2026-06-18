## Jumping state — Nasc is in the air after using Roc's Feather.
## This is a timed state: it runs for [member jump_duration] seconds and then
## auto-transitions back to walking or idle depending on whether there's still velocity.
## While airborne, directional input still steers Nasc (same momentum carry as LA)
## but she can't use items or start other actions since [method blocks_actions] is true.
## [member Nasc.jump_momentum] carries the velocity that was active at jump time,
## set by [JumpCommand.execute] right before the transition into this state.
extends NascState
class_name NascJumpingState


## How long the jump lasts in seconds before we check velocity and land.
## Tweak this to make jumps feel snappier or floatier.
const jump_duration : float = 0.6

## Accumulates elapsed time since the jump started — compared against [member jump_duration].
var jump_timer : float = 0.0


## Chain up to [NascState._ready] so the [member NascState.nasc] reference gets set.
func _ready() -> void:
	await super._ready()  # must wait for nasc reference — everything below needs it


## While in the air Nasc is "busy" — can't use items or start actions.
## [return] always true — no item usage mid-air
func blocks_actions() -> bool:
	return true  # you can't pull out a shovel while flying through the air


## Set up the jump — reset the timer, apply the momentum from [JumpCommand], and play the animation.
## jump_momentum was written by [JumpCommand.execute] right before this state was entered,
## so it already has the correct carry velocity baked in.
func enter() -> void:
	jump_timer = 0.0                               # always start fresh so repeated jumps work correctly
	nasc.velocity = nasc.jump_momentum             # carry whatever speed she was moving at into the air
	nasc.play_animation("jump_" + nasc.facing)     # play the directional jump animation


## Counts down the jump timer and transitions out when time's up.
## Which state we go to depends on whether she still has any velocity when landing.
## [param delta] physics timestep in seconds
func physics_update(delta: float) -> void:
	jump_timer += delta                            # accumulate time spent airborne
	if jump_timer >= jump_duration:                # time's up — check if she's still moving
		if nasc.velocity.length_squared() > 0.1:  # small threshold so floats don't cause false idle
			finished.emit(self, "walking")         # still moving — go to walking
		else:
			finished.emit(self, "idle")            # stopped — go back to idle


## Still accept directional input and idle while airborne — you can steer mid-jump
## just like in Zelda LA. Any other command type (items, sword) gets ignored since
## blocks_actions() is true and the input handler respects that.
## [param command] whatever the input handler produced this frame
func handle_command( command: Command ) -> void:
	if command is MoveCommand:
		nasc.update_facing(command.direction)   # let her face and steer while airborne
		command.execute( nasc )                 # apply the directional velocity mid-jump
	elif command is IdleCommand:
		command.execute( nasc )                 # no input — zero velocity so she drops straight down


## Clean up the jump momentum when leaving this state so it doesn't bleed into the next one.
func exit() -> void:
	nasc.jump_momentum = Vector2.ZERO  # always reset so a future jump starts clean
