extends Item
class_name ShovelItem

func _init() -> void:
	item_name = "Shovel"
	item_type = ItemType.TOOL
	is_continuous = false  # No ball, only dig

func create_command( nasc: Nasc ) -> Command:
	return DigCommand.new()

func can_use( nasc: Nasc ) -> bool:
	return super.can_use( nasc )  # Check discrete action status
