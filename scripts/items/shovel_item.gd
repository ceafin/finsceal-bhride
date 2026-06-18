## The Shovel — dig up stuff on the ground, same as Zelda: LA.
## Tap the assigned button to trigger a dig animation.
## No can_use override needed since there's no prerequisite for digging —
## she can dig any time she's not busy with something else (which [InputHandler] handles
## since it checks nasc.is_busy before dispatching commands from item states).
## is_continuous is false, so [InputHandler] handles this in the just_pressed check.
extends Item
class_name ShovelItem


## Set up item metadata. icon gets assigned in the inspector via the .tres file.
func _init() -> void:
	item_name = "Shovel"          # display name in inventory / pause menu
	item_type = ItemType.TOOL     # it's a tool, not a weapon
	is_continuous = false         # tap to dig, not hold


## Creates a [DigCommand] — a marker command that tells the FSM to transition into [NascDiggingState].
## No payload needed here; the digging state handles all the animation and timing internally.
## [param nasc] the player character using the shovel (not actually used — signature required by base)
## [return] a new [DigCommand]
func create_command( nasc: Nasc ) -> Command:
	return DigCommand.new()  # marker command — NascDiggingState handles all the actual digging logic
