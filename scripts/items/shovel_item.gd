extends Item
class_name ShovelItem

func _init() -> void:
	item_name = "Shovel"
	item_type = ItemType.TOOL
	is_continuous = false

func create_command( nasc: Nasc ) -> Command:
	return DigCommand.new()
