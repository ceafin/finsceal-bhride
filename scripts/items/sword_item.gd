## The Sword. Tap to slash, hold past the spin threshold for a spin attack —
## same mechanic as Zelda: Link's Awakening.
## is_continuous = true is the key thing here — that means [InputHandler] will keep
## generating [SwordCommand] objects every frame the button is held, which is exactly
## how [NascSwordState] detects whether the player is still holding the button for
## the spin attack charge. If continuous were false, it'd only get one command on tap
## and could never detect a hold.
extends Item
class_name SwordItem


## Set up item metadata. icon gets assigned in the inspector via the .tres file.
func _init() -> void:
	item_name = "Sword"           # display name in inventory / pause menu
	item_type = ItemType.WEAPON   # it's a weapon, not a tool
	is_continuous = true          # IMPORTANT: hold-to-use so InputHandler keeps sending SwordCommand while held


## Creates a [SwordCommand] — a marker command that tells the FSM to enter [NascSwordState]
## (or tells the sword state that the button is still held, if already there).
## [param nasc] the player character using the sword (not actually used — signature required by base)
## [return] a new [SwordCommand]
func create_command( nasc: Nasc ) -> Command:
	return SwordCommand.new()  # marker command — NascSwordState handles all slash / charge / spin logic internally
