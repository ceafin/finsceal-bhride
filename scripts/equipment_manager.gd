extends Node
class_name EquipmentManager

signal slot_changed( slot_name: String, item: Item )

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
	inventory = starting_inventory.duplicate()

	if default_slot_north: equip_item("slot_north", default_slot_north)
	if default_slot_east:  equip_item("slot_east",  default_slot_east)
	if default_slot_south: equip_item("slot_south", default_slot_south)
	if default_slot_west:  equip_item("slot_west",  default_slot_west)

func equip_item( slot_name: String, item: Item ) -> void:
	if slot_name not in slots:
		return
	slots[slot_name] = item
	slot_changed.emit( slot_name, item )

func get_equipped_item( slot_name: String ) -> Item:
	return slots.get( slot_name ) as Item

func unequip_slot( slot_name: String ) -> void:
	equip_item( slot_name, null )
