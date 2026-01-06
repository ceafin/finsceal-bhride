extends Item
class_name SwordItem

func _init() -> void:
	item_name = "Sword"
	item_type = ItemType.WEAPON
	is_continuous = true  # Can hold for spin attack

func create_command( nasc: Nasc ) -> Command:
	return SwordCommand.new()

func can_use( nasc: Nasc ) -> bool:
	return super.can_use( nasc )  # Check discrete action status
