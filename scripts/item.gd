extends Resource
class_name Item

enum ItemType { WEAPON, TOOL, CONSUMABLE }

@export var item_name : String
@export var item_type : ItemType
@export var is_continuous : bool = false  # Hold to use vs press once
@export var icon : Texture2D

# Each item creates its own command
func create_command( nasc: Nasc ) -> Command:
	return null  # Defined in actual item subclasses

# Can Nasc use this item at the moment
func can_use( nasc: Nasc ) -> bool:
	return not nasc.is_performing_discrete_action
