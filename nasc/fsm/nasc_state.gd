# Virtual base class for all states in the machine
extends Node
class_name NascState

var nasc : CharacterBody2D

signal finished( acting_state: NascState, new_state_name: String )

func _ready() -> void:
	await owner.ready
	nasc = owner as Nasc
	assert( nasc != null, "NascState must be used in the Nasc scene." )
	

# Returns true if this state can handle the given command
func can_handle_command( command: Command ) -> bool:
	return command.can_execute( nasc )

# Execute a command in this state's context
func handle_command( command: Command ) -> void:
	if can_handle_command( command ):
		command.execute( nasc )

# Called by the state machine when receiving unhandled input events
func handle_input( _event: InputEvent ) -> void:
	pass

# Called by the state machine on the engine's main loop tick
func update( _delta: float ) -> void:
	pass

# Called by the state machine on the engine's physics update tick
func physics_update(_delta: float) -> void:
	pass

# Called by the state machine upon changing the active state
func enter() -> void:
	pass

# Called by the state machine before changing the active state
# Use this function to clean up the state
func exit() -> void:
	pass
