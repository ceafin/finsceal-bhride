## Translates raw Godot input into [Command] objects that the FSM can act on.
## This is the Command Pattern's input layer — the whole point is that nothing
## downstream (states, Nasc herself) polls Input directly. They just get a Command
## and don't care where it came from. That makes it trivial to swap in AI commands,
## replay commands, or cutscene commands later without touching any state code.
## Priority order each frame: discrete item actions → continuous item actions → movement → idle.
extends Node
class_name InputHandler


## Typed reference to the owning Nasc — set in [method _ready] from the scene owner.
var nasc : Nasc

## Reference to the equipment manager so we can look up what item is in each slot.
## Assigned externally by [Nasc] when its own equipment_manager setter fires.
var equipment_manager : EquipmentManager  # should be assigned by Nasc after it receives its EquipmentManager


## Grabs the Nasc reference from the scene owner once it's ready.
func _ready() -> void:
	await owner.ready          # wait for Nasc's scene to finish before trying to cast owner
	nasc = owner as Nasc
	assert(
		nasc != null,
        "InputHandler must be child of Nasc scene"  # blow up early if the node tree is wrong
	)


## Polls input and returns the highest-priority [Command] for this frame.
## Always returns something — worst case it's an [IdleCommand] — so the FSM
## never has to null-check.
## [return] the command that should run this frame
func get_command() -> Command:

	var input_vector : Vector2   # will hold the directional input if we get that far

	# Edge case: no equipment manager yet (scene still loading, or not assigned).
	# Fall back to just movement and idle so nothing crashes.
	if not equipment_manager:
		input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")  # raw 2D directional input
		if input_vector != Vector2.ZERO:
			return MoveCommand.new(input_vector)  # moving somewhere — wrap it up
		return IdleCommand.new()                   # nothing pressed — idle

	# --- Highest priority: discrete item actions (just_pressed) ---
	# We check these first so a quick button tap always registers even if movement is also held.
	for slot_name in [ "slot_north", "slot_east", "slot_south", "slot_west" ]:
		if Input.is_action_just_pressed( slot_name ):                    # just_pressed = discrete, one-shot trigger
			var item : Item = equipment_manager.get_equipped_item( slot_name )  # look up whatever's assigned to this slot
			if item and not item.is_continuous:                          # only handle non-continuous items here (sword handles its own continuous check below)
				if item.can_use( nasc ):                                 # let the item check its own prerequisites
					return item.create_command( nasc )                   # hand back whatever command the item generates

	# --- Second priority: continuous item actions (held) ---
	# Sword and any other hold-to-use items. Checked after discrete so a tap doesn't fight a hold.
	for slot_name in [ "slot_north", "slot_east", "slot_south", "slot_west" ]:
		if Input.is_action_pressed( slot_name ):                         # is_action_pressed = true every frame the button is held
			var item : Item = equipment_manager.get_equipped_item( slot_name )
			if item and item.is_continuous:                              # only continuous items in this pass (e.g. sword)
				if item.can_use( nasc ):
					return item.create_command( nasc )                   # keep feeding SwordCommand every frame the button is held

	# --- Third priority: directional movement ---
	# Gets here if no item button is doing anything this frame.
	input_vector = Input.get_vector( "move_left", "move_right", "move_up", "move_down" )  # raw 2D input, normalized on diagonals
	if input_vector != Vector2.ZERO:
		return MoveCommand.new( input_vector )  # player is pushing a direction

	# --- Fallback: idle ---
	# Nothing pressed at all — return idle so the FSM always has a command to chew on.
	return IdleCommand.new()
