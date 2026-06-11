extends Node
class_name EquipmentManager

signal slot_changed( slot_name: String, item: Item )

var slots : Dictionary = {
	"slot_north": null,
	"slot_east": null,
	"slot_south": null,
	"slot_west": null,
}

var inventory : Array[ Item ] = []

func _ready() -> void:
	inventory.append( SwordItem.new() )
	inventory.append( ShovelItem.new() )
	inventory.append( FeatherItem.new() )

	equip_item( "slot_south", inventory[0] )
	equip_item( "slot_west", inventory[1] )
	equip_item( "slot_east", inventory[2] )

func equip_item( slot_name: String, item: Item ) -> void:
	if slot_name not in slots:
		return
	slots[slot_name] = item
	slot_changed.emit( slot_name, item )

func get_equipped_item( slot_name: String ) -> Item:
	return slots.get( slot_name ) as Item

func unequip_slot( slot_name: String ) -> void:
	equip_item( slot_name, null )
