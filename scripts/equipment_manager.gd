extends Node
class_name EquipmentManager

signal slot_changed(slot_name: String, item: Item)
signal inventory_changed(index: int, item: Item)

const INVENTORY_SIZE := 35

@export_group("Inventory")
@export var starting_inventory : Array[Item] = []

@export_group("Default Equipment")
@export var default_slot_north : Item = null
@export var default_slot_east  : Item = null
@export var default_slot_south : Item = null
@export var default_slot_west  : Item = null

var slots : Dictionary = {
	"slot_north": null,
	"slot_east":  null,
	"slot_south": null,
	"slot_west":  null,
}

var inventory : Array[Item] = []

func _ready() -> void:
	inventory.resize(INVENTORY_SIZE)
	for i in mini(starting_inventory.size(), INVENTORY_SIZE):
		inventory[i] = starting_inventory[i]

	_equip_default("slot_north", default_slot_north)
	_equip_default("slot_east",  default_slot_east)
	_equip_default("slot_south", default_slot_south)
	_equip_default("slot_west",  default_slot_west)

func _equip_default(slot_name: String, item: Item) -> void:
	if not item:
		return
	var idx := inventory.find(item)
	if idx != -1:
		inventory[idx] = null
	slots[slot_name] = item
	slot_changed.emit(slot_name, item)

# The primary gameplay method — always a swap between a grid cell and a slot.
# Handles all four cases: item↔item, item↔empty, empty↔item, empty↔empty.
func swap_inventory_with_slot(grid_index: int, slot_name: String) -> void:
	if slot_name not in slots:
		return
	if grid_index < 0 or grid_index >= inventory.size():
		return
	var grid_item : Item = inventory[grid_index]
	var slot_item : Item = slots[slot_name]
	if grid_item == null and slot_item == null:
		return
	inventory[grid_index] = slot_item
	slots[slot_name]       = grid_item
	slot_changed.emit(slot_name, grid_item)
	inventory_changed.emit(grid_index, slot_item)

func get_equipped_item(slot_name: String) -> Item:
	return slots.get(slot_name) as Item
