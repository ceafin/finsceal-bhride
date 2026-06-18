## Sword state — Nasc is swinging or charging a spin attack.
## This replicates the Zelda LA sword feel: tap the button for a single slash,
## hold it past [constant SPIN_THRESHOLD] seconds for a spin attack.
## The way it tracks "held" vs "released" is clever: [InputHandler] keeps sending
## [SwordCommand] every frame the button is held (it's a continuous item), so
## this state flips [member _button_held] back to true on each SwordCommand and
## false on anything else — no raw Input polling needed.
extends NascState
class_name NascSwordState


## How long the button has to be held before a spin attack triggers (seconds).
const SPIN_THRESHOLD : float = 1.0

## Accumulates elapsed hold time. Reset to 0 every [method enter].
var hold_duration : float = 0.0

## Tracks whether the sword button is still being held this frame.
## Starts true (we just entered because the button was pressed) and gets flipped
## false the frame any non-sword command comes in.
var _button_held : bool = true


## Chain up to [NascState._ready] so the [member NascState.nasc] reference gets set.
func _ready() -> void:
	await super._ready()  # must wait for nasc reference before we do anything


## Sword action locks out all other input — can't jump or use items mid-slash.
## [return] always true — sword state is a blocking action
func blocks_actions() -> bool:
	return true  # no item usage while actively swinging


## Set up the slash — reset state, zero velocity so she stays planted,
## play the directional slash animation, and connect animation_finished so we know
## when the slash is over and can check whether to transition.
func enter() -> void:
	hold_duration = 0.0                                       # fresh timer every time we enter
	_button_held = true                                       # we just entered because the button was pressed — it's held
	nasc.velocity = Vector2.ZERO                              # planted for the slash, no movement
	nasc.play_animation("slash_" + nasc.facing)               # directional slash animation
	nasc.animation_finished.connect(_on_slash_finished)       # hook into animation end so we can transition at the right moment


## Handles the spin attack timing — only relevant when the button is still held
## AND the slash animation has already finished AND we've been holding long enough.
## [param delta] physics timestep in seconds
func physics_update(delta: float) -> void:
	hold_duration += delta                                                                   # keep ticking the hold timer
	if _button_held and not nasc.is_animation_playing() and hold_duration >= SPIN_THRESHOLD:
		_end_sword_action()                                                                  # spin threshold hit — wrap up the sword state


## SwordCommand means the button is still held — flip held back to true.
## Anything else means the button was released — flip held to false and potentially
## wrap up immediately if the animation is also already done.
## [param command] the incoming command this frame
func handle_command(command: Command) -> void:
	if command is SwordCommand:
		_button_held = true     # sword button still down — keep holding
		return
	_button_held = false        # something else came in — button was released
	if not nasc.is_animation_playing():   # if slash is also finished, we're done
		if command is MoveCommand:
			command.execute(nasc)         # let her start moving immediately on release if direction is held
		_end_sword_action()


## Fires when the slash animation completes.
## If the button's already released by then, we're done immediately.
## If it's still held, we let physics_update handle the spin threshold check.
func _on_slash_finished() -> void:
	if not _button_held:
		_end_sword_action()  # button was let go before animation ended — wrap up


## Shared transition logic — checks velocity and goes to walking or idle.
## Called from both animation_finished path and physics_update spin path.
func _end_sword_action() -> void:
	if nasc.velocity.length_squared() > 0.1:   # if we have velocity (from a move command during slash release)
		finished.emit(self, "walking")          # go straight to walking
	else:
		finished.emit(self, "idle")             # stopped — go idle


## Clean up on exit — reset state and always disconnect the animation signal
## to prevent ghost callbacks if we somehow leave before the animation finishes.
func exit() -> void:
	hold_duration = 0.0    # reset timer so next sword entry starts clean
	_button_held = false   # reset held state
	if nasc.animation_finished.is_connected(_on_slash_finished):  # guard — only disconnect if we actually connected
		nasc.animation_finished.disconnect(_on_slash_finished)
