## A single cell in the inventory grid — basically just a TextureRect that knows about [Item].
## This extends [TextureRect] directly because a slot IS a texture display;
## there's no separate label, no extra children, nothing — just the item icon or empty.
## These get instantiated in code (not from a .tscn) by [UI._refresh_inventory_grid]
## so the grid can be built dynamically at runtime without 35 hardcoded Panel nodes in the scene.
extends TextureRect
class_name UIItemSlot


## The item this slot is currently showing, or null for empty.
## The setter updates the texture immediately when the item changes so the display
## always reflects the data — no manual sync calls needed from outside.
var item : Item:
	set(value):
		item = value                                   # store the new item reference
		texture = value.icon if value else null        # immediately update the displayed icon, or clear it if null


## Configure the slot's visual properties at runtime.
## These match what a statically-placed TextureRect would have in the inspector —
## sizing, stretching, and mouse passthrough so clicks don't land on invisible inventory cells.
func _ready() -> void:
	custom_minimum_size = Vector2(32, 32)                              # each cell is at least 32×32 regardless of what the GridContainer does with it
	expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL           # scale the icon to fill width while keeping aspect ratio
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED           # center the icon and don't distort it
	mouse_filter = Control.MOUSE_FILTER_IGNORE                        # don't consume mouse events — the cursor handles selection
	texture = item.icon if item else null                              # set initial texture in case item was assigned before _ready fired
