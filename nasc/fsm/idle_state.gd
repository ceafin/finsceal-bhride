## Idle state — Nasc is standing still, not doing anything.
## This is the default state she comes back to after finishing any action.
## On enter, velocity is zeroed out and the appropriate standing animation plays
## (paused on the first frame so she's just standing, not walking in place).
## Every frame we check what command came in and either execute it or kick off
## a transition if it's something that requires a different state.
extends NascState
class_name NascIdleState


## Chain up to [NascState._ready] so the [member NascState.nasc] reference gets set.
func _ready() -> void:
	await super._ready()  # NascState.ready grabs the nasc reference — we NEED that before doing anything


## Zero velocity and show the idle frame for whichever direction Nasc is facing.
## We play the walk animation and immediately pause it — that lands on frame 0,
## which is the standing frame, so we reuse the walk sheet without a separate idle sheet.
func enter() -> void:
	nasc.velocity = Vector2.ZERO                             # make sure she's actually stopped, not drifting from a previous state
	nasc.play_animation(nasc.get_walk_animation_name())     # play the correct walk/carry/shield variant for current facing
	nasc.pause_animation()                                   # immediately pause so it freezes on the first (standing) frame


## Handles every incoming command while idle.
## The order here matters — facing update has to happen before execute()
## so the animation that gets played reflects the new direction.
## [param command] whatever the input handler produced this frame
func handle_command( command: Command ) -> void:
	if not command.can_execute( nasc ):   # respect the command's own gate — e.g. JumpCommand blocks if airborne
		return
	if command is MoveCommand:
		nasc.update_facing(command.direction)  # update which way she's looking BEFORE execute so animations are correct
	command.execute( nasc )                    # apply the command's effect (set velocity, write momentum, etc.)

	# Now figure out if this command should pull us out of idle into a different state
	if command is MoveCommand and command.direction != Vector2.ZERO:
		finished.emit( self, "walking" )   # got a non-zero move direction — go to walking
	elif command is JumpCommand:
		finished.emit( self, "jumping" )   # feather used — go to jumping
	elif command is DigCommand:
		finished.emit( self, "digging" )   # shovel used — go to digging
	elif command is SwordCommand:
		finished.emit( self, "sword" )     # sword button — go to sword state
