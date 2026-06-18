## Base resource class for all items, tools, and weapons in the game.
## Extend this to create specific items (see [SwordItem], [ShovelItem], [FeatherItem]).
## Being a [Resource] means items live as .tres files in the project, can be set in
## the inspector, and can be preloaded — no scene needed, no node overhead.
## The key method to override is [method create_command] — that's how an item produces
## the action that happens when the player uses it.
extends Resource
class_name Item


## What broad category this item falls into. Mostly for future use — things like
## "only weapons can be charged" or "consumables have a use count" would key off this.
enum ItemType { WEAPON, TOOL, CONSUMABLE }


## The display name shown in the inventory and pause menu.
@export var item_name : String

## What kind of item this is — WEAPON, TOOL, or CONSUMABLE.
@export var item_type : ItemType

## Whether this item should be checked every frame the button is held (true)
## or only on the initial press (false). Sword is continuous (hold to charge);
## Feather and Shovel are discrete (tap to use).
@export var is_continuous : bool = false  # hold-to-use vs. press-once — InputHandler uses this to decide which input check to run

## The icon texture shown in the inventory grid and the button assignment displays.
## Use an [AtlasTexture] here to pull a region out of a sprite sheet.
@export var icon : Texture2D


## Override this in subclasses to return the [Command] that should execute when this item is used.
## The base returns null which means "nothing happens" — always override in real items.
## [param nasc] the player character using the item — passed through to the command
## [return] the command to execute, or null if this item doesn't do anything
func create_command( nasc: Nasc ) -> Command:
	return null  # base does nothing — subclasses must override this


## Override this in subclasses to add prerequisites for item use.
## Return false to silently block the action — e.g. Feather checks is_grounded here.
## Default is always true so items that don't have prerequisites don't have to think about it.
## [param _nasc] the player character — check her state here if needed
## [return] whether the item is currently usable
func can_use( _nasc: Nasc ) -> bool:
	return true  # default — no prerequisites, always usable
