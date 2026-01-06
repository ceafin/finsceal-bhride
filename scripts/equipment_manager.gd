extends Node

class_name EquipmentManager

signal slot_changed( slot_name: String, item: Item )

# The four equipment slots
var slot_north : Item = null
var slot_east : Item = null
var slot_south : Item = null
var slot_west : Item = null

# Inventory of available items
var inventory : Array[ Item ] = []

func _ready() -> void:
	
	# Initialize with items
	# Later I'll have to figure out how to add item pickup and inventory management
	inventory.append( SwordItem.new() )
	inventory.append( ShovelItem.new() )
	inventory.append( FeatherItem.new() )
	
	# Default equipment setup for testing
	# Figure out how to load this from saved data later
	equip_item( "slot_south", inventory[0] )
	equip_item( "slot_west", inventory[1] )
	equip_item( "slot_east", inventory[2] )

# Equip an item to a slot
func equip_item( slot_name: String, item: Item ) -> void:

	match slot_name:
		"slot_north":
			slot_north = item
		"slot_east":
			slot_east = item
		"slot_south":
			slot_south = item
		"slot_west":
			slot_west = item
	
	slot_changed.emit( slot_name, item )


# Get the item equipped in asked for slot
func get_equipped_item( slot_name: String ) -> Item:

	match slot_name:
		"slot_north":
			return slot_north
		"slot_east":
			return slot_east
		"slot_south":
			return slot_south
		"slot_west":
			return slot_west
	
	return null


# Unequip item from slot
func unequip_slot( slot_name: String ) -> void:
	equip_item( slot_name, null )
