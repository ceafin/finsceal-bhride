## Walking state — Nasc is actively moving around.
## On enter, the correct walk animation starts fresh every time (no name-check guard
## here — that was the old animation restart bug where idle had already set the same
## animation name and paused it, so the check thought nothing needed to change and
## play() never got called). Now enter() always calls play() directly so the
## animation always restarts when you start moving again.
## Every physics tick we check if the direction or shield/carry state changed and
## swap animations if needed, so shield pickup mid-walk looks right automatically.
extends NascState
class_name NascWalkingState


## Chain up to [NascState._ready] so the [member NascState.nasc] reference gets set.
func _ready() -> void:
	await super._ready()  # NascState.ready grabs the nasc reference — must happen before anything else


## Kick off the walk animation fresh. Calling play() directly here (not through
## _sync_animation) is intentional — we always want a clean restart on state entry
## regardless of what animation was previously playing.
func enter() -> void:
	nasc.play_animation(nasc.get_walk_animation_name())  # always restart — fixes the "no restart on re-press" bug


## Every physics tick, make sure the animation matches reality.
## If she picked up a shield or started carrying something mid-walk, the animation
## needs to switch. _sync_animation only swaps if the name actually changed.
## [param _delta] physics timestep — not used here but required by the signature
func physics_update(_delta: float) -> void:
	_sync_animation()  # keep animation in sync with shield/carry state changes


## Handles commands while walking.
## Same pattern as idle — update facing first so the animation reflects new direction,
## then execute, then check if we should transition out.
## [param command] whatever the input handler produced this frame
func handle_command( command: Command ) -> void:
	if not command.can_execute( nasc ):   # respect command gates before doing anything
		return
	if command is MoveCommand:
		nasc.update_facing(command.direction)  # new direction from input — update facing before executing so it reads right
	command.execute( nasc )                    # apply the velocity / effect

	# Figure out where we go from here based on what command just ran
	if command is IdleCommand:
		finished.emit( self, "idle" )    # no direction pressed — stop and go idle
	elif command is JumpCommand:
		finished.emit( self, "jumping" ) # feather pressed while moving — jump with momentum
	elif command is DigCommand:
		finished.emit( self, "digging" ) # shovel pressed — go dig
	elif command is SwordCommand:
		finished.emit( self, "sword" )   # sword button — go slash


## Checks whether the current animation name matches what it SHOULD be, and if not,
## swaps it. This handles shield/carry state changes happening mid-walk without
## needing to watch any signals — we just check every frame and fix it if it drifted.
func _sync_animation() -> void:
	var anim := nasc.get_walk_animation_name()      # what should be playing right now given current state
	if nasc.get_current_animation() != anim:         # only call play() if something actually changed — avoids constant restarts
		nasc.play_animation(anim)
