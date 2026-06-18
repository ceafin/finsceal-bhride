## Nasc's Finite State Machine — this is the orchestrator that holds all the states
## as child nodes and routes every frame's worth of input and physics through whichever
## one is currently active. It doesn't know anything about what any particular state
## DOES — it just knows how to tick the active state and swap states when a transition
## signal comes in. Classic FSM pattern from Nystrom's Game Programming Patterns.
extends Node
class_name NascFSM


## Optional inspector-assigned starting state. If left null, the FSM just uses
## whatever the first child state node is, which is usually IdleState.
@export var initial_state : NascState = null

## Optional inspector-assigned input handler. If left null, the FSM will try to
## find one by path inside the Nasc scene (looks for a node named "InputHandler").
@export var input_handler : InputHandler = null


## Typed reference to the owning Nasc player node — set in [method _ready].
var nasc : Nasc

## Whichever state is currently running — the FSM ticks this every frame.
var current_state : NascState

## All child state nodes keyed by their lowercased node name so transitions can
## look them up by string e.g. [code]states["walking"][/code].
var states : Dictionary = {}


## Sets up the whole machine — grabs Nasc, indexes all child states, connects their
## finished signals, and kicks off the initial state.
func _ready() -> void:

	# Wait for Nasc's scene to be fully ready before we try to grab a reference to it
	await owner.ready
	nasc = owner as Nasc
	assert(
		nasc != null,
		"The FSM must be used only in the Nasc Player scene. It needs the owner to be a Nasc Player node."
	)

	# Walk all child nodes, grab the ones that are states, and index them by lowercased name
	for child_state in get_children():
		if child_state is NascState:
			states[ child_state.name.to_lower() ] = child_state              # "IdleState" → states["idlestate"], etc.
			child_state.finished.connect( _transition_to_next_state )        # wire up each state so it can drive transitions

	# Pick which state to start in — either the one assigned in the inspector or just the first child
	var starting_state : NascState = initial_state if initial_state != null else get_child(0) as NascState
	if starting_state and starting_state is NascState:
		starting_state.enter()       # run the initial state's setup
		current_state = starting_state

	# If no input handler was set in the inspector, try to find one by path in the Nasc scene
	if input_handler == null:
		input_handler = nasc.get_node_or_null( "InputHandler" )
		assert(
			input_handler != null,
			"The NascFSM needs an InputHandler assigned or a child InputHandler node inside the Nasc Player scene."
		)


## Passes raw input events down to the active state in case it needs them.
## Most states ignore this and just use the processed [Command] from [method _physics_process],
## but it's here for states that need to react to discrete events (like key releases).
## [param event] the raw input event from Godot
func _unhandled_input(event: InputEvent) -> void:
	if current_state: current_state.handle_input(event)  # forward to active state — it can handle or ignore


## Runs the active state's idle-thread update — for non-physics stuff like timers.
## [param delta] seconds since last frame
func _process(delta: float) -> void:
	if current_state: current_state.update(delta)  # tick the active state's idle logic


## The main per-physics-frame driver — pulls a command from input, hands it to the
## active state, ticks the state's physics logic, then lets Nasc actually move.
## [param delta] the fixed physics timestep
func _physics_process(delta: float) -> void:
	if current_state:
		# Ask the input handler what the player wants to do this frame — always returns something
		var command : Command = input_handler.get_command()

		# Hand that command to the active state — it decides what to do with it
		current_state.handle_command( command )

		# Let the active state run its own physics logic (animation sync, jump timer, etc.)
		current_state.physics_update( delta )

	# After the state does its work, actually apply velocity and resolve collisions
	nasc.move_and_slide()


## Called when any state emits [signal NascState.finished] — handles the actual swap.
## [param acting_state] the state that wants to transition — ignored if it's not current
## [param new_state_name] the lowercased name of the state to switch into
func _transition_to_next_state( acting_state: NascState, new_state_name: String ) -> void:
	# Ignore stale transition requests — only the ACTIVE state gets to drive transitions
	if acting_state != current_state: return

	# Look up the destination state by name — bail if it doesn't exist (typo protection)
	var new_state : NascState = states.get( new_state_name.to_lower() )
	if !new_state: return

	# Clean up the state we're leaving
	if current_state: current_state.exit()

	# Boot up the new state
	new_state.enter()

	# This is now the active state going forward
	current_state = new_state
