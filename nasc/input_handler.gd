extends Node
class_name InputHandler

var nasc : Nasc
var equipment_manager : EquipmentManager  # Should be assigned by Nasc

func _ready() -> void:
	await owner.ready
	nasc = owner as Nasc

	assert(
		nasc != null,
        "InputHandler must be child of Nasc scene"
	)


func get_command() -> Command:
	
	var input_vector : Vector2
	
	# [Weird Case] If no equipment manager, just handle movement and idle
	if not equipment_manager:
		print("No equipment manager!")
		# Fallback: just handle movement
		input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input_vector != Vector2.ZERO:
			return MoveCommand.new(input_vector)
		return IdleCommand.new()

	# Check all four slots for discrete actions "just_pressed"
	for slot_name in [ "slot_north", "slot_east", "slot_south", "slot_west" ]:
		if Input.is_action_just_pressed( slot_name ):
			var item = equipment_manager.get_equipped_item( slot_name )
			if item and not item.is_continuous:
				if item.can_use( nasc ):
					return item.create_command( nasc )
	
	# Check all four slots for continuous actions "pressed"
	for slot_name in [ "slot_north", "slot_east", "slot_south", "slot_west" ]:
		if Input.is_action_pressed( slot_name ):
			var item = equipment_manager.get_equipped_item( slot_name )
			if item and item.is_continuous:
				if item.can_use( nasc ):
					return item.create_command( nasc )
	
	# Then check for continuous movement all the time
	input_vector = Input.get_vector( "move_left", "move_right", "move_up", "move_down" )
	if input_vector != Vector2.ZERO:
		return MoveCommand.new( input_vector )
	
	return IdleCommand.new()
