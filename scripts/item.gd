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

# Override in subclasses for item-specific prerequisites (e.g. must be grounded)
func can_use( _nasc: Nasc ) -> bool:
	return true
