## Digging state — Nasc is performing a shovel dig action.
## Locks her in place for the full dig animation, then transitions out automatically
## when the animation finishes. The transition target depends on whether she ended
## up with any velocity (which she shouldn't while digging, but it's a safe fallback).
## Uses Nasc's forwarded [signal Nasc.animation_finished] signal to know when to leave,
## so we don't have to hardcode a timer — the animation length drives it.
extends NascState
class_name NascDiggingState


## Chain up to [NascState._ready] so the [member NascState.nasc] reference gets set.
func _ready() -> void:
	await super._ready()  # must wait for nasc reference before connecting signals


## Digging is a committed action — can't interrupt it with items or movement.
## [return] always true — action is locked for the full dig animation
func blocks_actions() -> bool:
	return true  # you're mid-dig, you can't do anything else


## Start the dig — zero velocity so she stays put, play the directional animation,
## and hook up the animation_finished signal so we know when to transition out.
func enter() -> void:
	nasc.velocity = Vector2.ZERO                              # she doesn't move while digging
	nasc.play_animation("dig_" + nasc.facing)                 # play the facing-specific dig animation
	nasc.animation_finished.connect(_finished_digging)        # listen for when the dig animation completes


## The only command we accept while digging is IdleCommand — it just keeps velocity zeroed.
## Everything else (move, jump, sword, items) is blocked.
## [param command] the incoming command — only IdleCommand is handled
func handle_command( command: Command ) -> void:
	if command is IdleCommand:
		command.execute( nasc )  # keep velocity at zero while digging — prevents any drift


## Fires when Nasc's animation_finished signal comes in.
## Checks velocity to decide whether to go idle or walking (should almost always be idle
## since we zeroed velocity in enter, but the check is a safe fallback).
func _finished_digging() -> void:
	if nasc.velocity.length_squared() > 0.1:   # small float threshold — practically never true after a dig
		finished.emit( self, "walking" )        # somehow still moving — walk it off
	else:
		finished.emit( self, "idle" )           # normal case — dig done, go idle


## Clean up — always disconnect the animation signal on exit to prevent ghost callbacks
## if the state machine transitions away before the animation actually finishes.
func exit() -> void:
	if nasc.animation_finished.is_connected(_finished_digging):  # guard against disconnecting something that was never connected
		nasc.animation_finished.disconnect(_finished_digging)
