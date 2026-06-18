## Virtual base class for every state in Nasc's finite state machine.
## All the actual states (idle, walking, jumping, etc.) extend this.
## The pattern here is from Robert Nystrom's Game Programming Patterns, State chapter —
## each state owns its own enter/exit/update/handle_command lifecycle, so the FSM
## itself ([NascFSM]) stays dead simple and just routes calls to whichever state is active.
## When a state is done, it emits [signal finished] with its own reference and the
## name of the state to transition to next.
extends Node
class_name NascState


## Typed reference to the player character — set by [NascState._ready] after the
## owner (Nasc's scene root) finishes its own ready call.
var nasc : Nasc


## Emitted when this state decides it's done and the FSM should transition.
## [param acting_state] this state (so the FSM can verify it's still the active one).
## [param new_state_name] lowercased name of the state node to transition into.
signal finished( acting_state: NascState, new_state_name: String )


## Override this to return true if this state should block gameplay commands
## from going through — basically "is Nasc busy right now and shouldn't react to input."
## [NascSwordState], [NascJumpingState], and [NascDiggingState] all return true here.
## [return] whether this state locks out normal action input
func blocks_actions() -> bool:
	return false  # default is non-blocking — action states override this


## Grabs the Nasc reference once the owner scene is fully ready.
## Has to wait because state nodes are children of Nasc's FSM, not Nasc itself,
## so [code]owner[/code] is Nasc but it might not be ready yet when this node inits.
func _ready() -> void:
	await owner.ready                                                       # wait for Nasc's scene to finish setting up
	nasc = owner as Nasc                                                    # owner is the Nasc CharacterBody2D at the root of the player scene
	assert( nasc != null, "NascState must be used in the Nasc scene." )    # blow up early if someone drops this state node somewhere wrong


## Checks whether the given command is allowed to run at all.
## Just delegates down to the command's own [method Command.can_execute].
## [param command] the incoming command to check
## [return] true if the command is currently executable
func can_handle_command( command: Command ) -> bool:
	return command.can_execute( nasc )  # let the command itself decide — e.g. JumpCommand checks is_grounded here


## Default command handler — just executes if allowed.
## Most states override this to also inspect the command type for transitions.
## [param command] the command to potentially execute
func handle_command( command: Command ) -> void:
	if can_handle_command( command ):   # guard first — never execute something that said it can't run
		command.execute( nasc )


## Called by the FSM when an unhandled input event comes in.
## Most states ignore this — it's mainly a hook for states that need raw event data
## rather than the processed Command objects.
## [param _event] the raw InputEvent from Godot's input system
func handle_input( _event: InputEvent ) -> void:
	pass  # base does nothing — override if a state needs raw events


## Called by the FSM on the idle (non-physics) process tick every frame.
## Use this for things that don't need to sync with physics — timers, UI updates, etc.
## [param _delta] time in seconds since the last frame
func update( _delta: float ) -> void:
	pass  # base does nothing — override if a state needs per-frame idle logic


## Called by the FSM every physics tick (fixed timestep).
## This is where movement, collision checks, and animation syncs should live.
## [param _delta] the fixed physics timestep in seconds
func physics_update(_delta: float) -> void:
	pass  # base does nothing — override in states that need physics-tick logic


## Called by the FSM right before this state becomes the active state.
## Set up initial conditions here — reset timers, play entry animations, etc.
func enter() -> void:
	pass  # base does nothing — override to set up each state's starting condition


## Called by the FSM right before switching away from this state.
## Clean up here — disconnect signals, reset vars, whatever this state dirtied.
func exit() -> void:
	pass  # base does nothing — override in states that need cleanup on the way out
