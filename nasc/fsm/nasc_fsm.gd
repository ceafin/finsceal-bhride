extends Node
class_name NascFSM


@export var initial_state : NascState = null  # GUI assignable if I want
@export var input_handler : InputHandler = null  # GUI assignable if I want

var nasc : CharacterBody2D  # Hold the Nasc Player node
var current_state : NascState
var states : Dictionary = {}
# var input_handler : InputHandler # To hold the input handler for the Nasc Player


func _ready() -> void:
	
	# Wait for owning parent node and check it
	await owner.ready
	nasc = owner as Nasc
	assert(
		nasc != null,
		"The FSM must be used only in the Nasc Player scene. It needs the owner to be a Nasc Player node."
	)
	
	# Get the children states as FSM comes online
	for child_state in get_children():
		if child_state is NascState:
			states[ child_state.name.to_lower() ] = child_state
			child_state.finished.connect( _transition_to_next_state )
	
	# Start with initial state or first child state
	var starting_state = initial_state if initial_state != null else get_child(0)
	if starting_state and starting_state is NascState:
		starting_state.enter()
		current_state = starting_state
	
	# If no input handler assigned, try to find one in scene
	if input_handler == null:
		input_handler = nasc.get_node_or_null( "InputHandler" )
		assert(
			input_handler != null,
			"The NascFSM needs an InputHandler assigned or a child InputHandler node inside the Nasc Player scene."
		)

func _unhandled_input(event: InputEvent) -> void:
	if current_state: current_state.handle_input(event)

func _process(delta: float) -> void:
	if current_state: current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		# Get command from input handler
		var command : Command = input_handler.get_command()

		# Let current state handle the command
		current_state.handle_command( command )

		# Let current state do its own physics update
		current_state.physics_update( delta )
	
	nasc.move_and_slide()

func _transition_to_next_state( acting_state: NascState, new_state_name: String ) -> void:
	# Don't transition into myself
	if acting_state != current_state: return
	
	# Grab Nasc's new state's State Node, make it's sure real
	var new_state : NascState = states.get( new_state_name.to_lower() )
	if !new_state: return
	
	# If we have a current state, get out
	if current_state: current_state.exit()
	
	# Enter the new state
	new_state.enter()
	
	# Update what is current state
	current_state = new_state
