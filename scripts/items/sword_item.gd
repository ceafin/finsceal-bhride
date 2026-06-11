extends Item
class_name SwordItem

func _init() -> void:
	item_name = "Sword"
	item_type = ItemType.WEAPON
	is_continuous = true  # Held for charge/spin attack

func create_command( nasc: Nasc ) -> Command:
	return SwordCommand.new()
