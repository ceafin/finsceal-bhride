## Roc's Feather — the jump item, same as in Zelda: Link's Awakening.
## Tap the assigned button while grounded to make Nasc hop.
## The jump carries her current velocity into the air so momentum is preserved —
## if she's running right and jumps, she keeps going right in the air.
## is_continuous is false, so [InputHandler] only generates the command on the initial press.
extends Item
class_name FeatherItem


## Set up item metadata. icon gets assigned in the inspector via the .tres file.
func _init() -> void:
	item_name = "Roc's Feather"   # display name in inventory / pause menu
	item_type = ItemType.TOOL     # it's a tool, not a weapon
	is_continuous = false         # tap to jump, not hold — InputHandler handles this in the just_pressed check


## Creates a [JumpCommand] carrying Nasc's current velocity as jump momentum.
## [JumpCommand.execute] writes that momentum into nasc.jump_momentum, and
## [NascJumpingState.enter] picks it up immediately on transition.
## [param nasc] the player character using the feather
## [return] a [JumpCommand] initialized with Nasc's current velocity
func create_command( nasc: Nasc ) -> Command:
	return JumpCommand.new( nasc.velocity )  # pass current velocity in so momentum carries through the jump


## Block use if Nasc isn't grounded — can't double-jump.
## This gates the command before it's even created, consistent with how
## [JumpCommand.can_execute] also checks is_grounded (belt-and-suspenders).
## [param nasc] the player character to check
## [return] true only if Nasc is on the ground
func can_use( nasc: Nasc ) -> bool:
	return nasc.is_grounded()  # no airborne jumps — must be grounded first
