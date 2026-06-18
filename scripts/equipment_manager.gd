## Manages Nasc's inventory grid and four equipment slots (north/east/south/west buttons).
## The core mechanic is the always-a-swap: every equip/unequip is modeled as a swap
## between a grid cell and a slot, covering all four cases automatically —
## item↔item, item↔empty, empty↔item, and empty↔empty (which is a no-op).
## Items exist in exactly ONE place at a time: either in a grid cell or in a slot.
## The inventory is a fixed-size null-padded array so grid position is always preserved —
## removing an item leaves a null at that index, not a gap.
extends Node
class_name EquipmentManager


## Emitted whenever a slot's contents change — UI listens to this to refresh
## the HUD button icons and the inventory panel slot displays.
## [param slot_name] one of "slot_north", "slot_east", "slot_south", "slot_west"
## [param item] the item now in that slot, or null if it's empty
signal slot_changed(slot_name: String, item: Item)

## Emitted whenever a single inventory grid cell changes — UI listens to this
## to do surgical single-cell updates instead of rebuilding the whole grid.
## [param index] the 0-based grid index (0–34) that changed
## [param item] the item now at that index, or null if it's empty
signal inventory_changed(index: int, item: Item)


## Total number of grid cells in the inventory — 7 columns × 5 rows = 35.
## All inventory arrays are sized to this.
const INVENTORY_SIZE := 35  # 7 cols × 5 rows — matches GRID_COLS in ui.gd


## Items to pre-populate the inventory with at game start.
## Set these in the inspector — they get copied into the live inventory array in [method _ready].
@export_group("Inventory")
@export var starting_inventory : Array[Item] = []

## Default items to have equipped in each slot at game start.
## These get pulled out of the inventory grid and placed directly in the slot,
## so an item can't simultaneously be in the grid AND equipped.
@export_group("Default Equipment")
@export var default_slot_north : Item = null
@export var default_slot_east  : Item = null
@export var default_slot_south : Item = null
@export var default_slot_west  : Item = null


## The four action button slots — each holds an Item reference or null.
## Keyed by slot name string so [InputHandler] can look them up by action name directly.
var slots : Dictionary = {
	"slot_north": null,   # Y button / north face button
	"slot_east":  null,   # A button / east face button
	"slot_south": null,   # B button / south face button
	"slot_west":  null,   # X button / west face button
}

## The fixed-size inventory grid array. Null entries mean empty cells.
## Index = grid position (row * 7 + col), which means position is spatial and preserved.
var inventory : Array[Item] = []


## Initialize the inventory array, copy in starting items, then equip defaults.
func _ready() -> void:
	inventory.resize(INVENTORY_SIZE)                                   # fill the array to 35 slots, all null to start
	for i: int in mini(starting_inventory.size(), INVENTORY_SIZE):    # copy starting items in — mini() guards against an oversized export array
		inventory[i] = starting_inventory[i]

	# Equip defaults after inventory is populated so _equip_default can properly
	# clear the item from its grid slot before moving it to the slot
	_equip_default("slot_north", default_slot_north)
	_equip_default("slot_east",  default_slot_east)
	_equip_default("slot_south", default_slot_south)
	_equip_default("slot_west",  default_slot_west)


## Initializes a slot with a default item without going through the swap mechanic.
## Called only in [method _ready] — gameplay equipping always goes through [method swap_inventory_with_slot].
## Clears the item from the inventory grid if it's there, then puts it in the slot directly.
## [param slot_name] which slot to initialize
## [param item] the item to put there, or null (in which case this is a no-op)
func _equip_default(slot_name: String, item: Item) -> void:
	if not item:       # nothing to equip — just leave the slot null
		return
	var idx : int = inventory.find(item)   # look for this item in the grid
	if idx != -1:
		inventory[idx] = null              # remove it from the grid so it's not in two places at once
	slots[slot_name] = item               # drop it into the slot
	slot_changed.emit(slot_name, item)    # tell the UI about it so displays update


## The ONLY gameplay equip/unequip method. Always does a swap between a grid cell and a slot.
## Covers all four cases:
## - item in grid ↔ item in slot → they swap places
## - item in grid, empty slot → item moves to slot, grid cell empties
## - empty grid cell, item in slot → item moves to grid, slot empties
## - both empty → no-op (early return)
## [param grid_index] 0-based index into the inventory array (0–34)
## [param slot_name] which slot to swap with — must be one of the four valid slot names
func swap_inventory_with_slot(grid_index: int, slot_name: String) -> void:
	if slot_name not in slots:                      # bail if the slot name is garbage
		return
	if grid_index < 0 or grid_index >= inventory.size():  # bail if the index is out of bounds
		return
	var grid_item : Item = inventory[grid_index]   # what's currently in the grid cell
	var slot_item : Item = slots[slot_name]         # what's currently in the slot
	if grid_item == null and slot_item == null:     # both empty — nothing to swap
		return
	inventory[grid_index] = slot_item              # slot's item goes into the grid cell
	slots[slot_name]       = grid_item             # grid's item goes into the slot
	slot_changed.emit(slot_name, grid_item)         # tell UI the slot changed (grid_item is now in the slot)
	inventory_changed.emit(grid_index, slot_item)  # tell UI the grid cell changed (slot_item is now there)


## Looks up and returns the item currently in the given slot, or null if empty.
## Used by [InputHandler] every frame to resolve what command to generate.
## [param slot_name] which slot to look up
## [return] the equipped [Item] or null
func get_equipped_item(slot_name: String) -> Item:
	return slots.get(slot_name) as Item  # .get() returns null for missing keys, as Item casts it properly
